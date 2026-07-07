package api

import (
	"encoding/json"
	"fmt"
	"net/url"

	"anime-bot/backend/utils"
)

// aparatBaseURL нуқтаи асосии API-и Aparat (платформаи видеои эронӣ, ки дар он
// зиёда аз дубляжҳои форсӣ/тоҷикии аниме ҷойгир мешаванд)
const aparatBaseURL = "https://www.aparat.com/etc/api"

// AparatVideo як видеои ёфтшуда дар Aparat
type AparatVideo struct {
	ID       int    `json:"id"`
	Title    string `json:"title"`
	UID      string `json:"uid"`
	Username string `json:"username"`
	Duration int    `json:"duration"`
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

// SearchVideos дар Aparat бо матни додашуда видео меҷӯяд
func (c *AparatClient) SearchVideos(query string, perPage int) ([]AparatVideo, error) {
	if perPage <= 0 {
		perPage = 5
	}
	// Aparat қиматҳоро ҳамчун қисмҳои роҳ (path segments) мегирад, на параметри
	// query-и URL — барои ҳамин PathEscape лозим аст, на QueryEscape (вагарна
	// фазоҳо ба "+" табдил меёбанд, ки дар роҳ маъно надорад)
	endpoint := fmt.Sprintf("%s/videoBySearch/text/%s/perpage/%d", aparatBaseURL, url.PathEscape(query), perPage)

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
		if err := json.Unmarshal(val, &videos); err == nil && len(videos) > 0 {
			return videos, nil
		}
	}
	return nil, nil
}
