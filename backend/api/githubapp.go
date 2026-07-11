package api

import (
	"archive/zip"
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"sync"
	"time"

	"anime-bot/backend/utils"
)

const githubAPIBase = "https://api.github.com"

// flutterAutoCreateWorkflow скелети пурраи Flutter-ро (агар набошад) месозад
// ва ФАВРАН ба репо commit мекунад — то pubspec.yaml/android/ios ва ғ. дар
// худи репо боқӣ монад, на ҳар дафъа аз нав дар ичрокунандаи муваққатии
// GitHub Actions сохта шавад. Ин workflow пеш аз ҳар коднависии AI ва пеш
// аз build.yml push ва иҷро карда мешавад (дар FinalizeAppSetup). Танҳо бо
// workflow_dispatch оғоз мешавад (на бо push) — то ҳамеша бо app_name-и
// дурусти корбар (аз input) иҷро шавад, на бо номи пешфарз
const flutterAutoCreateWorkflow = `name: Auto Create Flutter Project

on:
  workflow_dispatch:
    inputs:
      app_name:
        description: 'App display name'
        required: false
        default: 'Flutter App'

permissions:
  contents: write

jobs:
  create_flutter:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Create Flutter project if missing
        run: |
          if [ ! -f "pubspec.yaml" ]; then
            PROJECT_NAME=$(basename "$GITHUB_REPOSITORY" | tr '-' '_')
            flutter create --project-name "$PROJECT_NAME" .
          else
            echo "Flutter project already exists."
          fi

      - name: Set app display name
        run: |
          APP_NAME="${{ github.event.inputs.app_name }}"
          if [ -z "$APP_NAME" ]; then
            APP_NAME="Flutter App"
          fi
          if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
            sed -i "s/android:label=\"[^\"]*\"/android:label=\"$APP_NAME\"/" android/app/src/main/AndroidManifest.xml
          fi

      - name: Ensure INTERNET permission (release builds need it explicitly)
        run: |
          MANIFEST="android/app/src/main/AndroidManifest.xml"
          if [ -f "$MANIFEST" ] && ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
            sed -i '/<manifest/a\    <uses-permission android:name="android.permission.INTERNET"/>' "$MANIFEST"
          fi

      - name: Generate app icon if provided
        run: |
          if [ -f "assets/icon/icon.png" ]; then
            flutter pub add --dev flutter_launcher_icons
            {
              echo 'flutter_launcher_icons:'
              echo '  android: "launcher_icon"'
              echo '  ios: true'
              echo '  image_path: "assets/icon/icon.png"'
            } >> pubspec.yaml
            dart run flutter_launcher_icons
          fi

      - name: Commit and Push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

          git add .

          if git diff --cached --quiet; then
            echo "No changes"
          else
            git commit -m "Auto create Flutter project"
            git push
          fi
`

// flutterBuildWorkflow workflow-и GitHub Actions барои лоиҳаи Flutter.
// Агар pubspec.yaml вуҷуд надошта бошад (репои нав), "flutter create ."
// худкор скелети пурраи лоиҳаро месозад (ин ҳамеша дуруст build мешавад,
// чун худи Flutter месозад, на AI) — файлҳои мавҷуда (масалан lib/main.dart-и
// AI-сохташуда, агар пеш аз ин push шуда бошад) аз ҷониби "flutter create"
// рӯй гардонда намешаванд, танҳо чизҳои норасида илова мешаванд
const flutterBuildWorkflow = `name: Build APK

on:
  push:
    branches: [ main, master ]
  workflow_dispatch: {}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Create Flutter project if missing
        run: |
          if [ ! -f "pubspec.yaml" ]; then
            PROJECT_NAME=$(basename "$GITHUB_REPOSITORY" | tr '-' '_')
            flutter create --project-name "$PROJECT_NAME" .
          fi

      - name: Ensure Feather icons dependency
        run: flutter pub add flutter_feather_icons

      - name: Ensure http dependency (for functions with real network calls)
        run: flutter pub add http

      - name: Get dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/*.apk
`

// GitHubAppClient ба GitHub REST API пайваст мешавад — репо месозад,
// workflow-и build-и APK-ро илова мекунад, ва баъдтар artifact-и
// сохташударо (APK) мегирад. Токен (Personal Access Token, доираи "repo")
// аз ҷониби соҳиби бот тавассути Environment Variable дода мешавад
type GitHubAppClient struct {
	http  *http.Client
	token string

	mu    sync.Mutex
	owner string
}

