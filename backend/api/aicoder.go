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

// GeneratedScreen се файли асосии экрани як-саҳифагии Android-ро (Kotlin + XML)
// дар бар мегирад
type GeneratedScreen struct {
	AppName         string
	MainActivityKt  string
	ActivityMainXML string
}

const screenPromptTemplate = `You generate Android Kotlin code for a minimal single-screen demo app.

Fixed package name: com.appbuilder.generated
User's app description: %s

Create exactly ONE screen (MainActivity) with exactly 5 buttons, one per major function implied by the description. Each button's onClick listener should just show a Toast with that function's name (placeholder only — no real backend, networking, or database logic; this is a scaffold the user will extend).

Respond with ONLY valid JSON, no markdown code fences, no explanation, in exactly this shape:
{"app_name": "Short App Name", "main_activity_kt": "...", "activity_main_xml": "..."}

Rules for main_activity_kt (full file content, as a single string with \n for newlines):
- package com.appbuilder.generated
- imports: androidx.appcompat.app.AppCompatActivity, android.os.Bundle, android.widget.Toast, android.widget.Button
- class MainActivity : AppCompatActivity()
- onCreate calls setContentView(R.layout.activity_main), then for each of btn1..btn5: findViewById<Button>(R.id.btnN).setOnClickListener { Toast.makeText(this, "<function name>", Toast.LENGTH_SHORT).show() }

Rules for activity_main_xml (full file content, as a single string with \n for newlines):
- root LinearLayout, xmlns:android, orientation="vertical", layout_width/height="match_parent", padding="16dp"
- exactly 5 Button elements with android:id="@+id/btn1" through "@+id/btn5", each with a descriptive android:text matching one function`

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
		AppName         string `json:"app_name"`
		MainActivityKt  string `json:"main_activity_kt"`
		ActivityMainXML string `json:"activity_main_xml"`
	}
	if err := json.Unmarshal([]byte(content), &screen); err != nil {
		return GeneratedScreen{}, fmt.Errorf("failed to parse generated screen JSON: %w (raw: %s)", err, truncateStr(content, 300))
	}
	if screen.MainActivityKt == "" || screen.ActivityMainXML == "" {
		return GeneratedScreen{}, fmt.Errorf("generated screen missing required fields")
	}

	return GeneratedScreen{
		AppName:         screen.AppName,
		MainActivityKt:  screen.MainActivityKt,
		ActivityMainXML: screen.ActivityMainXML,
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
