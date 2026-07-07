package api

import (
	"encoding/json"
	"fmt"
	"net/url"

	"anime-bot/backend/utils"
)

// dailymotionEndpoint API-и ҷустуҷӯи Dailymotion — барои ҷустуҷӯи оддӣ калиди
// API лозим нест, аз ин рӯ ин манбаи дуюми ройгони видео барои дубляж аст
const dailymotionEndpoint = "https://api.dailymotion.com/videos"

// DailymotionVideo як видеои ёфтшуда дар Dailymotion
type DailymotionVideo struct {
	Title string `json:"title"`
	URL   string `json:"url"`
}

// DailymotionClient client барои ҷустуҷӯи видео дар Dailymotion
type DailymotionClient struct {
	http *utils.HTTPClient
}

// NewDailymotionClient client-и нав месозад
func NewDailymotionClient() *DailymotionClient {
	return &DailymotionClient{http: utils.NewHTTPClient()}
}

// SearchVideos дар Dailymotion бо матни додашуда видео меҷӯяд ва танҳо
// натиҷаҳоеро бармегардонад, ки унвонашон воқеан ба ҷустуҷӯ рабт дорад
func (c *DailymotionClient) SearchVideos(query string, limit int) ([]DailymotionVideo, error) {
	if limit <= 0 {
		limit = 5
	}
	endpoint := fmt.Sprintf(
		"%s?search=%s&fields=title,url&limit=%d&sort=relevance",
		dailymotionEndpoint, url.QueryEscape(query), limit*3,
	)

	body, err := c.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("dailymotion search failed: %w", err)
	}

	var result struct {
		List []DailymotionVideo `json:"list"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse dailymotion response: %w", err)
	}

	return filterByRelevance(result.List, func(v DailymotionVideo) string { return v.Title }, query, limit), nil
}
