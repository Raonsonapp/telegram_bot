package database

import (
	"database/sql"
	"strings"
	"time"

	"appbuilder-bot/backend/models"
)

// genreNames номи жанрҳоро бо вергул якҷоя мекунад, то дар як сатри БД нигоҳ дошта шавад
func genreNames(genres []models.Genre) string {
	names := make([]string, 0, len(genres))
	for _, g := range genres {
		names = append(names, g.Name)
	}
	return strings.Join(names, ",")
}

// ToggleFavorite анимеро ба Севимиҳо илова мекунад ё аз он хориҷ мекунад.
// Бармегардонад added=true агар илова шуда бошад, added=false агар хориҷ шуда бошад
func (d *DB) ToggleFavorite(telegramID int64, anime models.Anime) (bool, error) {
	isFav, err := d.IsFavorite(telegramID, anime.MalID)
	if err != nil {
		return false, err
	}
	if isFav {
		_, err := d.Conn.Exec(`DELETE FROM favorites WHERE telegram_id = ? AND anime_id = ?`, telegramID, anime.MalID)
		return false, err
	}
	_, err = d.Conn.Exec(
		`INSERT INTO favorites (telegram_id, anime_id, anime_title, anime_year, genres, created_at) VALUES (?, ?, ?, ?, ?, ?)`,
		telegramID, anime.MalID, anime.Title, anime.Year, genreNames(anime.Genres), time.Now().Format(time.RFC3339),
	)
	return true, err
}

// IsFavorite месанҷад, ки оё анимеи додашуда дар Севимиҳои корбар ҳаст ё не
func (d *DB) IsFavorite(telegramID int64, animeID int) (bool, error) {
	var count int
	err := d.Conn.QueryRow(`SELECT COUNT(*) FROM favorites WHERE telegram_id = ? AND anime_id = ?`, telegramID, animeID).Scan(&count)
	return count > 0, err
}

