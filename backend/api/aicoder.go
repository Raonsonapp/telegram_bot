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

	"appbuilder-bot/backend/utils"
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

// realFunctionalityInstruction — дар ҳар се дархости коднависӣ истифода
// мешавад: ба ҷои ҳамеша "танҳо SnackBar" гуфтан, модел бояд функсияро
// ВОҚЕАН амалӣ кунад агар бе backend/парол имконпазир бошад (holo state ё
// API-и ройгони бе калид), вагарна ҳамчун placeholder-и равшан гузорад
const realFunctionalityInstruction = `For each function: if it can be genuinely implemented using only local state (counters, lists, forms, toggles, local search/filter over sample/seed data) OR a free public API that needs NO API key or account (e.g. https://api.frankfurter.dev/latest for currency exchange rates, or another genuinely keyless public API that clearly fits), implement it for REAL — actual working logic. For network calls, use the "http" package (import 'package:http/http.dart' as http;) with proper async/await, a loading indicator, and error handling (try/catch showing a SnackBar on failure) — never invent fake data pretending to be a real network result. If a function genuinely requires a backend server, user accounts/authentication, or a paid/keyed API, keep it as a clearly-labeled placeholder (SnackBar on tap explaining what real backend it would need) instead of faking it.`

// designPromptTemplate — модели АЛОҲИДА (на коднавис), ки танҳо нақшаи
// дизайнро (ранг, чойгиршавӣ, шаффофият, фосила ва ғ.) месозад, БЕ навиштани
// код. Натиҷааш баъд ба модели коднавис ҳамчун роҳнамо дода мешавад — ду
// зинаи алоҳида (аввал "тарроҳ", баъд "коднавис"), тавре ки дархост шуда буд
const designPromptTemplate = `You are a senior UI/UX designer (not a developer). Given an app description, produce a concise design specification that ANOTHER model (a developer) will use to build a Flutter screen. Do NOT write any code — only design decisions.

App description: %s

Respond with ONLY valid JSON, no markdown fences, no explanation, in exactly this shape:
{"seed_color": "#RRGGBB", "layout_style": "short description of layout/composition", "spacing": "short guidance on padding and gaps", "elevation_and_shadow": "short guidance on elevation/shadow depth", "corner_radius": "short guidance on corner rounding", "typography": "short guidance on text weight/emphasis", "icon_style_notes": "short note on which kind of FeatherIcons fit this app's tone (e.g. rounded/friendly vs sharp/professional)", "notes": "1-2 sentences of any other guidance that would make the screen look modern and polished"}`

const screenPromptTemplate = `You generate Flutter/Dart code for a polished, realistic-looking single-screen home UI demo app. Design quality is the TOP priority — a beautiful, professional-looking screen matters more than anything else here, since the user judges the whole app by how this first screen looks.

User's app description: %s

Design specification from the design step — follow it closely for colors, spacing, elevation, corners, and icon tone (if empty, use your own best judgment): %s

Identify exactly 5 major functions implied by the description. Design a proper home screen for a real app around them — NOT a plain column of stacked buttons.

%s

Respond with ONLY valid JSON, no markdown code fences, no explanation, in exactly this shape:
{"app_name": "Short App Name", "main_dart": "..."}

Rules for main_dart (full content of lib/main.dart, as a single string with \n for newlines — this must be a COMPLETE, valid, self-contained Dart file that compiles with the standard Flutter SDK, no external packages beyond "flutter/material.dart", "flutter_feather_icons/flutter_feather_icons.dart", "package:http/http.dart" as http, and "dart:convert" if actually needed):
- import 'package:flutter/material.dart';
- import 'package:flutter_feather_icons/flutter_feather_icons.dart';
- ALL icons anywhere in the file (feature cards, FloatingActionButton, anything else) MUST use FeatherIcons.<name> (e.g. FeatherIcons.home, FeatherIcons.user, FeatherIcons.search) — never Icons.<name> from Material. Pick the FeatherIcons constant that best matches each function.
- void main() => runApp(const MyApp());
- MyApp is a StatelessWidget returning a MaterialApp with title matching app_name, useMaterial3: true, and theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: <a color fitting the app's theme>), useMaterial3: true), and a home of MyHomePage
- MyHomePage is a StatelessWidget with a Scaffold: a colored AppBar (backgroundColor from the theme's colorScheme, centerTitle: true) showing the app title, and a body that is a scrollable, padded Column containing (in this order): (1) a short welcome/header Text styled with Theme.of(context).textTheme.headlineSmall, (2) a GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12) with exactly 5 feature cards, one per function
- each feature card is a Card (elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))) wrapping an InkWell (borderRadius matching) with onTap performing that function's real action (or the SnackBar placeholder — see functionality rules below), whose child is a Padding containing a Column (mainAxisAlignment: MainAxisAlignment.center) with a large FeatherIcons Icon (sized ~32, colored from the theme) then SizedBox(height: 8) then a Text with the function's short label (textAlign: TextAlign.center, fontWeight: FontWeight.w600)
- add a FloatingActionButton on the Scaffold for the single most important function, with a fitting FeatherIcons icon, wired to that same function's action
- use consistent padding (e.g. EdgeInsets.all(16)) and spacing (SizedBox(height: 16) between the header and the grid) so the screen looks intentional, modern, and complete, not sparse or generic`

