package api

import (
	"encoding/json"
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"appbuilder-bot/backend/models"
	"appbuilder-bot/backend/utils"
)

// JikanClient client барои кор бо Jikan API (v4) - манбаи ройгони MyAnimeList
// Ҳуҷҷат: https://docs.api.jikan.moe/
type JikanClient struct {
	BaseURL string
	http    *utils.HTTPClient
}

// NewJikanClient client-и нав месозад
func NewJikanClient(baseURL string) *JikanClient {
	return &JikanClient{
		BaseURL: baseURL,
		http:    utils.NewHTTPClient(),
	}
}

// SearchAnime дар Jikan API бо номи аниме ҷустуҷӯ мекунад
func (j *JikanClient) SearchAnime(query string, limit int) ([]models.Anime, error) {
	if limit <= 0 {
		limit = 5
	}
	endpoint := fmt.Sprintf("%s/anime?q=%s&limit=%d&order_by=popularity&sort=asc",
		j.BaseURL, url.QueryEscape(query), limit)

	body, err := j.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("search request failed: %w", err)
	}

	var result models.JikanSearchResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse search response: %w", err)
	}
	return result.Data, nil
}

// GetAnimeByID тафсилоти пурраи як аниме-ро мегирад
func (j *JikanClient) GetAnimeByID(id int) (*models.Anime, error) {
	endpoint := fmt.Sprintf("%s/anime/%d", j.BaseURL, id)

	body, err := j.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("get anime request failed: %w", err)
	}

	var result models.JikanAnimeResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse anime response: %w", err)
	}
	return &result.Data, nil
}

// GetAnimeEpisodes рӯйхати эпизодҳои аниме-ро мегирад (саҳифаи додашуда)
func (j *JikanClient) GetAnimeEpisodes(id int, page int) ([]models.Episode, bool, error) {
	if page <= 0 {
		page = 1
	}
	endpoint := fmt.Sprintf("%s/anime/%d/episodes?page=%d", j.BaseURL, id, page)

	body, err := j.http.Get(endpoint)
	if err != nil {
		return nil, false, fmt.Errorf("get episodes request failed: %w", err)
	}

	var result models.JikanEpisodesResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, false, fmt.Errorf("failed to parse episodes response: %w", err)
	}
	return result.Data, result.Pagination.HasNextPage, nil
}

// GetRandomAnime як аниме-и тасодуфиро аз Jikan мегирад
func (j *JikanClient) GetRandomAnime() (*models.Anime, error) {
	endpoint := fmt.Sprintf("%s/random/anime", j.BaseURL)

	body, err := j.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("random anime request failed: %w", err)
	}

	var result models.JikanAnimeResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse random anime response: %w", err)
	}
	return &result.Data, nil
}

// SearchByGenres аниме-ҳоро мутобиқи жанр(ҳо)-и додашуда меёбад — барои
// пешниҳод аз рӯи кайфияти корбар истифода мешавад
func (j *JikanClient) SearchByGenres(genreIDs []int, limit int) ([]models.Anime, error) {
	if limit <= 0 {
		limit = 15
	}
	ids := make([]string, len(genreIDs))
	for i, id := range genreIDs {
		ids[i] = strconv.Itoa(id)
	}
	endpoint := fmt.Sprintf("%s/anime?genres=%s&order_by=score&sort=desc&limit=%d&sfw=true",
		j.BaseURL, strings.Join(ids, ","), limit)

	body, err := j.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("genre search request failed: %w", err)
	}

	var result models.JikanSearchResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse genre search response: %w", err)
	}
	return result.Data, nil
}

// GetTopAnime рӯйхати беҳтарин аниме-ҳоро мегирад
func (j *JikanClient) GetTopAnime(limit int) ([]models.Anime, error) {
	if limit <= 0 {
		limit = 10
	}
	endpoint := fmt.Sprintf("%s/top/anime?limit=%d", j.BaseURL, limit)

	body, err := j.http.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("top anime request failed: %w", err)
	}

	var result models.JikanSearchResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, fmt.Errorf("failed to parse top anime response: %w", err)
	}
	return result.Data, nil
}