// NewGitHubAppClient client-и нав месозад. Агар token холӣ бошад, Enabled()
// false бармегардонад ва хусусияти App Builder ғайрифаъол мемонад
func NewGitHubAppClient(token string) *GitHubAppClient {
	return &GitHubAppClient{
		http:  &http.Client{Timeout: 30 * time.Second},
		token: token,
	}
}

// Enabled нишон медиҳад, ки оё токен танзим шудааст
func (c *GitHubAppClient) Enabled() bool {
	return c.token != ""
}

func (c *GitHubAppClient) doRequest(method, path string, body []byte) ([]byte, int, error) {
	var reader io.Reader
	if body != nil {
		reader = bytes.NewReader(body)
	}
	req, err := http.NewRequest(method, githubAPIBase+path, reader)
	if err != nil {
		return nil, 0, err
	}
	req.Header.Set("Authorization", "Bearer "+c.token)
	req.Header.Set("Accept", "application/vnd.github+json")
	req.Header.Set("X-GitHub-Api-Version", "2022-11-28")
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}

	resp, err := c.http.Do(req)
	if err != nil {
		return nil, 0, err
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, 0, err
	}
	return respBody, resp.StatusCode, nil
}

// CreateOrGetUserRepo репои бо номи собити ба telegramID вобастаро месозад
// (масалан "app-user-6822119590"), то ҳар корбар ҳамеша ба ҳамон як номи
// репо расад — новобаста аз он ки тавсифаш чӣ буд. Агар репо аллакай вуҷуд
// дошта бошад (масалан агар пойгоҳи додаҳои SQLite-и мо аз сабаби деплой
// пок шуда бошад, вале худи репо дар GitHub монда бошад), ба ҷои хатогии
// "номи такрорӣ", маълумоти ҳамон репои мавҷударо мегирад — то ҳеҷ гоҳ
// беасос ноком нашавад. isNew нишон медиҳад, ки оё репо ҳозир аввалин бор сохта шуд
func (c *GitHubAppClient) CreateOrGetUserRepo(telegramID int64, appName string) (fullName string, htmlURL string, isNew bool, err error) {
	repoName := fmt.Sprintf("app-user-%d", telegramID)

	payload, _ := json.Marshal(map[string]interface{}{
		"name":        repoName,
		"description": fmt.Sprintf("App scaffold: %s", appName),
		"private":     false,
		"auto_init":   true,
	})

	body, status, err := c.doRequest(http.MethodPost, "/user/repos", payload)
	if err != nil {
		return "", "", false, fmt.Errorf("failed to create repo: %w", err)
	}

	if status == http.StatusUnprocessableEntity && strings.Contains(string(body), "already exists") {
		owner, ownerErr := c.CurrentOwner()
		if ownerErr != nil {
			return "", "", false, fmt.Errorf("repo already exists but failed to resolve owner: %w", ownerErr)
		}
		full, url, getErr := c.getRepo(owner, repoName)
		if getErr != nil {
			return "", "", false, fmt.Errorf("repo already exists but failed to fetch it: %w", getErr)
		}

		// Ҳатто барои репои мавҷуда низ workflow-ҳоро бо нусхаи ҲОЗИРА иваз
		// мекунем — вагарна корбароне, ки репояшон қаблан сохта шудааст,
		// ҳамеша бо версияи кӯҳнаи workflow (бо баги эҳтимолӣ) кор мекунанд,
		// ҳатто пас аз ислоҳи мо дар код
		if err := c.PushFile(full, ".github/workflows/auto-create.yml", "Update auto-create Flutter workflow", flutterAutoCreateWorkflow); err != nil {
			utils.LogError("githubapp: failed to update auto-create workflow for existing repo %s: %v", full, err)
		}
		if err := c.PushFile(full, ".github/workflows/build.yml", "Update Flutter APK build workflow", flutterBuildWorkflow); err != nil {
			utils.LogError("githubapp: failed to update build workflow for existing repo %s: %v", full, err)
		}

		return full, url, false, nil
	}

	if status != http.StatusCreated {
		return "", "", false, fmt.Errorf("failed to create repo: status %d, body: %s", status, string(body))
	}

	var repo struct {
		FullName string `json:"full_name"`
		HTMLURL  string `json:"html_url"`
		Owner    struct {
			Login string `json:"login"`
		} `json:"owner"`
	}
	if err := json.Unmarshal(body, &repo); err != nil {
		return "", "", false, fmt.Errorf("failed to parse create-repo response: %w", err)
	}

	c.mu.Lock()
	c.owner = repo.Owner.Login
	c.mu.Unlock()

	// GitHub-ро як лаҳза интизор мешавем, то репои нав (ки ҳозир бо auto_init
	// сохта шуд) пеш аз навиштани файли дигар пурра омода шавад
	time.Sleep(2 * time.Second)

	if err := c.PushFile(repo.FullName, ".github/workflows/auto-create.yml", "Add auto-create Flutter workflow", flutterAutoCreateWorkflow); err != nil {
		return repo.FullName, repo.HTMLURL, true, fmt.Errorf("repo created but failed to add auto-create workflow: %w", err)
	}
	if err := c.PushFile(repo.FullName, ".github/workflows/build.yml", "Add Flutter APK build workflow", flutterBuildWorkflow); err != nil {
		return repo.FullName, repo.HTMLURL, true, fmt.Errorf("repo created but failed to add build workflow: %w", err)
	}

	return repo.FullName, repo.HTMLURL, true, nil
}

