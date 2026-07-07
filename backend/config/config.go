package config

// Config нигоҳ медорад тамоми танзимоти боти Telegram-и аниме
type Config struct {
	TelegramToken    string
	JikanBaseURL     string
	DBPath           string
	DefaultLanguage  string
	Debug            bool
	Port             string
	YouTubeAPIKey    string
	RequiredChannels []string
	AdminChatID      int64
	PublicBaseURL    string
}
