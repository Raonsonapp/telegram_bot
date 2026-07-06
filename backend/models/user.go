package models

import "time"

// User намояндаи корбари бот дар пойгоҳи додаҳо
type User struct {
	ID         int64
	TelegramID int64
	Username   string
	Language   string
	CreatedAt  time.Time
}