// FinalizeAppSetup баъд аз CreateOrGetUserRepo даъват мешавад — пеш аз ҳар
// коднависии AI. Агар logoBytes холӣ набошад, ҳамчун иконка push мешавад;
// баъд auto-create.yml тавассути workflow_dispatch бо app_name-и дурусти
// корбар оғоз мешавад (то скелети Flutter ва ном/иконка commit шаванд), ва
// дар охир build.yml низ оғоз мешавад — то ҳатто агар AI баъдтар коде
// илова накунад (масалан токен нодуруст бошад), як APK-и оддӣ омода шавад
func (c *GitHubAppClient) FinalizeAppSetup(fullName, displayName string, logoBytes []byte) error {
	if len(logoBytes) > 0 {
		if err := c.PushFile(fullName, "assets/icon/icon.png", "Add app icon", string(logoBytes)); err != nil {
			utils.LogError("githubapp: failed to push app icon for %s: %v", fullName, err)
		}
	}

	// МУҲИМ: GitHub Actions худи commit-е, ки workflow-ро аввалин бор
	// илова мекунад, фаъол намекунад (маҳдудияти худи GitHub, на бағи мо).
	// Барои ҳамин ҳамеша мустақим тавассути workflow_dispatch оғоз мекунем —
	// то скелети Flutter (ва ном/иконка) ҳатман commit шавад, пеш аз он ки
	// build.yml ё коди AI илова шавад
	time.Sleep(2 * time.Second)
	if err := c.TriggerWorkflow(fullName, "auto-create.yml", map[string]string{"app_name": displayName}); err != nil {
		return fmt.Errorf("failed to trigger auto-create workflow: %w", err)
	}

	time.Sleep(2 * time.Second)
	if err := c.TriggerWorkflow(fullName, "build.yml", nil); err != nil {
		utils.LogError("githubapp: failed to trigger initial build workflow run for %s: %v", fullName, err)
	}

	return nil
}

// TriggerWorkflow workflow-и додашударо (масалан "build.yml" ё
// "auto-create.yml") тавассути workflow_dispatch оғоз мекунад. inputs
// метавонад nil бошад, агар workflow input лозим надошта бошад
func (c *GitHubAppClient) TriggerWorkflow(fullName, workflowFile string, inputs map[string]string) error {
	payloadMap := map[string]interface{}{"ref": "main"}
	if len(inputs) > 0 {
		payloadMap["inputs"] = inputs
	}
	payload, _ := json.Marshal(payloadMap)
	path := fmt.Sprintf("/repos/%s/actions/workflows/%s/dispatches", fullName, workflowFile)
	body, status, err := c.doRequest(http.MethodPost, path, payload)
	if err != nil {
		return err
	}
	if status != http.StatusNoContent {
		return fmt.Errorf("failed to dispatch workflow: status %d, body: %s", status, string(body))
	}
	return nil
}

// TransferRepo дархости кӯчонидани моликияти репоро ба корбари дигари
// GitHub (масалан худи соҳиби барнома) мефиристад. Агар newOwner account-и
// шахсӣ бошад (на ташкилот), GitHub интизори тасдиқи ӯ мемонад — кӯчонидан
// фавран тамом намешавад. Пас аз тасдиқ, токени бот дигар ба ин репо
// дастрасӣ надорад (агар корбар онро ба ҳайси collaborator илова накунад)
func (c *GitHubAppClient) TransferRepo(fullName, newOwner string) error {
	payload, _ := json.Marshal(map[string]interface{}{"new_owner": newOwner})
	path := fmt.Sprintf("/repos/%s/transfer", fullName)
	body, status, err := c.doRequest(http.MethodPost, path, payload)
	if err != nil {
		return err
	}
	if status != http.StatusAccepted && status != http.StatusOK {
		return fmt.Errorf("failed to transfer repo: status %d, body: %s", status, string(body))
	}
	return nil
}