// fullAppPromptTemplate — барои корбароне истифода мешавад, ки ҳадди
// даъватро (5 нафар) пур кардаанд: ба ҷои 1 экрани оддӣ, барномаи
// бо якчанд қисм (bottom navigation) месозад — ҳанӯз 1 файл (lib/main.dart),
// то системаи мавҷудаи push/build/fix бе тағйир кор кунад, вале аз назари
// корбар "барномаи пурратар" ба назар мерасад
const fullAppPromptTemplate = `You generate Flutter/Dart code for a fuller, more complete app (still a single lib/main.dart file, but richer than a single screen). Design quality is the TOP priority — every tab must look like a real, professionally designed screen, not a rough sketch.

User's app description: %s

Design specification from the design step — follow it closely for colors, spacing, elevation, corners, and icon tone (if empty, use your own best judgment): %s

Identify 3 to 4 main sections/tabs implied by the description (e.g. Home, Search, Profile, Settings — pick ones that actually fit the description, not generic placeholders). Build a proper bottom-navigation app: a Scaffold with a BottomNavigationBar (3 to 4 items with fitting icons+labels) switching between an IndexedStack of that many tab widgets. Each tab must have its own realistic, complete UI (lists, cards, forms, avatars — whatever fits that tab's purpose), not just a placeholder button.

%s

Respond with ONLY valid JSON, no markdown code fences, no explanation, in exactly this shape:
{"app_name": "Short App Name", "main_dart": "..."}

Rules for main_dart (full content of lib/main.dart, as a single string with \n for newlines — this must be a COMPLETE, valid, self-contained Dart file that compiles with the standard Flutter SDK, no external packages beyond "flutter/material.dart", "flutter_feather_icons/flutter_feather_icons.dart", "package:http/http.dart" as http, and "dart:convert" if actually needed, with every tab widget defined as a private class in this same file):
- import 'package:flutter/material.dart';
- import 'package:flutter_feather_icons/flutter_feather_icons.dart';
- ALL icons anywhere in the file (bottom nav items, in-tab icons, everything) MUST use FeatherIcons.<name> — never Icons.<name> from Material. Pick the FeatherIcons constant that best matches each purpose.
- void main() => runApp(const MyApp());
- MyApp is a StatelessWidget: MaterialApp with useMaterial3: true, theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: <a color fitting the app's theme>), useMaterial3: true), and home MyHomePage
- MyHomePage is a StatefulWidget holding the selected tab index in its State; its Scaffold has body: IndexedStack(index: _selectedIndex, children: [...one widget per tab...]) and bottomNavigationBar: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), type: BottomNavigationBarType.fixed, items: [...])
- each tab is its own private StatelessWidget or StatefulWidget class (e.g. _HomeTab, _SearchTab, _ProfileTab) with its own Scaffold-less body (each tab supplies just its content; wrap each tab's content in its own AppBar+body via a Scaffold per tab, or share one AppBar in MyHomePage whose title updates with the tab — pick whichever is simpler to implement correctly)
- keep the file complete and compiling — prioritize correctness over maximal feature count; it is fine to keep each tab's content moderately simple as long as it looks like a real, finished, well-designed screen`

