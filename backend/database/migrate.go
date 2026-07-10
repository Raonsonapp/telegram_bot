package database

import (
	"fmt"
	"strings"
)

// Migrate ҷадвалҳои заруриро дар SQLite месозад (агар мавҷуд набошанд)
func Migrate(db *DB) error {
	schema := `
	CREATE TABLE IF NOT EXISTS users (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		telegram_id INTEGER UNIQUE NOT NULL,
		username TEXT,
		language TEXT NOT NULL DEFAULT 'en',
		created_at TEXT NOT NULL
	);

	CREATE TABLE IF NOT EXISTS favorites (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		telegram_id INTEGER NOT NULL,
		anime_id INTEGER NOT NULL,
		anime_title TEXT,
		created_at TEXT NOT NULL,
		UNIQUE(telegram_id, anime_id)
	);

	CREATE TABLE IF NOT EXISTS watch_history (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		telegram_id INTEGER NOT NULL,
		anime_id INTEGER NOT NULL,
		anime_title TEXT,
		anime_year INTEGER,
		status TEXT NOT NULL,
		total_episodes INTEGER NOT NULL DEFAULT 0,
		genres TEXT,
		updated_at TEXT NOT NULL,
		created_at TEXT NOT NULL,
		UNIQUE(telegram_id, anime_id)
	);

	CREATE TABLE IF NOT EXISTS recently_viewed (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		telegram_id INTEGER NOT NULL,
		anime_id INTEGER NOT NULL,
		anime_title TEXT,
		anime_year INTEGER,
		viewed_at TEXT NOT NULL,
		UNIQUE(telegram_id, anime_id)
	);

	CREATE TABLE IF NOT EXISTS search_history (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		telegram_id INTEGER NOT NULL,
		query TEXT NOT NULL,
		created_at TEXT NOT NULL
	);

	CREATE TABLE IF NOT EXISTS app_builder_repos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		telegram_id INTEGER UNIQUE NOT NULL,
		repo_full_name TEXT NOT NULL,
		repo_url TEXT NOT NULL,
		created_at TEXT NOT NULL
	);

	CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);
	CREATE INDEX IF NOT EXISTS idx_favorites_telegram_id ON favorites(telegram_id);
	CREATE INDEX IF NOT EXISTS idx_watch_history_telegram_id ON watch_history(telegram_id);
	CREATE INDEX IF NOT EXISTS idx_recently_viewed_telegram_id ON recently_viewed(telegram_id);
	CREATE INDEX IF NOT EXISTS idx_app_builder_repos_telegram_id ON app_builder_repos(telegram_id);
	`

	if _, err := db.Conn.Exec(schema); err != nil {
		return fmt.Errorf("migration failed: %w", err)
	}

	// favorites-и кӯҳна бе сол ва жанр сохта шуда буд — инҳоро иловатан илова мекунем
	for _, stmt := range []string{
		`ALTER TABLE favorites ADD COLUMN anime_year INTEGER`,
		`ALTER TABLE favorites ADD COLUMN genres TEXT`,
	} {
		if _, err := db.Conn.Exec(stmt); err != nil && !strings.Contains(err.Error(), "duplicate column") {
			return fmt.Errorf("migration failed: %w", err)
		}
	}

	return nil
}
