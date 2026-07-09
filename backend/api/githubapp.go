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

// androidBuildWorkflow workflow-и стандартии GitHub Actions, ки лоиҳаи
// Android-и Gradle-ро build карда, APK-ро ҳамчун artifact бор мекунад.
// Ин ба ҳар репои нав худкор илова мешавад — корбар танҳо коди худи
// барномаро (лоиҳаи Android Studio-и оддӣ, папкаи "app") push мекунад,
// ва ин workflow худкор APK месозад
const androidBuildWorkflow = `name: Build APK

on:
  push:
    branches: [ main, master ]
  workflow_dispatch: {}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Grant execute permission for gradlew
        run: chmod +x gradlew
        continue-on-error: true

      - name: Build debug APK
        run: ./gradlew assembleDebug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-debug
          path: app/build/outputs/apk/debug/*.apk
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

// sanitizeRepoName номи озоди корбарро ба номи қобили қабули GitHub
// (ҳарфи хурд, рақам, хат) табдил медиҳад
func sanitizeRepoName(name string) string {
	name = strings.ToLower(strings.TrimSpace(name))
	var b strings.Builder
	lastWasDash := false
	for _, r := range name {
		switch {
		case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
			b.WriteRune(r)
			lastWasDash = false
		case r == ' ', r == '-', r == '_':
			if !lastWasDash {
				b.WriteRune('-')
				lastWasDash = true
			}
		}
	}
	result := strings.Trim(b.String(), "-")
	if result == "" {
		result = fmt.Sprintf("app-%d", time.Now().Unix())
	}
	return result
}

// CreateAppRepo репои нав месозад ва workflow-и build-и APK-ро дар он
// ҷойгир мекунад. fullName формати "owner/repo" дорад
func (c *GitHubAppClient) CreateAppRepo(appName string) (fullName string, htmlURL string, err error) {
	repoName := sanitizeRepoName(appName)

	payload, _ := json.Marshal(map[string]interface{}{
		"name":        repoName,
		"description": fmt.Sprintf("App scaffold: %s", appName),
		"private":     false,
		"auto_init":   true,
	})

	body, status, err := c.doRequest(http.MethodPost, "/user/repos", payload)
	if err != nil {
		return "", "", fmt.Errorf("failed to create repo: %w", err)
	}
	if status != http.StatusCreated {
		return "", "", fmt.Errorf("failed to create repo: status %d, body: %s", status, string(body))
	}

	var repo struct {
		FullName string `json:"full_name"`
		HTMLURL  string `json:"html_url"`
		Owner    struct {
			Login string `json:"login"`
		} `json:"owner"`
	}
	if err := json.Unmarshal(body, &repo); err != nil {
		return "", "", fmt.Errorf("failed to parse create-repo response: %w", err)
	}

	c.mu.Lock()
	c.owner = repo.Owner.Login
	c.mu.Unlock()

	// GitHub-ро як лаҳза интизор мешавем, то репои нав (ки ҳозир бо auto_init
	// сохта шуд) пеш аз навиштани файли дигар пурра омода шавад
	time.Sleep(2 * time.Second)

	if err := c.addWorkflowFile(repo.FullName); err != nil {
		return repo.FullName, repo.HTMLURL, fmt.Errorf("repo created but failed to add workflow: %w", err)
	}

	return repo.FullName, repo.HTMLURL, nil
}

func (c *GitHubAppClient) addWorkflowFile(fullName string) error {
	payload, _ := json.Marshal(map[string]interface{}{
		"message": "Add Android APK build workflow",
		"content": base64.StdEncoding.EncodeToString([]byte(androidBuildWorkflow)),
	})

	path := fmt.Sprintf("/repos/%s/contents/.github/workflows/build.yml", fullName)
	body, status, err := c.doRequest(http.MethodPut, path, payload)
	if err != nil {
		return err
	}
	if status != http.StatusCreated {
		return fmt.Errorf("failed to add workflow file: status %d, body: %s", status, string(body))
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