// getRepo маълумоти репои мавҷударо (full_name, html_url) мегирад
func (c *GitHubAppClient) getRepo(owner, repoName string) (fullName string, htmlURL string, err error) {
	body, status, err := c.doRequest(http.MethodGet, fmt.Sprintf("/repos/%s/%s", owner, repoName), nil)
	if err != nil {
		return "", "", err
	}
	if status != http.StatusOK {
		return "", "", fmt.Errorf("failed to fetch repo: status %d, body: %s", status, string(body))
	}
	var repo struct {
		FullName string `json:"full_name"`
		HTMLURL  string `json:"html_url"`
	}
	if err := json.Unmarshal(body, &repo); err != nil {
		return "", "", err
	}
	return repo.FullName, repo.HTMLURL, nil
}

// PushFile як файли ягонаро дар репо месозад/навсозӣ мекунад (тавассути
// GitHub Contents API)
func (c *GitHubAppClient) PushFile(fullName, path, message, content string) error {
	apiPath := fmt.Sprintf("/repos/%s/contents/%s", fullName, path)

	payloadMap := map[string]interface{}{
		"message": message,
		"content": base64.StdEncoding.EncodeToString([]byte(content)),
	}

	// GitHub Contents API-и PUT ҳангоми НАВСОЗИИ файли МАВҶУДА "sha"-и
	// нусхаи ҳозираро талаб мекунад (вагарна 422 "sha" wasn't supplied
	// медиҳад). Азбаски ҳар корбар танҳо 1 репо дорад ва лоиҳаро борҳо
	// навсозӣ карда метавонад, lib/main.dart метавонад аллакай вуҷуд дошта
	// бошад — пас аввал sha-и мавҷударо мегирем (агар файл нав бошад, ин
	// 404 медиҳад ва sha холӣ мемонад, ки барои сохтани файли нав дуруст аст)
	if sha, err := c.getFileSHA(fullName, path); err == nil && sha != "" {
		payloadMap["sha"] = sha
	}

	payload, _ := json.Marshal(payloadMap)

	body, status, err := c.doRequest(http.MethodPut, apiPath, payload)
	if err != nil {
		return err
	}
	if status != http.StatusCreated && status != http.StatusOK {
		return fmt.Errorf("failed to push file %q: status %d, body: %s", path, status, string(body))
	}
	return nil
}

// getFileSHA sha-и blob-и файли ҳозираро мегирад (агар мавҷуд бошад).
// Агар файл вуҷуд надошта бошад (404), sha холӣ бе хато бармегардад
func (c *GitHubAppClient) getFileSHA(fullName, path string) (string, error) {
	apiPath := fmt.Sprintf("/repos/%s/contents/%s", fullName, path)
	body, status, err := c.doRequest(http.MethodGet, apiPath, nil)
	if err != nil {
		return "", err
	}
	if status == http.StatusNotFound {
		return "", nil
	}
	if status != http.StatusOK {
		return "", fmt.Errorf("failed to get file sha for %q: status %d", path, status)
	}
	var result struct {
		SHA string `json:"sha"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", err
	}
	return result.SHA, nil
}

// GetFileContent матни (decoded) файли додашударо аз репо мегирад
func (c *GitHubAppClient) GetFileContent(fullName, path string) (string, error) {
	apiPath := fmt.Sprintf("/repos/%s/contents/%s", fullName, path)
	body, status, err := c.doRequest(http.MethodGet, apiPath, nil)
	if err != nil {
		return "", err
	}
	if status != http.StatusOK {
		return "", fmt.Errorf("failed to get file content for %q: status %d", path, status)
	}
	var result struct {
		Content string `json:"content"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", err
	}
	raw := strings.ReplaceAll(result.Content, "\n", "")
	decoded, err := base64.StdEncoding.DecodeString(raw)
	if err != nil {
		return "", err
	}
	return string(decoded), nil
}

var androidLabelRe = regexp.MustCompile(`android:label="([^"]*)"`)

