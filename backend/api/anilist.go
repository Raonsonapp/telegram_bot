package api

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"strings"

	"anime-bot/backend/models"
	"anime-bot/backend/utils"
)

// aniListEndpoint нуқтаи ягонаи GraphQL-и AniList
const aniListEndpoint = "https://graphql.anilist.co"

// AniListClient манбаи эҳтиётӣ (fallback) барои маълумоти аниме, вақте ки
// Jikan API дастнорас ё серкор аст (429/504 — ин барои Jikan-и ройгон маъмул аст).
// Барои мутобиқати ID-ҳо, ҳамеша idMal-и AniList истифода мешавад, на ID-и худи AniList,
// то тугмаи "Дар MyAnimeList бин" ва cache-и дохилӣ бо натиҷаҳои Jikan ихтилоф надошта бошанд
type AniListClient struct {
	http *utils.HTTPClient
}

// NewAniListClient client-и нав месозад
func NewAniListClient() *AniListClient {
	return &AniListClient{http: utils.NewHTTPClient()}
}

type aniListMediaTitle struct {
	Romaji  string `json:"romaji"`
	English string `json:"english"`
	Native  string `json:"native"`
}

type aniListCoverImage struct {
	Large  string `json:"large"`
	Medium string `json:"medium"`
}

type aniListMedia struct {
	IDMal        *int              `json:"idMal"`
	Title        aniListMediaTitle `json:"title"`
	Description  string            `json:"description"`
	AverageScore int               `json:"averageScore"`
	Episodes     int               `json:"episodes"`
	Status       string            `json:"status"`
	Format       string            `json:"format"`
	StartDate    struct {
		Year int `json:"year"`
	} `json:"startDate"`
	CoverImage aniListCoverImage `json:"coverImage"`
	Genres     []string          `json:"genres"`
}

const aniListMediaFields = `
	idMal
	title { romaji english native }
	description(asHtml: false)
	averageScore
	episodes
	status
	format
	startDate { year }
	coverImage { large medium }
	genres
`

// toAnime aniListMedia-ро ба models.Anime табдил медиҳад. Агар idMal мавҷуд
// набошад (баъзе унвонҳои AniList ба MyAnimeList пайваст нашудаанд), ok=false
func (m aniListMedia) toAnime() (models.Anime, bool) {
	if m.IDMal == nil {
		return models.Anime{}, false
	}
	genres := make([]models.Genre, 0, len(m.Genres))
	for _, g := range m.Genres {
		genres = append(genres, models.Genre{Name: g})
	}
	anime := models.Anime{
		MalID:         *m.IDMal,
		Title:         firstNonEmpty(m.Title.Romaji, m.Title.English, m.Title.Native),
		TitleEnglish:  m.Title.English,
		TitleJapanese: m.Title.Native,
		Synopsis:      cleanAniListDescription(m.Description),
		Score:         float64(m.AverageScore) / 10.0,
		Episodes:      m.Episodes,
		Status:        aniListStatusLabel(m.Status),
		Type:          aniListFormatLabel(m.Format),
		Year:          m.StartDate.Year,
		URL:           fmt.Sprintf("https://myanimelist.net/anime/%d", *m.IDMal),
		Genres:        genres,
	}
	anime.Images.JPG.ImageURL = m.CoverImage.Medium
	anime.Images.JPG.LargeImageURL = m.CoverImage.Large
	return anime, true
}

func firstNonEmpty(values ...string) string {
	for _, v := range values {
		if v != "" {
			return v
		}
	}
	return "Unknown"
}

func cleanAniListDescription(desc string) string {
	replacer := strings.NewReplacer(
		"<br>", "\n", "<br/>", "\n", "<br />", "\n",
		"<i>", "", "</i>", "", "<b>", "", "</b>", "",
	)
	return replacer.Replace(desc)
}

func aniListStatusLabel(status string) string {
	switch status {
	case "FINISHED":
		return "Finished Airing"
	case "RELEASING":
		return "Currently Airing"
	case "NOT_YET_RELEASED":
		return "Not yet aired"
	case "CANCELLED":
		return "Cancelled"
	default:
		return status
	}
}

