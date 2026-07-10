package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// openRouterEndpoint API-и OpenRouter (дастрасии ройгону пулакӣ ба
// моделҳои гуногун бо як калид) — модели пешфарз дар зер Qwen-и коднависии
// ройгонро истифода мебарад
const openRouterEndpoint = "https://openrouter.ai/api/v1/chat/completions"

// defaultCoderModel Qwen-и ройгон дар OpenRouter, махсус барои коднависӣ.
// Бо OPENROUTER_MODEL метавон дигар кард (масалан агар номи ройгони
// OpenRouter иваз шавад)
const defaultCoderModel = "qwen/qwen-2.5-coder-32b-instruct:free"

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
		http:  &http.Client{Timeout: 90 * time.Second},
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

const screenPromptTemplate = `You generate Flutter/Dart code for a minimal single-screen demo app.

User's app description: %s

Create exactly ONE screen with exactly 5 buttons, one per major function implied by the description. Each button's onPressed should just show a SnackBar with that function's name (placeholder only — no real backend, networking, or database logic; this is a scaffold the user will extend).

Respond with ONLY valid JSON, no markdown code fences, no explanation, in exactly this shape:
{"app_name": "Short App Name", "main_dart": "..."}

Rules for main_dart (full content of lib/main.dart, as a single string with \n for newlines — this must be a COMPLETE, valid, self-contained Dart file that compiles with the standard Flutter SDK, no external packages beyond "flutter/material.dart"):
- import 'package:flutter/material.dart';
- void main() => runApp(const MyApp());
- MyApp is a StatelessWidget returning a MaterialApp with title matching app_name and a home of MyHomePage
- MyHomePage is a StatelessWidget with a Scaffold: AppBar with the app title, and a body Column (mainAxisAlignment: MainAxisAlignment.center) containing exactly 5 ElevatedButton widgets, each with a descriptive child Text matching one function, and an onPressed that calls ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('<function name>')))
- wrap the 5 buttons so they don't overflow (e.g. each on its own row with some spacing, using SizedBox(height: 12) between them)`

// GenerateScreen тавсифи озоди корбарро мегирад ва экрани якум (MainActivity.kt +
// activity_main.xml + номи барнома)-ро тавассути Qwen мебарорад
func (c *AICoderClient) GenerateScreen(description string) (GeneratedScreen, error) {
	prompt := fmt.Sprintf(screenPromptTemplate, description)

	payload, err := json.Marshal(map[string]interface{}{
		"model": c.model,
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
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return GeneratedScreen{}, fmt.Errorf("failed to parse openrouter response: %w", err)
	}
	if result.Error != nil {
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