// GetCurrentAppName номи намоишии ҳозираи барномаро (android:label дар
// AndroidManifest.xml, ки дар репо ҳамчун манбаи ягонаи ҳақиқат нигоҳ
// дошта мешавад — на дар SQLite-и мо, ки бо ҳар деплой пок мешавад) мегирад.
// Барои таҳрирҳое (масалан танҳо тағйир додани тавсиф ё логотип) лозим аст,
// ки номи кӯҳна набояд гум шавад
func (c *GitHubAppClient) GetCurrentAppName(fullName string) (string, error) {
	content, err := c.GetFileContent(fullName, "android/app/src/main/AndroidManifest.xml")
	if err != nil {
		return "", err
	}
	m := androidLabelRe.FindStringSubmatch(content)
	if len(m) < 2 || m[1] == "" {
		return "", fmt.Errorf("android:label not found in AndroidManifest.xml")
	}
	return m[1], nil
}

// GetLatestRunID ID-и охирин (навтарин) run-и як workflow-и додашударо
// мегирад (масалан "build.yml") — то баъд аз workflow_dispatch (ки худаш
// ID бармегардонад) вазъи ҳамон run-ро пайгирӣ кунем
func (c *GitHubAppClient) GetLatestRunID(fullName, workflowFile string) (int64, error) {
	path := fmt.Sprintf("/repos/%s/actions/workflows/%s/runs?per_page=1", fullName, workflowFile)
	body, status, err := c.doRequest(http.MethodGet, path, nil)
	if err != nil {
		return 0, err
	}
	if status != http.StatusOK {
		return 0, fmt.Errorf("failed to list workflow runs: status %d, body: %s", status, string(body))
	}
	var result struct {
		WorkflowRuns []struct {
			ID int64 `json:"id"`
		} `json:"workflow_runs"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return 0, err
	}
	if len(result.WorkflowRuns) == 0 {
		return 0, fmt.Errorf("no workflow runs found yet")
	}
	return result.WorkflowRuns[0].ID, nil
}

// getRunStatus вазъи ҳозираи як run-ро мегирад ("queued"/"in_progress"/"completed")
// ва conclusion-ашро (агар тамом шуда бошад — "success"/"failure"/...)
func (c *GitHubAppClient) getRunStatus(fullName string, runID int64) (status, conclusion string, err error) {
	path := fmt.Sprintf("/repos/%s/actions/runs/%d", fullName, runID)
	body, code, err := c.doRequest(http.MethodGet, path, nil)
	if err != nil {
		return "", "", err
	}
	if code != http.StatusOK {
		return "", "", fmt.Errorf("failed to get run status: status %d, body: %s", code, string(body))
	}
	var result struct {
		Status     string `json:"status"`
		Conclusion string `json:"conclusion"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", "", err
	}
	return result.Status, result.Conclusion, nil
}

// WaitForRunCompletion то тамом шудани run-и додашуда мунтазир мешавад
// (интихобан то timeout), ҳар pollInterval як бор вазъро месанҷад. conclusion
// ("success", "failure" ва ғ.) баргардонда мешавад. Агар аз timeout гузашт
// ва ҳанӯз тамом нашуда бошад, хатогӣ бармегардад
func (c *GitHubAppClient) WaitForRunCompletion(fullName string, runID int64, timeout, pollInterval time.Duration) (string, error) {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		status, conclusion, err := c.getRunStatus(fullName, runID)
		if err != nil {
			return "", err
		}
		if status == "completed" {
			return conclusion, nil
		}
		time.Sleep(pollInterval)
	}
	return "", fmt.Errorf("timed out waiting for run %d to complete", runID)
}

