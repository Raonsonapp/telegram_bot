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
// оянда бидонем, ки ӯ аллакай ҳадди 1 репоро истифода кардааст. Идемпотент
// аст (UPSERT) — дархости такрорӣ хатои UNIQUE constraint намедиҳад
func (d *DB) SaveUserRepo(telegramID int64, fullName, url string) error {
	_, err := d.Conn.Exec(
		`INSERT INTO app_builder_repos (telegram_id, repo_full_name, repo_url, created_at) VALUES (?, ?, ?, ?)
		 ON CONFLICT(telegram_id) DO UPDATE SET repo_full_name = excluded.repo_full_name, repo_url = excluded.repo_url`,
		telegramID, fullName, url, time.Now().Format(time.RFC3339),
	)
	return err
}

// DeleteUserRepo нақшаи репои корбарро тоза мекунад — масалан баъд аз
// кӯчонидани репо ба GitHub-и худи корбар (бот дигар ба он дастрасӣ надорад),
// то дафъаи оянда "Барномасоз" аз аввал (репои нав дар зери бот) сар шавад
func (d *DB) DeleteUserRepo(telegramID int64) error {
	_, err := d.Conn.Exec(`DELETE FROM app_builder_repos WHERE telegram_id = ?`, telegramID)
	return err
}
