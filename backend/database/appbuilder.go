package database

import (
	"database/sql"
	"time"
)

// UserRepo репои App Builder-и як корбарро ифода мекунад
type UserRepo struct {
	FullName string
	URL      string
}

// GetUserRepo репои сохтаи корбарро (агар аллакай сохта бошад) бармегардонад.
// nil бармегардонад, агар корбар ҳанӯз ягон репо насохта бошад
func (d *DB) GetUserRepo(telegramID int64) (*UserRepo, error) {
	row := d.Conn.QueryRow(
		`SELECT repo_full_name, repo_url FROM app_builder_repos WHERE telegram_id = ?`,
		telegramID,
	)
	var r UserRepo
	err := row.Scan(&r.FullName, &r.URL)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &r, nil
}

// SaveUserRepo сабт мекунад, ки ин корбар кадом репоро сохтааст — то дафъаи
// оянда бидонем, ки ӯ аллакай ҳадди 1 репоро истифода кардааст
func (d *DB) SaveUserRepo(telegramID int64, fullName, url string) error {
	_, err := d.Conn.Exec(
		`INSERT INTO app_builder_repos (telegram_id, repo_full_name, repo_url, created_at) VALUES (?, ?, ?, ?)`,
		telegramID, fullName, url, time.Now().Format(time.RFC3339),
	)
	return err
}