const fixPromptTemplate = `The following Flutter/Dart lib/main.dart failed to build in GitHub Actions ("flutter build apk"). Fix it so it builds successfully, while preserving the same screen design and functionality intent.

Original app description: %s

Previous lib/main.dart:
%s

Build error log (tail):
%s

Respond with ONLY valid JSON, no markdown code fences, no explanation, in exactly this shape:
{"app_name": "Short App Name", "main_dart": "..."}

main_dart must be the FULL corrected content of lib/main.dart (a single string with \n for newlines) — still a complete, self-contained Dart file. Allowed imports: 'package:flutter/material.dart', 'package:flutter_feather_icons/flutter_feather_icons.dart', 'package:http/http.dart' as http, and 'dart:convert'. Keep using FeatherIcons.<name> for every icon (never Icons.<name>) unless a wrong FeatherIcons name is the actual cause of the build failure, in which case pick a valid one. Keep any real (non-placeholder) network logic working — only remove/simplify it if it is the actual cause of the build failure.`

// addFunctionPromptTemplate — вақте истифода мешавад, ки корбар як
// барномаи МАВҶУДА дошта бошад ва хоҳад як функсияи мушаххаси навро
// илова кунад (масалан "чат кардан"), бе аз нав сохтани ҳамаи экран
const addFunctionPromptTemplate = `You are updating an existing Flutter/Dart lib/main.dart file for an app. Add the following new function/feature to it, integrating it naturally into the existing screen(s) — as a new feature card, tab, button, or section, whichever fits the existing design best. Do NOT remove or break any existing functionality; keep everything else working exactly as it is.

App description (for context): %s

New function to add: %s

Design specification to match the app's existing look (if empty, infer the style from the current code): %s

Current lib/main.dart:
%s

%s

Respond with ONLY valid JSON, no markdown fences, no explanation, in exactly this shape:
{"app_name": "Short App Name", "main_dart": "..."}

main_dart must be the FULL updated content of lib/main.dart (a single string with \n for newlines) — still a complete, self-contained Dart file. Allowed imports: 'package:flutter/material.dart', 'package:flutter_feather_icons/flutter_feather_icons.dart', 'package:http/http.dart' as http, and 'dart:convert'. Keep using FeatherIcons.<name> for icons (never Icons.<name>).`

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
	designSpec := c.generateDesignSpec(description)
	prompt := fmt.Sprintf(screenPromptTemplate, description, designSpec, realFunctionalityInstruction)
	return c.runPromptAcrossModels(prompt)
}

// GenerateFullApp мисли GenerateScreen аст, вале дархости пурратар
// (bottom-navigation бо якчанд tab, на 1 экрани оддӣ) мефиристад — барои
// корбароне, ки ҳадди даъватро (5 нафар) пур кардаанд
func (c *AICoderClient) GenerateFullApp(description string) (GeneratedScreen, error) {
	designSpec := c.generateDesignSpec(description)
	prompt := fmt.Sprintf(fullAppPromptTemplate, description, designSpec, realFunctionalityInstruction)
	return c.runPromptAcrossModels(prompt)
}

// AddFunction як функсияи навро ба lib/main.dart-и МАВҶУДА (currentCode)
// илова мекунад, бе аз нав сохтани ҳамаи барнома — то корбар тавонад
// пайдарпай функсия ба функсия илова кунад
func (c *AICoderClient) AddFunction(description, newFunction, currentCode string) (GeneratedScreen, error) {
	designSpec := c.generateDesignSpec(description)
	prompt := fmt.Sprintf(addFunctionPromptTemplate, description, newFunction, designSpec, currentCode, realFunctionalityInstruction)
	return c.runPromptAcrossModels(prompt)
}

// generateDesignSpec модели алоҳидаи "тарроҳ"-ро даъват мекунад, то нақшаи
// дизайнро (ранг, чойгиршавӣ, шаффофият ва ғ.) пеш аз коднависӣ созад. Агар
// ин зина ноком шавад (масалан rate-limit), сатри холӣ бармегардад — зинаи
// коднависӣ ҳамоно бе он давом мекунад (танҳо роҳнамои иловагӣ гум мешавад,
// на худи сохтани барнома)
func (c *AICoderClient) generateDesignSpec(description string) string {
	prompt := fmt.Sprintf(designPromptTemplate, description)
	spec, err := c.runRawPromptAcrossModels(prompt)
	if err != nil {
		utils.LogError("aicoder: design step failed for %q: %v", description, err)
		return ""
	}
	return spec
}

