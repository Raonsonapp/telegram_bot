package database

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"anime-bot/models"

	_ "modernc.org/sqlite"
)

// DB печонандаи *sql.DB бо методҳои дархости корбарон
type DB struct {
	Conn *sql.DB
}

// Init пайвастшавӣ ба SQLite-ро месозад ва папкаи лозимаро эҷод мекунад
func Init(path string) (*DB, error) {
	dir := filepath.Dir(path)
	if dir != "." && dir != "" {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return nil, fmt.Errorf("failed to create db directory: %w", err)
		}
	}

	conn, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, fmt.Errorf("failed to open sqlite db: %w", err)
	}

	if err := conn.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping sqlite db: %w", err)
	}

	return &DB{Conn: conn}, nil
}

// Close пайвастшавиро мебандад
func (d *DB) Close() error {
	return d.Conn.Close()
}

// GetUserByTelegramID корбарро аз рӯи telegram_id меёбад
func (d *DB) GetUserByTelegramID(telegramID int64) (*models.User, error) {
	row := d.Conn.QueryRow(
		`SELECT id, telegram_id, username, language, created_at FROM users WHERE telegram_id = ?`,
		telegramID,
	)

	var u models.User
	var createdAt string
	err := row.Scan(&u.ID, &u.TelegramID, &u.Username, &u.Language, &createdAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	u.CreatedAt, _ = time.Parse(time.RFC3339, createdAt)
	return &u, nil
}

// CreateUser корбари навро дар пойгоҳи додаҳо эҷод мекунад
func (d *DB) CreateUser(telegramID int64, username string, language string) (*models.User, error) {
	now := time.Now().Format(time.RFC3339)
	res, err := d.Conn.Exec(
		`INSERT INTO users (telegram_id, username, language, created_at) VALUES (?, ?, ?, ?)`,
		telegramID, username, language, now,
	)
	if err != nil {
		return nil, err
	}
	id, _ := res.LastInsertId()
	return &models.User{
		ID:         id,
		TelegramID: telegramID,
		Username:   username,
		Language:   language,
	}, nil
}

// UpdateLanguage забони корбарро иваз мекунад
func (d *DB) UpdateLanguage(telegramID int64, language string) error {
	_, err := d.Conn.Exec(
		`UPDATE users SET language = ? WHERE telegram_id = ?`,
		language, telegramID,
	)
	return err
}

// GetOrCreateUser корбарро мегардонад ё агар вуҷуд надошта бошад, месозад
func (d *DB) GetOrCreateUser(telegramID int64, username string, defaultLang string) (*models.User, bool, error) {
	user, err := d.GetUserByTelegramID(telegramID)
	if err != nil {
		return nil, false, err
	}
	if user != nil {
		return user, false, nil
	}
	user, err = d.CreateUser(telegramID, username, defaultLang)
	if err != nil {
		return nil, false, err
	}
	return user, true, nil
}
