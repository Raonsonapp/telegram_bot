package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

// worldCupBaseURL API-и ройгону кушодаи маълумоти матнии Ҷоми Ҷаҳонии 2026
// (лоиҳаи GitHub-и rezarahiminia/worldcup2026) — танҳо натиҷа/ҷадвал/гурӯҳ
// медиҳад, ҳеҷ видео ё пахши зинда надорад
const worldCupBaseURL = "https://worldcup26.ir"

// WorldCupMatch як бозии Ҷоми Ҷаҳонии 2026-ро ифода мекунад. Сохти дақиқи
// ҷавоби API аз ҷониби мо тасдиқ нашудааст (API дар лаҳзаи навиштани ин код
// аз берун санҷида нашуд) — UnmarshalJSON якчанд номи имконпазири майдонҳоро
// меозмояд, то агар яке мувофиқат накунад, дигараш кор кунад
type WorldCupMatch struct {
	ID        int
	HomeTeam  string
	AwayTeam  string
	HomeScore *int
	AwayScore *int
	Status    string
	Date      string
	Group     string
}

func (m *WorldCupMatch) UnmarshalJSON(data []byte) error {
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(data, &raw); err != nil {
		return err
	}

	getString := func(keys ...string) string {
		for _, k := range keys {
			v, ok := raw[k]
			if !ok {
				continue
			}
			var s string
			if json.Unmarshal(v, &s) == nil && s != "" {
				return s
			}
		}
		return ""
	}

	getTeamName := func(keys ...string) string {
		for _, k := range keys {
			v, ok := raw[k]
			if !ok {
				continue
			}
			var s string
			if json.Unmarshal(v, &s) == nil && s != "" {
				return s
			}
			var obj struct {
				Name  string `json:"name"`
				Title string `json:"title"`
			}
			if json.Unmarshal(v, &obj) == nil {
				if obj.Name != "" {
					return obj.Name
				}
				if obj.Title != "" {
					return obj.Title
				}
			}
		}
		return ""
	}

	getInt := func(keys ...string) int {
		for _, k := range keys {
			v, ok := raw[k]
			if !ok {
				continue
			}
			var n int
			if json.Unmarshal(v, &n) == nil {
				return n
			}
		}
		return 0
	}

	getIntPtr := func(keys ...string) *int {
		for _, k := range keys {
			v, ok := raw[k]
			if !ok {
				continue
			}
			var n int
			if json.Unmarshal(v, &n) == nil {
				return &n
			}
		}
		return nil
	}

	m.ID = getInt("id", "matchId", "match_id")
	m.HomeTeam = getTeamName("homeTeam", "home_team", "home")
	m.AwayTeam = getTeamName("awayTeam", "away_team", "away")
	m.HomeScore = getIntPtr("homeScore", "home_score", "homeGoals")
	m.AwayScore = getIntPtr("awayScore", "away_score", "awayGoals")
	m.Status = getString("status", "matchStatus")
	m.Date = getString("date", "matchDate", "datetime", "kickoff")
	m.Group = getString("group", "groupName")
	return nil
}

// WorldCupClient ба worldcup26.ir пайваст мешавад. API бо JWT кор мекунад —
// корбари собити боти мо худкор сабти ном/вуруд мекунад ва токенро дар хотир
// нигоҳ медорад (то ~80 рӯз, бе дархости такрорӣ)
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
		Token       string `json:"token"`
		AccessToken string `json:"accessToken"`
		Jwt         string `json:"jwt"`
		Data        struct {
			Token string `json:"token"`
		} `json:"data"`
	}
	if err := json.Unmarshal(respBody, &result); err != nil {
		return "", fmt.Errorf("failed to parse auth response from %s: %w", path, err)
	}
	for _, t := range []string{result.Token, result.AccessToken, result.Jwt, result.Data.Token} {
		if t != "" {
			return t, nil
		}
	}
	return "", fmt.Errorf("no recognizable token field in response from %s", path)
}

// GetGames ҳамаи 104 бозии турнирро мегирад
func (c *WorldCupClient) GetGames() ([]WorldCupMatch, error) {
	body, err := c.authorizedGet("/get/games")
	if err != nil {
		return nil, err
	}

	var wrapped struct {
		Data  []WorldCupMatch `json:"data"`
		Games []WorldCupMatch `json:"games"`
	}
	if err := json.Unmarshal(body, &wrapped); err == nil {
		if len(wrapped.Data) > 0 {
			return wrapped.Data, nil
		}
		if len(wrapped.Games) > 0 {
			return wrapped.Games, nil
		}
	}

	var plain []WorldCupMatch
	if err := json.Unmarshal(body, &plain); err == nil && len(plain) > 0 {
		return plain, nil
	}

	return nil, fmt.Errorf("unrecognized response shape from /get/games")
}

func (c *WorldCupClient) authorizedGet(path string) ([]byte, error) {
	if err := c.ensureToken(); err != nil {
		return nil, err
	}

	do := func() (*http.Response, error) {
		req, err := http.NewRequest(http.MethodGet, worldCupBaseURL+path, nil)
		if err != nil {
			return nil, err
		}
		c.mu.Lock()
		token := c.token
		c.mu.Unlock()
		req.Header.Set("Authorization", "Bearer "+token)
		return c.http.Do(req)
	}

	resp, err := do()
	if err != nil {
		return nil, err
	}

	if resp.StatusCode == http.StatusUnauthorized {
		resp.Body.Close()
		c.mu.Lock()
		c.token = ""
		c.mu.Unlock()
		if err := c.ensureToken(); err != nil {
			return nil, err
		}
		resp, err = do()
		if err != nil {
			return nil, err
		}
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("request to %s failed: status %d", path, resp.StatusCode)
	}
	return io.ReadAll(resp.Body)
}
