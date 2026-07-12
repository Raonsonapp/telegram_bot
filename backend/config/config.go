package config

// Config нигоҳ медорад тамоми танзимоти бот
type Config struct {
	TelegramToken    string
	JikanBaseURL     string
	DBPath           string
	DefaultLanguage  string
	Debug            bool
	Port             string
	YouTubeAPIKey    string
	RequiredChannels []string
	// SponsorEnabled нишон медиҳад, ки оё gate-и обунаи ҳатмӣ (спонсор)
	// фаъол аст. Ин ба корбар имкон медиҳад, ки спонсорро муваққатан
	// хомӯш кунад (масалан барои демо) БЕ пок кардани рӯйхати каналҳо —
	// то баъдтар танҳо бо як тағйири env дубора фаъол кунад
	SponsorEnabled   bool
	AdminChatID      int64
	PublicBaseURL    string
	WorldCupEmail    string
	WorldCupPassword string
	GitHubAppToken   string
	OpenRouterToken  string
	OpenRouterModel  string
}
