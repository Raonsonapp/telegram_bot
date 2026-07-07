package api

import (
	"encoding/json"
	"fmt"
	"net/url"

	"anime-bot/backend/utils"
)

// youtubeSearchEndpoint нуқтаи ҷустуҷӯи YouTube Data API v3
const youtubeSearchEndpoint = "https://www.googleapis.com/youtube/v3/search"

// YouTubeVideo як видеои ёфтшуда дар YouTube
type YouTubeVideo struct {
	Title string
	URL   string
}

// YouTubeClient client барои ҷустуҷӯи видео дар YouTube. Бе калиди API ин
// client ғайрифаъол мемонад ва ҳамеша рӯйхати холӣ бармегардонад (на хато) —
// то набудани калид дигар манбаъҳоро вайрон накунад
type YouTubeClient struct {
	http   *utils.HTTPClient
	apiKey string
}

// NewYouTubeClient client-и нав месозад. apiKey метавонад холӣ бошад
// (масалан агар YOUTUBE_API_KEY танзим нашуда бошад)
func NewYouTubeClient(apiKey string) *YouTubeClient {
	return &YouTubeClient{http: utils.NewHTTPClient(), apiKey: apiKey}
}

// Enabled нишон медиҳад, ки оё калиди API мавҷуд аст
func (c *YouTubeClient) Enabled() bool {
	return c.apiKey != ""
}

// SearchVideos дар YouTube бо матни додашуда видео меҷӯяд ва танҳо
// натиҷаҳоеро бармегардонад, ки унвонашон воқеан ба ҷустуҷӯ рабт дорад
func (c *YouTubeClient) SearchVideos(query string, limit int) ([]YouTubeVideo, error) {
	if !c.Enabled() {
		return nil, nil
	}
	if limit <= 0 {
		limit = 5
	}

	endpoint := fmt.Sprintf(
		"%s?part=snippet&type=video&maxResults=%d&q=%s&key=%s",
		youtubeSearchEndpoint, limit*3, url.QueryEscape(query), url.QueryEscape(c.apiKey),
	)

	body, err := c.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("youtube search failed: %w", err)
	}

	var result struct {
		Items []struct {
			ID struct {
				VideoID string `json:"videoId"`
			} `json:"id"`
			Snippet struct {
				Title string `json:"title"`
			} `json:"snippet"`
		} `json:"items"`
		Error *struct {
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse youtube response: %w", err)
	}
	if result.Error != nil {
		return nil, fmt.Errorf("youtube api error: %s", result.Error.Message)
	}

	videos := make([]YouTubeVideo, 0, len(result.Items))
	for _, item := range result.Items {
		if item.ID.VideoID == "" {
			continue
		}
		videos = append(videos, YouTubeVideo{
			Title: item.Snippet.Title,
			URL:   fmt.Sprintf("https://www.youtube.com/watch?v=%s", item.ID.VideoID),
		})
	}

	return filterByRelevance(videos, func(v YouTubeVideo) string { return v.Title }, query, limit), nil
}