// FixScreen вақте даъват мешавад, ки build.yml бо lib/main.dart-и
// AI-сохташуда ноком шуда бошад — матни хатогии build-ро (логи job-и
// ноком) ва коди пешинаро ба AI медиҳад, то версияи ислоҳшударо баргардонад
func (c *AICoderClient) FixScreen(description, previousCode, errorLog string) (GeneratedScreen, error) {
	prompt := fmt.Sprintf(fixPromptTemplate, description, previousCode, truncateStr(errorLog, 3000))
	return c.runPromptAcrossModels(prompt)
}

// runPromptAcrossModels як prompt-и додашударо дар якчанд модели ройгон
// паиҳам меозмояд (аввал c.model, баъд fallbackModels) — то агар яке аз
// рӯйхати ройгон хориҷ шуда бошад, натиҷа гум нашавад. Агар модел
// rate-limit шуда бошад ва вақти интизорӣ кӯтоҳ бошад, як маротиба дубора
// кӯшиш мекунад пеш аз гузаштан ба модели навбатӣ
func (c *AICoderClient) runPromptAcrossModels(prompt string) (GeneratedScreen, error) {
	raw, err := c.runRawPromptAcrossModels(prompt)
	if err != nil {
		return GeneratedScreen{}, err
	}
	return parseGeneratedScreen(raw)
}

// runRawPromptAcrossModels як prompt-и додашударо (матни хоми ҷавоб, бе
// таҳлили шакли мушаххас) дар якчанд модели ройгон паиҳам меозмояд (аввал
// c.model, баъд fallbackModels) — то агар яке аз рӯйхати ройгон хориҷ шуда
// бошад, натиҷа гум нашавад. Агар модел rate-limit шуда бошад ва вақти
// интизорӣ кӯтоҳ бошад, як маротиба дубора кӯшиш мекунад пеш аз гузаштан
// ба модели навбатӣ
func (c *AICoderClient) runRawPromptAcrossModels(prompt string) (string, error) {
	var attempts []string
	for _, model := range c.candidateModels() {
		content, err := c.callModelRaw(prompt, model)
		if err == nil {
			return content, nil
		}

		var rle *rateLimitError
		if errors.As(err, &rle) && rle.retryAfter > 0 && rle.retryAfter <= maxRateLimitWait {
			time.Sleep(rle.retryAfter)
			content, err = c.callModelRaw(prompt, model)
			if err == nil {
				return content, nil
			}
		}

		attempts = append(attempts, fmt.Sprintf("%s: %v", model, err))
	}
	return "", fmt.Errorf("all models failed — %s", strings.Join(attempts, " | "))
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

// callModelRaw як дархостро ба модели додашуда мефиристад ва матни хоми
// ҷавобро (пеш аз ҳар гуна таҳлили шакли мушаххас) бармегардонад
func (c *AICoderClient) callModelRaw(prompt, model string) (string, error) {
	payload, err := json.Marshal(map[string]interface{}{
		"model": model,
		"messages": []map[string]string{
			{"role": "user", "content": prompt},
		},
	})
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest(http.MethodPost, openRouterEndpoint, bytes.NewReader(payload))
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+c.token)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("openrouter request failed: status %d, body: %s", resp.StatusCode, truncateStr(string(body), 500))
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
		return "", fmt.Errorf("failed to parse openrouter response: %w", err)
	}
	if result.Error != nil {
		if result.Error.Metadata.RetryAfterSeconds > 0 {
			return "", &rateLimitError{
				message:    result.Error.Message,
				retryAfter: time.Duration(result.Error.Metadata.RetryAfterSeconds * float64(time.Second)),
			}
		}
		return "", fmt.Errorf("openrouter error: %s", result.Error.Message)
	}
	if len(result.Choices) == 0 {
		return "", fmt.Errorf("no choices in openrouter response")
	}

	return result.Choices[0].Message.Content, nil
}

// parseGeneratedScreen матни хоми ҷавоби модели коднависро ба GeneratedScreen мубаддал мекунад
func parseGeneratedScreen(raw string) (GeneratedScreen, error) {
	content := extractJSONObject(raw)

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
