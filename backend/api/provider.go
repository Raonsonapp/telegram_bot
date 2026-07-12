package api

import (
	"appbuilder-bot/backend/models"
	"appbuilder-bot/backend/utils"
)

// AnimeProvider Jikan-ро ҳамчун манбаи асосӣ истифода мебарад ва агар он хато
// диҳад (429/504 — ин барои Jikan-и ройгон дар вақти сербор маъмул аст),
// худкор ба AniList (манбаи эҳтиётӣ) мегузарад, то корбар бе ҷавоб намонад
type AnimeProvider struct {
	Jikan   *JikanClient
	AniList *AniListClient
}

// NewAnimeProvider provider-и нав месозад
func NewAnimeProvider(jikan *JikanClient, anilist *AniListClient) *AnimeProvider {
	return &AnimeProvider{Jikan: jikan, AniList: anilist}
}

// SearchAnime дар Jikan ҷустуҷӯ мекунад, дар сурати хато — дар AniList
func (p *AnimeProvider) SearchAnime(query string, limit int) ([]models.Anime, error) {
	results, err := p.Jikan.SearchAnime(query, limit)
	if err == nil {
		return results, nil
	}
	utils.LogError("jikan search failed, falling back to anilist: %v", err)
	return p.AniList.SearchAnime(query, limit)
}

// GetAnimeByID тафсилоти анимеро аз Jikan мегирад, дар сурати хато — аз AniList
func (p *AnimeProvider) GetAnimeByID(id int) (*models.Anime, error) {
	anime, err := p.Jikan.GetAnimeByID(id)
	if err == nil {
		return anime, nil
	}
	utils.LogError("jikan get anime failed, falling back to anilist: %v", err)
	return p.AniList.GetAnimeByID(id)
}

// GetAnimeEpisodes рӯйхати эпизодҳоро аз Jikan мегирад, дар сурати хато — аз AniList
// (бо маҳдудияти рӯшан: AniList танҳо барои саҳифаи якум маълумот медиҳад)
func (p *AnimeProvider) GetAnimeEpisodes(id int, page int) ([]models.Episode, bool, error) {
	episodes, hasNext, err := p.Jikan.GetAnimeEpisodes(id, page)
	if err == nil {
		return episodes, hasNext, nil
	}
	utils.LogError("jikan episodes failed, falling back to anilist: %v", err)
	return p.AniList.GetAnimeEpisodes(id, page)
}

// GetRandomAnime анимеи тасодуфиро аз Jikan мегирад, дар сурати хато — аз AniList
func (p *AnimeProvider) GetRandomAnime() (*models.Anime, error) {
	anime, err := p.Jikan.GetRandomAnime()
	if err == nil {
		return anime, nil
	}
	utils.LogError("jikan random failed, falling back to anilist: %v", err)
	return p.AniList.GetRandomAnime()
}

// GetTopAnime рӯйхати беҳтаринҳоро аз Jikan мегирад, дар сурати хато — аз AniList
func (p *AnimeProvider) GetTopAnime(limit int) ([]models.Anime, error) {
	results, err := p.Jikan.GetTopAnime(limit)
	if err == nil {
		return results, nil
	}
	utils.LogError("jikan top failed, falling back to anilist: %v", err)
	return p.AniList.GetTopAnime(limit)
}

// SearchByGenres аниме-ҳоро мутобиқи жанр аз Jikan мегирад, дар сурати хато — аз AniList
func (p *AnimeProvider) SearchByGenres(genreIDs []int, limit int) ([]models.Anime, error) {
	results, err := p.Jikan.SearchByGenres(genreIDs, limit)
	if err == nil {
		return results, nil
	}
	utils.LogError("jikan genre search failed, falling back to anilist: %v", err)

	names := GenreIDsToNames(genreIDs)
	if len(names) == 0 {
		return nil, err
	}
	return p.AniList.SearchByGenres(names, limit)
}
