package api

import (
	"encoding/json"
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"anime-bot/backend/utils"
)

// youtubeSearchEndpoint нуқтаи ҷустуҷӯи YouTube Data API v3
const youtubeSearchEndpoint = "https://www.googleapis.com/youtube/v3/search"

// youtubeVideosEndpoint барои гирифтани дарозии видео (contentDetails) лозим аст —
// натиҷаи search.list дарозиро намедиҳад
const youtubeVideosEndpoint = "https://www.googleapis.com/youtube/v3/videos"

// YouTubeVideo як видеои ёфтшуда дар YouTube
type YouTubeVideo struct {
	ID    string
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
// натиҷаҳоеро бармегардонад, ки унвонашон ба ҷустуҷӯ рабт дорад ва дарозиашон
// ба як қисми аниме монанд аст (на филм, на клипи кӯтоҳ)
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
			ID:    item.ID.VideoID,
			Title: item.Snippet.Title,
			URL:   fmt.Sprintf("https://www.youtube.com/watch?v=%s", item.ID.VideoID),
		})
	}

	// search.list намедиҳад дарозии видеоро — барои санҷиши он дархости
	// дуюм ба videos.list лозим аст. Агар ин дархост ноком шавад, аз санҷиши
	// дарозӣ мегузарем (беҳтар натиҷаи бе санҷиш аз ҳеҷ натиҷа)
	durations, err := c.fetchDurations(videoIDs(videos))
	if err != nil {
		utils.LogError("youtube: failed to fetch durations, skipping duration filter: %v", err)
		return filterEpisodeCandidates(videos, func(v YouTubeVideo) string { return v.Title }, func(v YouTubeVideo) (int, bool) { return 0, false }, query, limit), nil
	}

	return filterEpisodeCandidates(
		videos,
		func(v YouTubeVideo) string { return v.Title },
		func(v YouTubeVideo) (int, bool) { seconds, ok := durations[v.ID]; return seconds, ok },
		query, limit,
	), nil
}

func videoIDs(videos []YouTubeVideo) []string {
	ids := make([]string, 0, len(videos))
	for _, v := range videos {
		ids = append(ids, v.ID)
	}
	return ids
}

// fetchDurations дарозии якчанд видеоро якбора мегирад (то дархости
// такрориро кам кунад) ва ҷадвали videoID -> сония бармегардонад
func (c *YouTubeClient) fetchDurations(videoIDs []string) (map[string]int, error) {
	if len(videoIDs) == 0 {
		return map[string]int{}, nil
	}

	endpoint := fmt.Sprintf(
		"%s?part=contentDetails&id=%s&key=%s",
		youtubeVideosEndpoint, url.QueryEscape(strings.Join(videoIDs, ",")), url.QueryEscape(c.apiKey),
	)

	body, err := c.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("youtube videos.list failed: %w", err)
	}

	var result struct {
		Items []struct {
			ID             string `json:"id"`
			ContentDetails struct {
				Duration string `json:"duration"`
			} `json:"contentDetails"`
		} `json:"items"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse youtube videos.list response: %w", err)
	}

	durations := make(map[string]int, len(result.Items))
	for _, item := range result.Items {
		if seconds, ok := parseISO8601Duration(item.ContentDetails.Duration); ok {
			durations[item.ID] = seconds
		}
	}
	return durations, nil
}

// parseISO8601Duration формати "PT#H#M#S"-и YouTube-ро ба сония табдил медиҳад
func parseISO8601Duration(s string) (int, bool) {
	if !strings.HasPrefix(s, "PT") {
		return 0, false
	}
	s = s[2:]

	var hours, minutes, seconds int
	var num strings.Builder
	for _, r := range s {
		switch r {
		case 'H':
			hours, _ = strconv.Atoi(num.String())
			num.Reset()
		case 'M':
			minutes, _ = strconv.Atoi(num.String())
			num.Reset()
		case 'S':
			seconds, _ = strconv.Atoi(num.String())
			num.Reset()
		default:
			num.WriteRune(r)
		}
	}
	return hours*3600 + minutes*60 + seconds, true
}