// ListFavorites рӯйхати Севимиҳои корбарро мегардонад (аз нав ба кӯҳна)
func (d *DB) ListFavorites(telegramID int64) ([]models.Favorite, error) {
	rows, err := d.Conn.Query(
		`SELECT anime_id, anime_title, COALESCE(anime_year, 0), COALESCE(genres, '') FROM favorites WHERE telegram_id = ? ORDER BY created_at DESC`,
		telegramID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var favorites []models.Favorite
	for rows.Next() {
		var f models.Favorite
		if err := rows.Scan(&f.AnimeID, &f.Title, &f.Year, &f.Genres); err != nil {
			return nil, err
		}
		favorites = append(favorites, f)
	}
	return favorites, rows.Err()
}

// SetWatchStatus ҳолати тамошои анимеро барои корбар танзим мекунад (upsert)
func (d *DB) SetWatchStatus(telegramID int64, anime models.Anime, status models.WatchStatus) error {
	now := time.Now().Format(time.RFC3339)
	_, err := d.Conn.Exec(`
		INSERT INTO watch_history (telegram_id, anime_id, anime_title, anime_year, status, total_episodes, genres, updated_at, created_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(telegram_id, anime_id) DO UPDATE SET
			status = excluded.status,
			anime_title = excluded.anime_title,
			anime_year = excluded.anime_year,
			total_episodes = excluded.total_episodes,
			genres = excluded.genres,
			updated_at = excluded.updated_at
	`, telegramID, anime.MalID, anime.Title, anime.Year, string(status), anime.Episodes, genreNames(anime.Genres), now, now)
	return err
}

// GetWatchStatus ҳолати ҷории тамошои корбарро барои як аниме мегардонад (агар вуҷуд дошта бошад)
func (d *DB) GetWatchStatus(telegramID int64, animeID int) (models.WatchStatus, error) {
	var status string
	err := d.Conn.QueryRow(`SELECT status FROM watch_history WHERE telegram_id = ? AND anime_id = ?`, telegramID, animeID).Scan(&status)
	if err == sql.ErrNoRows {
		return "", nil
	}
	if err != nil {
		return "", err
	}
	return models.WatchStatus(status), nil
}

// ListWatchByStatus рӯйхати аниме-ҳоро мутобиқи ҳолати тамошо мегардонад
func (d *DB) ListWatchByStatus(telegramID int64, status models.WatchStatus) ([]models.WatchEntry, error) {
	rows, err := d.Conn.Query(
		`SELECT anime_id, anime_title, COALESCE(anime_year, 0), status, total_episodes, COALESCE(genres, '')
		 FROM watch_history WHERE telegram_id = ? AND status = ? ORDER BY updated_at DESC`,
		telegramID, string(status),
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var entries []models.WatchEntry
	for rows.Next() {
		var e models.WatchEntry
		var statusStr string
		if err := rows.Scan(&e.AnimeID, &e.Title, &e.Year, &statusStr, &e.TotalEpisodes, &e.Genres); err != nil {
			return nil, err
		}
		e.Status = models.WatchStatus(statusStr)
		entries = append(entries, e)
	}
	return entries, rows.Err()
}

// LogRecentlyViewed дидани анимеро сабт мекунад ва танҳо 10-тои охиринро нигоҳ медорад
func (d *DB) LogRecentlyViewed(telegramID int64, anime models.Anime) error {
	now := time.Now().Format(time.RFC3339)
	_, err := d.Conn.Exec(`
		INSERT INTO recently_viewed (telegram_id, anime_id, anime_title, anime_year, viewed_at)
		VALUES (?, ?, ?, ?, ?)
		ON CONFLICT(telegram_id, anime_id) DO UPDATE SET viewed_at = excluded.viewed_at
	`, telegramID, anime.MalID, anime.Title, anime.Year, now)
	if err != nil {
		return err
	}

	_, err = d.Conn.Exec(`
		DELETE FROM recently_viewed WHERE telegram_id = ? AND id NOT IN (
			SELECT id FROM recently_viewed WHERE telegram_id = ? ORDER BY viewed_at DESC LIMIT 10
		)
	`, telegramID, telegramID)
	return err
}

// ListRecentlyViewed рӯйхати анимеҳои ба наздикӣ дидашударо мегардонад
func (d *DB) ListRecentlyViewed(telegramID int64, limit int) ([]models.RecentlyViewed, error) {
	if limit <= 0 {
		limit = 10
	}
	rows, err := d.Conn.Query(
		`SELECT anime_id, anime_title, COALESCE(anime_year, 0) FROM recently_viewed WHERE telegram_id = ? ORDER BY viewed_at DESC LIMIT ?`,
		telegramID, limit,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []models.RecentlyViewed
	for rows.Next() {
		var r models.RecentlyViewed
		if err := rows.Scan(&r.AnimeID, &r.Title, &r.Year); err != nil {
			return nil, err
		}
		items = append(items, r)
	}
	return items, rows.Err()
}

// GetProfileStats омори шахсии корбарро барои саҳифаи профил ҷамъ мекунад
func (d *DB) GetProfileStats(telegramID int64) (*models.ProfileStats, error) {
	user, err := d.GetUserByTelegramID(telegramID)
	if err != nil {
		return nil, err
	}
	stats := &models.ProfileStats{}
	if user != nil {
		stats.Language = user.Language
		stats.RegisteredAt = user.CreatedAt.Format("02.01.2006")
	}

	if err := d.Conn.QueryRow(`SELECT COUNT(*) FROM favorites WHERE telegram_id = ?`, telegramID).Scan(&stats.FavoritesCount); err != nil {
		return nil, err
	}
	if err := d.Conn.QueryRow(`SELECT COUNT(*) FROM watch_history WHERE telegram_id = ? AND status = ?`, telegramID, string(models.StatusWatching)).Scan(&stats.WatchingCount); err != nil {
		return nil, err
	}
	if err := d.Conn.QueryRow(`SELECT COUNT(*) FROM watch_history WHERE telegram_id = ? AND status = ?`, telegramID, string(models.StatusCompleted)).Scan(&stats.CompletedCount); err != nil {
		return nil, err
	}

	var totalEpisodes sql.NullInt64
	if err := d.Conn.QueryRow(`SELECT SUM(total_episodes) FROM watch_history WHERE telegram_id = ? AND status = ?`, telegramID, string(models.StatusCompleted)).Scan(&totalEpisodes); err != nil {
		return nil, err
	}
	stats.TotalEpisodes = int(totalEpisodes.Int64)

	stats.TopGenres, err = d.topGenres(telegramID)
	if err != nil {
		return nil, err
	}

	return stats, nil
}

// topGenres 3 жанри бештар вохӯрдаро дар Севимиҳо ва таърихи тамошои корбар меёбад
func (d *DB) topGenres(telegramID int64) ([]string, error) {
	rows, err := d.Conn.Query(`
		SELECT genres FROM favorites WHERE telegram_id = ? AND genres != ''
		UNION ALL
		SELECT genres FROM watch_history WHERE telegram_id = ? AND genres != ''
	`, telegramID, telegramID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	counts := make(map[string]int)
	var order []string
	for rows.Next() {
		var genresStr string
		if err := rows.Scan(&genresStr); err != nil {
			return nil, err
		}
		for _, g := range strings.Split(genresStr, ",") {
			g = strings.TrimSpace(g)
			if g == "" {
				continue
			}
			if _, seen := counts[g]; !seen {
				order = append(order, g)
			}
			counts[g]++
		}
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// 3 жанри бо шумораи бештарро мечинем (тартиби содда, рӯйхат хурд аст)
	top := make([]string, 0, 3)
	for len(top) < 3 && len(order) > 0 {
		bestIdx, bestCount := 0, -1
		for i, g := range order {
			if counts[g] > bestCount {
				bestIdx, bestCount = i, counts[g]
			}
		}
		top = append(top, order[bestIdx])
		order = append(order[:bestIdx], order[bestIdx+1:]...)
	}
	return top, nil
}