func aniListFormatLabel(format string) string {
	switch format {
	case "TV_SHORT":
		return "TV Short"
	case "MOVIE":
		return "Movie"
	case "SPECIAL":
		return "Special"
	case "MUSIC":
		return "Music"
	default:
		return format
	}
}

func convertMediaList(list []aniListMedia) []models.Anime {
	result := make([]models.Anime, 0, len(list))
	for _, m := range list {
		if anime, ok := m.toAnime(); ok {
			result = append(result, anime)
		}
	}
	return result
}

type aniListRequest struct {
	Query     string                 `json:"query"`
	Variables map[string]interface{} `json:"variables"`
}

// query дархости GraphQL-ро ба AniList мефиристад ва қисми "data"-ро бармегардонад
func (c *AniListClient) query(gql string, variables map[string]interface{}) (json.RawMessage, error) {
	body, err := json.Marshal(aniListRequest{Query: gql, Variables: variables})
	if err != nil {
		return nil, err
	}
	respBody, err := c.http.Post(aniListEndpoint, body)
	if err != nil {
		return nil, err
	}

	var result struct {
		Data   json.RawMessage `json:"data"`
		Errors []struct {
			Message string `json:"message"`
		} `json:"errors"`
	}
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("failed to parse anilist response: %w", err)
	}
	if len(result.Errors) > 0 {
		return nil, fmt.Errorf("anilist error: %s", result.Errors[0].Message)
	}
	return result.Data, nil
}

// SearchAnime дар AniList бо номи аниме ҷустуҷӯ мекунад
func (c *AniListClient) SearchAnime(query string, limit int) ([]models.Anime, error) {
	if limit <= 0 {
		limit = 5
	}
	gql := `query ($search: String, $perPage: Int) {
		Page(perPage: $perPage) {
			media(search: $search, type: ANIME, sort: SEARCH_MATCH) { ` + aniListMediaFields + ` }
		}
	}`
	data, err := c.query(gql, map[string]interface{}{"search": query, "perPage": limit})
	if err != nil {
		return nil, fmt.Errorf("anilist search failed: %w", err)
	}
	var parsed struct {
		Page struct {
			Media []aniListMedia `json:"media"`
		} `json:"Page"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, fmt.Errorf("failed to parse anilist search response: %w", err)
	}
	return convertMediaList(parsed.Page.Media), nil
}

// GetAnimeByID тафсилоти анимеро аз рӯи ID-и MyAnimeList аз AniList мегирад
func (c *AniListClient) GetAnimeByID(malID int) (*models.Anime, error) {
	gql := `query ($idMal: Int) {
		Media(idMal: $idMal, type: ANIME) { ` + aniListMediaFields + ` }
	}`
	data, err := c.query(gql, map[string]interface{}{"idMal": malID})
	if err != nil {
		return nil, fmt.Errorf("anilist get anime failed: %w", err)
	}
	var parsed struct {
		Media aniListMedia `json:"Media"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, fmt.Errorf("failed to parse anilist anime response: %w", err)
	}
	anime, ok := parsed.Media.toAnime()
	if !ok {
		return nil, fmt.Errorf("anilist: no MyAnimeList mapping for anime id=%d", malID)
	}
	return &anime, nil
}

