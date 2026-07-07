package api

import (
	"encoding/json"
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"anime-bot/backend/utils"
)

// aparatBaseURL нуқтаи асосии API-и Aparat (платформаи видеои эронӣ, ки дар он
// зиёда аз дубляжҳои форсӣ/тоҷикии аниме ҷойгир мешаванд)
const aparatBaseURL = "https://www.aparat.com/etc/api"

// aparatFlexInt баъзан майдонҳои рақамии Aparat (масалан duration) ҳамчун сатр
// ва баъзан ҳамчун рақам бармегарданд — ин навъ ҳардуро мегирад
type aparatFlexInt int

func (n *aparatFlexInt) UnmarshalJSON(data []byte) error {
	trimmed := strings.Trim(string(data), `"`)
	if trimmed == "" {
		*n = 0
		return nil
	}
	v, err := strconv.Atoi(trimmed)
	if err != nil {
		return err
	}
	*n = aparatFlexInt(v)
	return nil
}

// AparatVideo як видеои ёфтшуда дар Aparat
type AparatVideo struct {
	Title    string        `json:"title"`
	UID      string        `json:"uid"`
	Username string        `json:"username"`
	Duration aparatFlexInt `json:"duration"`
}

// URL суроғаи тамошои видеоро дар Aparat месозад
func (v AparatVideo) URL() string {
	return fmt.Sprintf("https://www.aparat.com/v/%s", v.UID)
}

// AparatClient client барои ҷустуҷӯи видеои дубляжшуда дар Aparat
type AparatClient struct {
	http *utils.HTTPClient
}

// NewAparatClient client-и нав месозад
func NewAparatClient() *AparatClient {
	return &AparatClient{http: utils.NewHTTPClient()}
}

// SearchVideos дар Aparat бо матни додашуда видео меҷӯяд ва танҳо натиҷаҳоеро
// бармегардонад, ки унвонашон воқеан ба матни ҷустуҷӯ рабт дорад (Aparat
// баъзан барои унвонҳои номаълум видеои комилан бемаънӣ бармегардонад)
func (c *AparatClient) SearchVideos(query string, perPage int) ([]AparatVideo, error) {
	if perPage <= 0 {
		perPage = 5
	}
	// Aparat қиматҳоро ҳамчун қисмҳои роҳ (path segments) мегирад, на параметри
	// query-и URL — барои ҳамин PathEscape лозим аст, на QueryEscape (вагарна
	// фазоҳо ба "+" табдил меёбанд, ки дар роҳ маъно надорад)
	endpoint := fmt.Sprintf("%s/videoBySearch/text/%s/perpage/%d", aparatBaseURL, url.PathEscape(query), perPage*3)

	body, err := c.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("aparat search failed: %w", err)
	}

	// Aparat калиди сатҳи болоии ҷавобро мутобиқи номи метод бармегардонад
	// (масалан "videobysearch"), барои ҳамин ба таври мутлақ хондашаванда ҷустуҷӯ мекунем
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(body, &raw); err != nil {
		return nil, fmt.Errorf("failed to parse aparat response: %w", err)
	}

	for key, val := range raw {
		if key == "ui" {
			continue
		}
		var videos []AparatVideo
		if err := json.Unmarshal(val, &videos); err != nil {
			utils.LogError("aparat: failed to parse video list under key=%q: %v", key, err)
			continue
		}
		if len(videos) == 0 {
			continue
		}

		relevant := filterEpisodeCandidates(
			videos,
			func(v AparatVideo) string { return v.Title },
			func(v AparatVideo) (int, bool) { return int(v.Duration), v.Duration > 0 },
			query, perPage,
		)
		if len(relevant) > 0 {
			return relevant, nil
		}
		utils.LogError("aparat: found %d videos for query=%q but none matched the title closely enough", len(videos), query)
		return nil, nil
	}

	preview := string(body)
	if len(preview) > 400 {
		preview = preview[:400] + "..."
	}
	utils.LogError("aparat: no video list found in response for query=%q, keys=%v, body preview: %s", query, mapKeys(raw), preview)
	return nil, nil
}

func mapKeys(m map[string]json.RawMessage) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
