package api

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// openRouterEndpoint API-и OpenRouter (дастрасии ройгону пулакӣ ба
// моделҳои гуногун бо як калид)
const openRouterEndpoint = "https://openrouter.ai/api/v1/chat/completions"

// defaultCoderModel модели пешфарз (аввалин, ки озмуда мешавад).
// fallbackModels — агар модели якум ноком шавад (масалан аз рӯйхати
// ройгон хориҷ шуда бошад — рӯйхати моделҳои ройгони OpenRouter хеле тез
// иваз мешавад), инҳо паиҳам озмуда мешаванд, то АМАЛАН натиҷа гум нашавад,
// на танҳо ба тағйири дастии OPENROUTER_MODEL такя кунем
const defaultCoderModel = "openai/gpt-oss-120b:free"

var fallbackModels = []string{
	"openai/gpt-oss-120b:free",
	"openai/gpt-oss-20b:free",
	"meta-llama/llama-3.3-70b-instruct:free",
	// openrouter/free худаш аз байни моделҳои ройгони ҲОЗИР дастрас интихоб
	// мекунад (на аз рӯйхати собити боло) — то агар ҳамаи се модели дар боло
	// ҳамзамон rate-limit шуда бошанд, ин ҳамчун ҷамъбасти охирин кӯмак кунад
	"openrouter/free",
}

// AICoderClient барои сохтани экрани оддии Android (1 саҳифа, 5 функсия)
// аз тавсифи озоди корбар, тавассути OpenRouter (Qwen coder), истифода мешавад
type AICoderClient struct {
	http  *http.Client
	token string
	model string
}

// NewAICoderClient client-и нав месозад. Агар token холӣ бошад, Enabled()
// false бармегардонад
func NewAICoderClient(token, model string) *AICoderClient {
	if model == "" {
		model = defaultCoderModel
	}
	return &AICoderClient{
		// Дархости экрани пурратар (AppBar, grid-и корт, FAB ва ғ.) аз ду
		// тугмаи оддӣ дарозтар аст, пас ба моделҳои сатҳи ройгон вақти
		// бештар лозим — 90с баъзан кам буд ("context deadline exceeded")
		http:  &http.Client{Timeout: 150 * time.Second},
		token: token,
		model: model,
	}
}

// Enabled нишон медиҳад, ки оё калиди OpenRouter танзим шудааст
func (c *AICoderClient) Enabled() bool {
	return c.token != ""
}

// GeneratedScreen файли асосии экрани як-саҳифагии Flutter (lib/main.dart)-ро
// дар бар мегирад
type GeneratedScreen struct {
	AppName  string
	MainDart string
}

const screenPromptTemplate = `You generate Flutter/Dart code for a polished, realistic-looking single-screen home UI demo app.

User's app description: %s

Identify exactly 5 major functions implied by the description. Design a proper home screen for a real app around them — NOT a plain column of stacked buttons. Each function's tap action should just show a SnackBar with that function's name (placeholder only — no real backend, networking, or database logic; this is a visual scaffold the user will extend).

Respond with ONLY valid JSON, no markdown code fences, no explanation, in exactly this shape:
{"app_name": "Short App Name", "main_dart": "..."}

Rules for main_dart (full content of lib/main.dart, as a single string with \n for newlines — this must be a COMPLETE, valid, self-contained Dart file that compiles with the standard Flutter SDK, no external packages beyond "flutter/material.dart"):
- import 'package:flutter/material.dart';
- void main() => runApp(const MyApp());
- MyApp is a StatelessWidget returning a MaterialApp with title matching app_name, useMaterial3: true, and theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: <a color fitting the app's theme>), useMaterial3: true), and a home of MyHomePage
- MyHomePage is a StatelessWidget with a Scaffold: a colored AppBar (backgroundColor from the theme's colorScheme, centerTitle: true) showing the app title, and a body that is a scrollable, padded Column containing (in this order): (1) a short welcome/header Text styled with Theme.of(context).textTheme.headlineSmall, (2) a GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12) with exactly 5 feature cards, one per function
- each feature card is a Card (elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))) wrapping an InkWell (borderRadius matching) with onTap showing the SnackBar, whose child is a Padding containing a Column (mainAxisAlignment: MainAxisAlignment.center) with a large IconData Icon (pick a fitting Material icon per function, sized ~36, colored from the theme) then SizedBox(height: 8) then a Text with the function's short label (textAlign: TextAlign.center, fontWeight: FontWeight.w600)
- add a FloatingActionButton on the Scaffold for the single most important function, with a fitting icon, that also shows the same SnackBar as its card
- use consistent padding (e.g. EdgeInsets.all(16)) and spacing (SizedBox(height: 16) between the header and the grid) so the screen looks intentional and complete, not sparse`

// rateLimitError маънои онро дорад, ки OpenRouter модели интихобшударо
// муваққатан маҳдуд кардааст (rate-limit-и умумии сатҳи ройгон). retryAfter
// вақти пешниҳодшуда барои интизорӣ пеш аз кӯшиши дигар аст (аз
// retry_after_seconds-и худи хатогии OpenRouter гирифта мешавад)
type rateLimitError struct {
	message    string
	retryAfter time.Duration
}

func (e *rateLimitError) Error() string {
	return fmt.Sprintf("rate-limited: %s (retry after %s)", e.message, e.retryAfter)
}

