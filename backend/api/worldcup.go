package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"
)

// worldCupBaseURL API-и ройгону кушодаи маълумоти матнии Ҷоми Ҷаҳонии 2026
// (лоиҳаи GitHub-и rezarahiminia/worldcup2026) — танҳо натиҷа/ҷадвал/гурӯҳ
// медиҳад, ҳеҷ видео ё пахши зинда надорад
const worldCupBaseURL = "https://worldcup26.ir"

// WorldCupMatch як бозии Ҷоми Ҷаҳонии 2026-ро ифода мекунад. Сохти майдонҳо
// мутобиқи мисоли воқеии ҷавоби API дар README-и лоиҳа аст (масалан
// "home_score" ҳамчун сатр, на рақам — API ин тавр бармегардонад)
type WorldCupMatch struct {
	ID             string
	HomeTeamNameEn string
	AwayTeamNameEn string
	HomeScore      int
	AwayScore      int
	Group          string
	LocalDate      string
	Finished       bool
	TimeElapsed    string
	Type           string
}

func (m *WorldCupMatch) UnmarshalJSON(data []byte) error {
	var raw struct {
		ID             string `json:"id"`
		HomeTeamNameEn string `json:"home_team_name_en"`
		AwayTeamNameEn string `json:"away_team_name_en"`
		HomeTeamLabel  string `json:"home_team_label"`
		AwayTeamLabel  string `json:"away_team_label"`
		HomeScore      string `json:"home_score"`
		AwayScore      string `json:"away_score"`
		Group          string `json:"group"`
		LocalDate      string `json:"local_date"`
		Finished       string `json:"finished"`
		TimeElapsed    string `json:"time_elapsed"`
		Type           string `json:"type"`
	}
	if err := json.Unmarshal(data, &raw); err != nil {
		return err
	}

	m.ID = raw.ID
	m.HomeTeamNameEn = raw.HomeTeamNameEn
	if m.HomeTeamNameEn == "" {
		m.HomeTeamNameEn = raw.HomeTeamLabel
	}
	m.AwayTeamNameEn = raw.AwayTeamNameEn
	if m.AwayTeamNameEn == "" {
		m.AwayTeamNameEn = raw.AwayTeamLabel
	}
	m.HomeScore, _ = strconv.Atoi(raw.HomeScore)
	m.AwayScore, _ = strconv.Atoi(raw.AwayScore)
	m.Group = raw.Group
	m.LocalDate = raw.LocalDate
	m.Finished = strings.EqualFold(raw.Finished, "true")
	m.TimeElapsed = raw.TimeElapsed
	m.Type = raw.Type
	return nil
}

// WorldCupClient ба worldcup26.ir пайваст мешавад. Мувофиқи README-и лоиҳа,
// хондани /get/* бе токен ҳам бояд кор кунад (сатҳи "демо"-и ройгон бо
// маҳдудияти суръат) — барои ҳамин аввал бе Authorization кӯшиш мекунем,
// ва танҳо агар 401 гирем, ба JWT (сабти ном/вуруди худкор) мегузарем
type WorldCupClient struct {
	http     *http.Client
	email    string
	password string

	mu      sync.Mutex
	token   string
	tokenAt time.Time
}

// NewWorldCupClient client-и нав месозад. email/password метавонанд холӣ
// бошанд — дар ин ҳолат қиматҳои пешфарз истифода мешаванд (акаунти
// худкори худи бот, на акаунти шахсии касе)
func NewWorldCupClient(email, password string) *WorldCupClient {
	if email == "" {
		email = "animebot.worldcup2026@gmail.com"
	}
	if password == "" {
		password = "AnimeBotWC2026!Secure"
	}
	return &WorldCupClient{
		http:     &http.Client{Timeout: 10 * time.Second},
		email:    email,
		password: password,
	}
}