// GetRunFailureLog барои run-и ноком, лог(ҳо)-и job-ҳои ноком (то ҳадде
// кӯтоҳшуда)-ро мегирад — барои ба AI фиристодан то хатогиро ислоҳ кунад
func (c *GitHubAppClient) GetRunFailureLog(fullName string, runID int64) (string, error) {
	path := fmt.Sprintf("/repos/%s/actions/runs/%d/jobs", fullName, runID)
	body, status, err := c.doRequest(http.MethodGet, path, nil)
	if err != nil {
		return "", err
	}
	if status != http.StatusOK {
		return "", fmt.Errorf("failed to list jobs: status %d, body: %s", status, string(body))
	}
	var result struct {
		Jobs []struct {
			ID         int64  `json:"id"`
			Conclusion string `json:"conclusion"`
		} `json:"jobs"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", err
	}

	var logs strings.Builder
	for _, job := range result.Jobs {
		if job.Conclusion != "failure" {
			continue
		}
		logPath := fmt.Sprintf("/repos/%s/actions/jobs/%d/logs", fullName, job.ID)
		logBody, logStatus, err := c.doRequest(http.MethodGet, logPath, nil)
		if err != nil || logStatus != http.StatusOK {
			continue
		}
		logs.Write(logBody)
		logs.WriteString("\n")
	}
	if logs.Len() == 0 {
		return "", fmt.Errorf("no failed job logs found")
	}
	return logs.String(), nil
}

// PushFlutterScreen танҳо lib/main.dart-и AI-сохташударо ба репо мебарорад.
// Дигар файлҳои лоиҳаи Flutter (pubspec.yaml, android/, ios/ ва ғ.) лозим
// нестанд — вақте workflow иҷро мешавад, "flutter create ." онҳоро худкор
// месозад, бе рӯй гардондани lib/main.dart-и мавҷуда (чун файл аллакай ҳаст)
func (c *GitHubAppClient) PushFlutterScreen(fullName string, screen GeneratedScreen) error {
	if err := c.PushFile(fullName, "lib/main.dart", "Add generated app screen", screen.MainDart); err != nil {
		return fmt.Errorf("failed to push lib/main.dart: %w", err)
	}
	return nil
}

// CurrentOwner логини соҳиби токенро мегирад (то корбар ҳар дафъа лозим
// набошад "owner/repo"-и пурраро бинависад, танҳо номи репо кофист)
func (c *GitHubAppClient) CurrentOwner() (string, error) {
	c.mu.Lock()
	if c.owner != "" {
		o := c.owner
		c.mu.Unlock()
		return o, nil
	}
	c.mu.Unlock()

	body, status, err := c.doRequest(http.MethodGet, "/user", nil)
	if err != nil {
		return "", err
	}
	if status != http.StatusOK {
		return "", fmt.Errorf("failed to get current user: status %d", status)
	}

	var user struct {
		Login string `json:"login"`
	}
	if err := json.Unmarshal(body, &user); err != nil {
		return "", err
	}

	c.mu.Lock()
	c.owner = user.Login
	c.mu.Unlock()
	return user.Login, nil
}

// GetLatestAPK охирин artifact-и APK-и сохташударо барои репои додашуда
// (формати "owner/repo") мегирад, аз файли zip-и GitHub Actions мебарорад
// ва байти худи файли .apk-ро бармегардонад
func (c *GitHubAppClient) GetLatestAPK(fullName string) ([]byte, string, error) {
	path := fmt.Sprintf("/repos/%s/actions/artifacts", fullName)
	body, status, err := c.doRequest(http.MethodGet, path, nil)
	if err != nil {
		return nil, "", err
	}
	if status != http.StatusOK {
		return nil, "", fmt.Errorf("failed to list artifacts: status %d, body: %s", status, string(body))
	}

	var result struct {
		Artifacts []struct {
			Name               string `json:"name"`
			ArchiveDownloadURL string `json:"archive_download_url"`
			Expired            bool   `json:"expired"`
		} `json:"artifacts"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, "", fmt.Errorf("failed to parse artifacts response: %w", err)
	}

	for _, a := range result.Artifacts {
		if a.Expired {
			continue
		}
		zipBytes, err := c.downloadArtifact(a.ArchiveDownloadURL)
		if err != nil {
			continue
		}
		apkBytes, apkName, err := extractAPKFromZip(zipBytes)
		if err != nil {
			continue
		}
		return apkBytes, apkName, nil
	}
	return nil, "", fmt.Errorf("no usable (non-expired, with .apk inside) artifacts found for %s", fullName)
}

func (c *GitHubAppClient) downloadArtifact(url string) ([]byte, error) {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+c.token)
	req.Header.Set("Accept", "application/vnd.github+json")

	resp, err := c.http.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to download artifact: status %d", resp.StatusCode)
	}
	return io.ReadAll(resp.Body)
}

func extractAPKFromZip(zipBytes []byte) ([]byte, string, error) {
	r, err := zip.NewReader(bytes.NewReader(zipBytes), int64(len(zipBytes)))
	if err != nil {
		return nil, "", err
	}
	for _, f := range r.File {
		if strings.HasSuffix(strings.ToLower(f.Name), ".apk") {
			rc, err := f.Open()
			if err != nil {
				return nil, "", err
			}
			defer rc.Close()
			data, err := io.ReadAll(rc)
			if err != nil {
				return nil, "", err
			}
			return data, f.Name, nil
		}
	}
	return nil, "", fmt.Errorf("no .apk file found inside artifact zip")
}
