package api

import (
	"archive/zip"
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"
	"time"
)

const githubAPIBase = "https://api.github.com"

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
            flutter create .
          fi

      - name: Get dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --debug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-debug
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

	if err := c.PushFile(repo.FullName, ".github/workflows/build.yml", "Add Flutter APK build workflow", flutterBuildWorkflow); err != nil {
		return repo.FullName, repo.HTMLURL, true, fmt.Errorf("repo created but failed to add workflow: %w", err)
	}

	return repo.FullName, repo.HTMLURL, true, nil
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
	payload, _ := json.Marshal(map[string]interface{}{
		"message": message,
		"content": base64.StdEncoding.EncodeToString([]byte(content)),
	})

	apiPath := fmt.Sprintf("/repos/%s/contents/%s", fullName, path)
	body, status, err := c.doRequest(http.MethodPut, apiPath, payload)
	if err != nil {
		return err
	}
	if status != http.StatusCreated && status != http.StatusOK {
		return fmt.Errorf("failed to push file %q: status %d, body: %s", path, status, string(body))
	}
	return nil
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
