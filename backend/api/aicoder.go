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

// dartOutputFormat — формати ЯГОНАИ ҷавоб барои ҳамаи дархостҳои коднависӣ.
// Ба ҷои JSON (ки коди калонро escape кардан лозим буду зуд-зуд вайрон
// мешуд) модел коди ХОМ-ро байни ду ҷудокунанда менависад — escape лозим
// нест, пас ҷавоб хеле боэътимодтар таҳлил (parse) мешавад
const dartOutputFormat = `

Output format — reply with EXACTLY this and NOTHING else. No JSON, no markdown, no backticks, no code fences, no explanation before or after:
APP_NAME: <a short app name>
===DART_BEGIN===
<the full raw source code of lib/main.dart, written normally with real line breaks — do NOT escape characters, do NOT wrap it in quotes or code fences, just the plain Dart code>
===DART_END===`

// fullAppPromptTemplate — генератори MVP-и ПУРРА. Агар корбар номи як
// барномаи машҳурро гӯяд (Instagram, TikTok, CapCut, WhatsApp ва ғ.), MVP-и
// УМУМИИ ҳамон НАВъи барномаро бо ҳамаи экранҳои асосиаш месозад — вале бе
// логотип/ном/ранги бренди воқеӣ ва бе даъвои "ин ҳамон барнома аст" (то
// мушкили trademark набошад). Ҳанӯз 1 файл (lib/main.dart), то системаи
// мавҷудаи push/build/fix бе тағйир кор кунад
const fullAppPromptTemplate = `You generate a COMPLETE, realistic Flutter MVP app in a single lib/main.dart file. It must look and feel like a real, finished app with several connected screens — not a single demo screen.

User's app description: %s

Design specification from the design step — follow it for colors, spacing, elevation, corners, and icon tone (if empty, use your own best judgment): %s

Build a proper MVP of the app the user described:
- If the description names or resembles a well-known app, build a GENERIC MVP of that TYPE of app with its standard screens/features. IMPORTANT: do NOT use the real brand's name, logo, exact brand colors, or claim to be that app — this is the user's own app with the name they chose. Just replicate the common feature set of that category. Typical feature sets by category:
  * Social photo-sharing (Instagram-like): Home feed of posts (avatar + username, image placeholder, like/comment/share row, caption), a horizontal Stories bar at the top of Home, an Explore/Search grid of images, a vertical short-video/Reels screen, an Activity/Notifications list, a Direct-messages/chat list, a Profile screen with stats and a photo grid.
  * Short video (TikTok-like): a vertical full-screen video feed (PageView), Discover/search, a big center "+" create button, an Inbox, a Profile.
  * Video/photo editor (CapCut-like): a Projects list with a "New Project" button, an Editor screen showing a preview area + a timeline + a horizontal tool row (Trim/Split, Text, Effects, Filters, Audio, Stickers, Speed, Transitions), an AI-tools screen (e.g. AI cutout, auto captions, enhance — as buttons), and an Export screen with resolution options.
  * Chat/messaging (WhatsApp-like): a Chats list (avatar, name, last message, time), a Chat screen (message bubbles + input bar), Contacts, Calls, Settings.
  * Shopping/store: product grid, product detail, cart, orders, profile.
  * Otherwise: infer the 4-6 screens a real app of this kind would have.
- Build 3 to 5 screens. Connect the primary ones with a BottomNavigationBar; open secondary screens (e.g. a chat, a product detail, the editor) via Navigator.push from taps. Keep each screen's code compact but realistic so the whole file stays complete and not truncated.
- EVERY screen must be populated with a few sample/seed items from local Dart lists (sample posts, sample chats, sample products, a real-looking editor timeline + tool buttons) so it looks complete — never an empty "coming soon" placeholder.

%s

Rules for the Dart file (a COMPLETE, valid, self-contained lib/main.dart compiling with the standard Flutter SDK; allowed imports only: "package:flutter/material.dart", "package:flutter_feather_icons/flutter_feather_icons.dart", "package:http/http.dart" as http, and "dart:convert" if needed; every screen a private class in this same file):
- import 'package:flutter/material.dart';
- import 'package:flutter_feather_icons/flutter_feather_icons.dart';
- Prefer Feather icons, but use ONLY names that exist in the package. Use ONLY names from this verified list: FeatherIcons.home, user, users, userPlus, search, settings, plus, plusCircle, minus, edit, edit2, edit3, trash2, heart, star, bell, mail, messageCircle, messageSquare, send, camera, image, video, film, music, headphones, mic, map, mapPin, navigation, compass, calendar, clock, shoppingCart, shoppingBag, dollarSign, creditCard, tag, gift, download, upload, share2, play, pause, playCircle, pauseCircle, skipForward, skipBack, menu, grid, list, filter, sliders, check, checkCircle, x, xCircle, phone, phoneCall, bookmark, folder, file, fileText, book, bookOpen, globe, wifi, lock, unlock, eye, eyeOff, sun, moon, refreshCw, arrowRight, arrowLeft, chevronRight, chevronLeft, moreVertical, moreHorizontal, thumbsUp, award, zap, activity, barChart2, pieChart, trendingUp, coffee, briefcase, truck, package, cpu, database, server, cloud, logOut, logIn, volume2, repeat, shuffle. If none fits, use a Material Icons.<name> instead (Material icons always exist). Never invent a FeatherIcons name not in this list.
- void main() => runApp(const MyApp());
- MyApp: MaterialApp with useMaterial3: true, theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: <a fitting color>), useMaterial3: true), home MyHomePage.
- MyHomePage: StatefulWidget holding the selected tab index; Scaffold with body: IndexedStack(index: _selectedIndex, children: [...main tab screens...]) and bottomNavigationBar: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), type: BottomNavigationBarType.fixed, items: [...]).
- Each tab and each secondary screen is its own private widget class with a realistic body (ListView/GridView/PageView of sample data, cards, avatars, forms, timelines — whatever fits).
- Use CircleAvatar with a background color + initials or a FeatherIcons icon for avatars, and a Container with a colored/gradient box (with an icon centered) for image/video placeholders — do NOT load network images.
- CRITICAL: the file MUST compile as one valid Dart file. If a screen gets too complex, simplify it — a slightly simpler screen that builds beats a rich one that doesn't. Never reference an undefined name, icon, or API.` + dartOutputFormat

