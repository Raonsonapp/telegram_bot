package models

// UserSettings танзимоти иловагии корбар
type UserSettings struct {
	TelegramID    int64
	Language      string
	Notifications bool
}

// SupportedLanguages рӯйхати забонҳое, ки бот дастгирӣ мекунад
var SupportedLanguages = map[string]string{
	"en": "English 🇬🇧",
	"ru": "Русский 🇷🇺",
	"fa": "فارسی 🇮🇷",
}

// DefaultSettings танзимоти пешфарз барои корбари нав
func DefaultSettings(telegramID int64) UserSettings {
	return UserSettings{
		TelegramID:    telegramID,
		Language:      "en",
		Notifications: true,
	}
}