// GetRandomAnime як анимеи тасодуфиро аз AniList мегирад
func (c *AniListClient) GetRandomAnime() (*models.Anime, error) {
	page := rand.Intn(500) + 1
	gql := `query ($page: Int) {
		Page(page: $page, perPage: 1) {
			media(type: ANIME, sort: ID, isAdult: false) { ` + aniListMediaFields + ` }
		}
	}`
	data, err := c.query(gql, map[string]interface{}{"page": page})
	if err != nil {
		return nil, fmt.Errorf("anilist random failed: %w", err)
	}
	var parsed struct {
		Page struct {
			Media []aniListMedia `json:"media"`
		} `json:"Page"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, fmt.Errorf("failed to parse anilist random response: %w", err)
	}
	list := convertMediaList(parsed.Page.Media)
	if len(list) == 0 {
		return nil, fmt.Errorf("anilist: no random anime found")
	}
	return &list[0], nil
}

// GetTopAnime рӯйхати беҳтарин аниме-ҳоро аз AniList мегирад
func (c *AniListClient) GetTopAnime(limit int) ([]models.Anime, error) {
	if limit <= 0 {
		limit = 10
	}
	gql := `query ($perPage: Int) {
		Page(perPage: $perPage) {
			media(type: ANIME, sort: SCORE_DESC, isAdult: false) { ` + aniListMediaFields + ` }
		}
	}`
	data, err := c.query(gql, map[string]interface{}{"perPage": limit})
	if err != nil {
		return nil, fmt.Errorf("anilist top failed: %w", err)
	}
	var parsed struct {
		Page struct {
			Media []aniListMedia `json:"media"`
		} `json:"Page"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, fmt.Errorf("failed to parse anilist top response: %w", err)
	}
	return convertMediaList(parsed.Page.Media), nil
}

// GetAnimeEpisodes рӯйхати эпизодҳоро аз AniList мегирад (fallback вақте Jikan кор намекунад).
// AniList саҳифабандии Jikan-монандро надорад — барои ҳамин танҳо барои page=1 маълумот
// медиҳад; агар "streamingEpisodes" холӣ бошад, аз рӯи шумораи умумии эпизодҳо рӯйхати
// оддӣ (бе унвон) месозад, то ҳадди ақал шумораи қисмҳо ба корбар маълум шавад
func (c *AniListClient) GetAnimeEpisodes(malID int, page int) ([]models.Episode, bool, error) {
	if page > 1 {
		return nil, false, nil
	}

	gql := `query ($idMal: Int) {
		Media(idMal: $idMal, type: ANIME) {
			episodes
			streamingEpisodes { title }
		}
	}`
	data, err := c.query(gql, map[string]interface{}{"idMal": malID})
	if err != nil {
		return nil, false, fmt.Errorf("anilist episodes failed: %w", err)
	}

	var parsed struct {
		Media struct {
			Episodes          int `json:"episodes"`
			StreamingEpisodes []struct {
				Title string `json:"title"`
			} `json:"streamingEpisodes"`
		} `json:"Media"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, false, fmt.Errorf("failed to parse anilist episodes response: %w", err)
	}

	if len(parsed.Media.StreamingEpisodes) > 0 {
		episodes := make([]models.Episode, 0, len(parsed.Media.StreamingEpisodes))
		for i, se := range parsed.Media.StreamingEpisodes {
			episodes = append(episodes, models.Episode{MalID: i + 1, Title: se.Title})
		}
		return episodes, false, nil
	}

	total := parsed.Media.Episodes
	if total <= 0 {
		return nil, false, nil
	}
	if total > 100 {
		total = 100
	}
	episodes := make([]models.Episode, 0, total)
	for i := 1; i <= total; i++ {
		episodes = append(episodes, models.Episode{MalID: i})
	}
	return episodes, false, nil
}

// SearchByGenres аниме-ҳоро мутобиқи номи жанр(ҳо) аз AniList меёбад
func (c *AniListClient) SearchByGenres(genreNames []string, limit int) ([]models.Anime, error) {
	if limit <= 0 {
		limit = 15
	}
	gql := `query ($genres: [String], $perPage: Int) {
		Page(perPage: $perPage) {
			media(genre_in: $genres, type: ANIME, sort: SCORE_DESC, isAdult: false) { ` + aniListMediaFields + ` }
		}
	}`
	data, err := c.query(gql, map[string]interface{}{"genres": genreNames, "perPage": limit})
	if err != nil {
		return nil, fmt.Errorf("anilist genre search failed: %w", err)
	}
	var parsed struct {
		Page struct {
			Media []aniListMedia `json:"media"`
		} `json:"Page"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, fmt.Errorf("failed to parse anilist genre search response: %w", err)
	}
	return convertMediaList(parsed.Page.Media), nil
}