const fixPromptTemplate = `The following Flutter/Dart lib/main.dart failed to build in GitHub Actions ("flutter build apk"). Your ONLY goal now is to make it COMPILE and build successfully. Getting a working APK matters more than any styling detail — it is completely fine to simplify or drop a problematic widget/feature if that is what it takes to build.

Original app description: %s

Previous lib/main.dart:
%s

Build error log (tail):
%s

Read the ACTUAL error(s) in the log above and fix their real cause. Common causes and how to fix them:
- "The getter '<X>' isn't defined for the type 'FeatherIcons'" or any undefined FeatherIcons name → that Feather icon name does not exist. Replace ONLY those icons with a standard Material icon: use Icons.<name> from 'package:flutter/material.dart' (Material icons always exist). It is OK to mix: keep valid FeatherIcons.<name> where they work, and use Icons.<name> where a Feather name was invalid. When unsure, prefer Icons.<name>.
- "isn't defined" / "not a function" / "too many positional arguments" → a wrong or nonexistent API; replace it with a correct standard Flutter API or remove that call.
- "Undefined name" / missing import → add the needed import (only from the allowed list) or remove the reference.
- const / final / type errors → fix the type or drop the const.
- A broken network call (http) → wrap correctly with async/await + try/catch, or if it is the cause and can't be fixed simply, replace that action with a SnackBar placeholder.

Return the FULL corrected content of lib/main.dart — a complete, self-contained Dart file that WILL compile. Allowed imports only: 'package:flutter/material.dart', 'package:flutter_feather_icons/flutter_feather_icons.dart', 'package:http/http.dart' as http, and 'dart:convert'. Do not leave any reference to an undefined name, icon, or API.` + dartOutputFormat

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

