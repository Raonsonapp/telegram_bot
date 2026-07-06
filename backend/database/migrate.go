package database

import "fmt"

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

	CREATE TABLE IF NOT EXISTS search_history (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		telegram_id INTEGER NOT NULL,
		query TEXT NOT NULL,
		created_at TEXT NOT NULL
	);

	CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);
	CREATE INDEX IF NOT EXISTS idx_favorites_telegram_id ON favorites(telegram_id);
	`

	if _, err := db.Conn.Exec(schema); err != nil {
		return fmt.Errorf("migration failed: %w", err)
	}
	return nil
}