func (c *WorldCupClient) ensureToken() error {
	c.mu.Lock()
	hasValid := c.token != "" && time.Since(c.tokenAt) < 80*24*time.Hour
	c.mu.Unlock()
	if hasValid {
		return nil
	}

	// Аввал кӯшиши вуруд (агар акаунт аллакай вуҷуд дошта бошад)
	if token, err := c.postAuth("/auth/authenticate", nil); err == nil {
		c.mu.Lock()
		c.token = token
		c.tokenAt = time.Now()
		c.mu.Unlock()
		return nil
	}

	// Вуруд ноком шуд — эҳтимол акаунт ҳанӯз сохта нашудааст, сабти ном мекунем
	token, err := c.postAuth("/auth/register", map[string]string{"name": "AnimeBot"})
	if err != nil {
		return fmt.Errorf("failed to register/authenticate with worldcup api: %w", err)
	}
	c.mu.Lock()
	c.token = token
	c.tokenAt = time.Now()
	c.mu.Unlock()
	return nil
}

func (c *WorldCupClient) postAuth(path string, extra map[string]string) (string, error) {
	payload := map[string]string{"email": c.email, "password": c.password}
	for k, v := range extra {
		payload[k] = v
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest(http.MethodPost, worldCupBaseURL+path, bytes.NewReader(body))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return "", fmt.Errorf("auth request to %s failed: status %d", path, resp.StatusCode)
	}

	var result struct {
		Token string `json:"token"`
	}
	if err := json.Unmarshal(respBody, &result); err != nil {
		return "", fmt.Errorf("failed to parse auth response from %s: %w", path, err)
	}
	if result.Token == "" {
		return "", fmt.Errorf("no token in response from %s", path)
	}
	return result.Token, nil
}

// GetGames ҳамаи 104 бозии турнирро мегирад
func (c *WorldCupClient) GetGames() ([]WorldCupMatch, error) {
	body, err := c.authorizedGet("/get/games")
	if err != nil {
		return nil, err
	}

	var wrapped struct {
		Games []WorldCupMatch `json:"games"`
		Data  []WorldCupMatch `json:"data"`
	}
	if err := json.Unmarshal(body, &wrapped); err == nil {
		if len(wrapped.Games) > 0 {
			return wrapped.Games, nil
		}
		if len(wrapped.Data) > 0 {
			return wrapped.Data, nil
		}
	}

	var plain []WorldCupMatch
	if err := json.Unmarshal(body, &plain); err == nil && len(plain) > 0 {
		return plain, nil
	}

	return nil, fmt.Errorf("unrecognized response shape from /get/games")
}

// authorizedGet мувофиқи README аввал бе токен мекӯшад (сатҳи ройгони
// "демо"), баъд агар 401 гирад, бо JWT (сабти ном/вуруди худкор) такрор мекунад
func (c *WorldCupClient) authorizedGet(path string) ([]byte, error) {
	body, status, err := c.rawGet(path, "")
	if err != nil {
		return nil, err
	}
	if status == http.StatusOK {
		return body, nil
	}

	if err := c.ensureToken(); err != nil {
		return nil, fmt.Errorf("unauthenticated request failed (status %d) and auth fallback failed: %w", status, err)
	}
	c.mu.Lock()
	token := c.token
	c.mu.Unlock()

	body, status, err = c.rawGet(path, token)
	if err != nil {
		return nil, err
	}
	if status == http.StatusUnauthorized {
		c.mu.Lock()
		c.token = ""
		c.mu.Unlock()
		if err := c.ensureToken(); err != nil {
			return nil, err
		}
		c.mu.Lock()
		token = c.token
		c.mu.Unlock()
		body, status, err = c.rawGet(path, token)
		if err != nil {
			return nil, err
		}
	}

	if status != http.StatusOK {
		return nil, fmt.Errorf("request to %s failed: status %d", path, status)
	}
	return body, nil
}

func (c *WorldCupClient) rawGet(path string, token string) ([]byte, int, error) {
	req, err := http.NewRequest(http.MethodGet, worldCupBaseURL+path, nil)
	if err != nil {
		return nil, 0, err
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return nil, 0, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, 0, err
	}
	return body, resp.StatusCode, nil
}