Return the FULL updated content of lib/main.dart — still a complete, self-contained Dart file. Allowed imports: 'package:flutter/material.dart', 'package:flutter_feather_icons/flutter_feather_icons.dart', 'package:http/http.dart' as http, and 'dart:convert'. Keep using FeatherIcons.<name> for icons (never invent a Feather name; if unsure use Material Icons.<name>).` + dartOutputFormat

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

// GenerateFullApp тавсифи озоди корбарро мегирад ва MVP-и пурраи Flutter-ро
// (якчанд экран, genre-aware) ҳамчун lib/main.dart тавассути OpenRouter
// мебарорад. Якчанд модели ройгон паиҳам озмуда мешаванд (аввал c.model,
// баъд fallbackModels) — то агар яке аз рӯйхати ройгон хориҷ шуда бошад,
// натиҷа гум нашавад. Агар модел rate-limit шуда бошад ва вақти интизорӣ
// кӯтоҳ бошад, як маротиба дубора кӯшиш мекунад пеш аз гузаштан ба модели навбатӣ
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
	// ТАЙЛи логро мегирем, на аввалашро — хатои воқеии Dart дар охири лог
	// (қадами "Build APK") аст, на дар қадамҳои setup дар аввал
	prompt := fmt.Sprintf(fixPromptTemplate, description, previousCode, tailStr(errorLog, 6000))
	return c.runPromptAcrossModels(prompt)
}

// chatSystemPrompt — дастури модели муошират (на коднавис). Бо ҳамон забони
// корбар ҷавоби кӯтоҳу дӯстона медиҳад
const chatSystemPrompt = `You are a friendly, helpful AI assistant inside a Telegram bot. Answer the user's message helpfully and in the SAME language they wrote in (Tajik, Russian, English, etc.). Keep replies concise and conversational, suitable for a chat. You can help brainstorm app ideas, answer questions, explain things, translate, and chat generally.`

// Chat як паёми озоди корбарро мегирад ва ҷавоби AI-ро (муошират, на код)
// бармегардонад. Аз ҳамон рӯйхати моделҳои ройгон бо fallback истифода мебарад
func (c *AICoderClient) Chat(userMessage string) (string, error) {
	prompt := chatSystemPrompt + "\n\nUser message:\n" + userMessage + "\n\nYour reply (same language as the user, concise):"
	reply, err := c.runRawPromptAcrossModels(prompt)
	if err != nil {
		return "", err
	}
	reply = strings.TrimSpace(reply)
	if reply == "" {
		return "", fmt.Errorf("empty chat reply")
	}
	return reply, nil
}