// maxRateLimitWait — то ин андоза интизор мешавем, то дархости webhook-и
// Telegram аз ҳад зиёд дароз нашавад; агар retry_after_seconds аз ин зиёд
// бошад, ба ҷои интизорӣ бевосита модели навбатиро озмоед
const maxRateLimitWait = 15 * time.Second

// GenerateScreen тавсифи озоди корбарро мегирад ва lib/main.dart-и Flutter-ро
// тавассути OpenRouter мебарорад. Якчанд модели ройгон паиҳам озмуда
// мешаванд (аввал c.model, баъд fallbackModels) — то агар яке аз рӯйхати
// ройгон хориҷ шуда бошад, натиҷа гум нашавад. Агар модел rate-limit шуда
// бошад ва вақти интизорӣ кӯтоҳ бошад, як маротиба дубора кӯшиш мекунад
// пеш аз гузаштан ба модели навбатӣ
func (c *AICoderClient) GenerateScreen(description string) (GeneratedScreen, error) {
	var attempts []string
	for _, model := range c.candidateModels() {
		screen, err := c.generateWithModel(description, model)
		if err == nil {
			return screen, nil
		}

		var rle *rateLimitError
		if errors.As(err, &rle) && rle.retryAfter > 0 && rle.retryAfter <= maxRateLimitWait {
			time.Sleep(rle.retryAfter)
			screen, err = c.generateWithModel(description, model)
			if err == nil {
				return screen, nil
			}
		}

		attempts = append(attempts, fmt.Sprintf("%s: %v", model, err))
	}
	return GeneratedScreen{}, fmt.Errorf("all models failed — %s", strings.Join(attempts, " | "))
}

// candidateModels рӯйхати моделҳоеро бармегардонад, ки паиҳам озмуда
// мешаванд: аввал c.model (пешфарз ё аз OPENROUTER_MODEL), баъд
// fallbackModels (бе такрор)
func (c *AICoderClient) candidateModels() []string {
	models := []string{c.model}
	for _, m := range fallbackModels {
		if m != c.model {
			models = append(models, m)
		}
	}
	return models
}

func (c *AICoderClient) generateWithModel(description, model string) (GeneratedScreen, error) {
	prompt := fmt.Sprintf(screenPromptTemplate, description)

	payload, err := json.Marshal(map[string]interface{}{
		"model": model,
		"messages": []map[string]string{
			{"role": "user", "content": prompt},
		},
	})
	if err != nil {
		return GeneratedScreen{}, err
	}

	req, err := http.NewRequest(http.MethodPost, openRouterEndpoint, bytes.NewReader(payload))
	if err != nil {
		return GeneratedScreen{}, err
	}
	req.Header.Set("Authorization", "Bearer "+c.token)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return GeneratedScreen{}, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return GeneratedScreen{}, err
	}
	if resp.StatusCode != http.StatusOK {
		return GeneratedScreen{}, fmt.Errorf("openrouter request failed: status %d, body: %s", resp.StatusCode, truncateStr(string(body), 500))
	}

	var result struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
		Error *struct {
			Message  string `json:"message"`
			Metadata struct {
				RetryAfterSeconds float64 `json:"retry_after_seconds"`
			} `json:"metadata"`
		} `json:"error"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return GeneratedScreen{}, fmt.Errorf("failed to parse openrouter response: %w", err)
	}
	if result.Error != nil {
		if result.Error.Metadata.RetryAfterSeconds > 0 {
			return GeneratedScreen{}, &rateLimitError{
				message:    result.Error.Message,
				retryAfter: time.Duration(result.Error.Metadata.RetryAfterSeconds * float64(time.Second)),
			}
		}
		return GeneratedScreen{}, fmt.Errorf("openrouter error: %s", result.Error.Message)
	}
	if len(result.Choices) == 0 {
		return GeneratedScreen{}, fmt.Errorf("no choices in openrouter response")
	}

	content := extractJSONObject(result.Choices[0].Message.Content)

	var screen struct {
		AppName  string `json:"app_name"`
		MainDart string `json:"main_dart"`
	}
	if err := json.Unmarshal([]byte(content), &screen); err != nil {
		return GeneratedScreen{}, fmt.Errorf("failed to parse generated screen JSON: %w (raw: %s)", err, truncateStr(content, 300))
	}
	if screen.MainDart == "" {
		return GeneratedScreen{}, fmt.Errorf("generated screen missing required fields")
	}

	return GeneratedScreen{
		AppName:  screen.AppName,
		MainDart: screen.MainDart,
	}, nil
}

// extractJSONObject агар AI сарфи назар аз дархост JSON-ро бо ```json``` печонда
// бошад, ё матни иловагӣ пеш/пас аз он гузошта бошад, танҳо худи объекти
// JSON-ро мебарорад
func extractJSONObject(s string) string {
	s = strings.TrimSpace(s)
	s = strings.TrimPrefix(s, "```json")
	s = strings.TrimPrefix(s, "```")
	s = strings.TrimSuffix(s, "```")
	s = strings.TrimSpace(s)

	start := strings.Index(s, "{")
	end := strings.LastIndex(s, "}")
	if start >= 0 && end > start {
		return s[start : end+1]
	}
	return s
}

func truncateStr(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "..."
}