// runPromptAcrossModels як prompt-и додашударо дар якчанд модели ройгон
// паиҳам меозмояд (аввал c.model, баъд fallbackModels) — то агар яке аз
// рӯйхати ройгон хориҷ шуда бошад, натиҷа гум нашавад. Агар модел
// rate-limit шуда бошад ва вақти интизорӣ кӯтоҳ бошад, як маротиба дубора
// кӯшиш мекунад пеш аз гузаштан ба модели навбатӣ
func (c *AICoderClient) runPromptAcrossModels(prompt string) (GeneratedScreen, error) {
	var attempts []string
	for _, model := range c.candidateModels() {
		content, err := c.callModelRaw(prompt, model)
		if err != nil {
			var rle *rateLimitError
			if errors.As(err, &rle) && rle.retryAfter > 0 && rle.retryAfter <= maxRateLimitWait {
				time.Sleep(rle.retryAfter)
				content, err = c.callModelRaw(prompt, model)
			}
		}
		if err != nil {
			attempts = append(attempts, fmt.Sprintf("%s: %v", model, err))
			continue
		}
		// Агар ин модел натиҷаи вайрон/нопурра диҳад, ба модели навбатӣ
		// мегузарем (на фавран ноком мешавем) — ин боэътимодиро зиёд мекунад
		screen, perr := parseGeneratedScreen(content)
		if perr != nil {
			attempts = append(attempts, fmt.Sprintf("%s: parse: %v", model, perr))
			continue
		}
		return screen, nil
	}
	return GeneratedScreen{}, fmt.Errorf("all models failed — %s", strings.Join(attempts, " | "))
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
		// MVP-и якчандэкрана output-и калон мехоҳад, вале max_tokens-и хеле
		// баланд (масалан 16000) аз ҷониби баъзе моделҳои ройгон рад мешавад
		// ("too large") — 8000 аз ҷониби ҳамаи моделҳои асосӣ қабул мешавад
		// ва барои MVP-и 3-5 экрана кофист
		"max_tokens": 8000,
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

// parseGeneratedScreen ҷавоби формати "APP_NAME: ...\n===DART_BEGIN===\n
// <код>\n===DART_END===" (формати боэътимоди мо, на JSON)-ро таҳлил мекунад.
// Барои моделҳое, ки формат риоя накунанд, chandin fallback ҳаст, вале агар
// коди воқеии Dart наёбад, хато медиҳад — то runPromptAcrossModels ба модели
// дигар гузарад
func parseGeneratedScreen(raw string) (GeneratedScreen, error) {
	appName := ""
	if idx := strings.Index(raw, "APP_NAME:"); idx >= 0 {
		rest := raw[idx+len("APP_NAME:"):]
		if nl := strings.IndexAny(rest, "\r\n"); nl >= 0 {
			appName = strings.TrimSpace(rest[:nl])
		} else {
			appName = strings.TrimSpace(rest)
		}
	}

	dart := ""
	begin := strings.Index(raw, "===DART_BEGIN===")
	end := strings.LastIndex(raw, "===DART_END===")
	switch {
	case begin >= 0 && end > begin:
		dart = raw[begin+len("===DART_BEGIN===") : end]
	case begin >= 0:
		// маркери END нест — ҷавоб буридаву нопурра аст; хато то модели дигар
		return GeneratedScreen{}, fmt.Errorf("response truncated (no DART_END marker, %d chars)", len(raw))
	default:
		// модел форматро риоя накард — коди Dart-ро аз худи матн ёфта мебарорем
		dart = salvageDart(raw)
	}

	dart = strings.TrimSpace(dart)
	dart = strings.TrimPrefix(dart, "```dart")
	dart = strings.TrimPrefix(dart, "```")
	dart = strings.TrimSuffix(dart, "```")
	dart = strings.TrimSpace(dart)

	if !strings.Contains(dart, "void main(") || !strings.Contains(dart, "import 'package:flutter/material.dart'") {
		return GeneratedScreen{}, fmt.Errorf("no valid Flutter Dart found in model output (%d chars)", len(dart))
	}
	if appName == "" {
		appName = "My App"
	}
	return GeneratedScreen{AppName: appName, MainDart: dart}, nil
}

// salvageDart вақте истифода мешавад, ки модел форматро риоя накарда бошад —
// коди Dart-ро аз худи матн (аз аввалин "import 'package:flutter" ё "void
// main") то охир мебарорад, ва fence-ҳои ```-ро тоза мекунад
func salvageDart(raw string) string {
	s := raw
	if i := strings.Index(s, "import 'package:flutter/material.dart'"); i >= 0 {
		s = s[i:]
	} else if i := strings.Index(s, "void main("); i >= 0 {
		s = s[i:]
	}
	if i := strings.LastIndex(s, "```"); i >= 0 {
		// матни баъд аз блоки код-ро бурида партоем
		s = s[:i]
	}
	return s
}

func truncateStr(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "..."
}

// tailStr n аломати ОХИРи сатрро бармегардонад — барои логи build, ки
// хатои аслӣ дар охираш аст
func tailStr(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return "..." + s[len(s)-n:]
}
