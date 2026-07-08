package config

import (
	"bufio"
	"os"
	"strconv"
	"strings"
)

// loadDotEnv хонда мешавад файли .env-ро (агар мавҷуд бошад) ва
// қиматҳоро ба муҳити система (environment) илова мекунад, вале
// қиматҳои аллакай мавҷудбударо иваз намекунад.
func loadDotEnv(path string) {
	file, err := os.Open(path)
	if err != nil {
		// Файли .env ихтиёрӣ аст — агар набошад, идома медиҳем
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}
		key := strings.TrimSpace(parts[0])
		value := strings.TrimSpace(parts[1])
		value = strings.Trim(value, `"'`)

		if _, exists := os.LookupEnv(key); !exists {
			os.Setenv(key, value)
		}
	}
}

func getEnv(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return fallback
}

// defaultRequiredChannels спонсорҳое, ки соҳиби бот дархост кардааст — корбар
// бояд ба ин каналҳо обуна бошад, то бот кор кунад. Тавассути REQUIRED_CHANNELS
// (бо вергул ҷудошуда) дар Render метавон инро бе тағйири код иваз кард
var defaultRequiredChannels = []string{
	"tajikshop1",
	"tajiktop",
	"afsonaishab",
	"NARUTO_DOUBLE_FARSI",
	"ANIME_TJK_1",
}

// parseRequiredChannels номи каналҳоро аз рӯи вергул ҷудо мекунад ва ба
// шакли "@username" меорад
func parseRequiredChannels(raw string) []string {
	if strings.TrimSpace(raw) == "" {
		channels := make([]string, len(defaultRequiredChannels))
		for i, c := range defaultRequiredChannels {
			channels[i] = "@" + c
		}
		return channels
	}

	var channels []string
	for _, part := range strings.Split(raw, ",") {
		name := strings.TrimSpace(part)
		name = strings.TrimPrefix(name, "https://t.me/")
		name = strings.TrimPrefix(name, "@")
		if name == "" {
			continue
		}
		channels = append(channels, "@"+name)
	}
	return channels
}

// parseAdminChatID ID-и Telegram-и админро аз сатр мегирад. Агар холӣ ё
// нодуруст бошад, 0 бармегардонад — дар ин ҳолат хусусияти "гуфтугӯ бо
// админ" ғайрифаъол мемонад, на ин ки боти пурраро вайрон кунад
func parseAdminChatID(raw string) int64 {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return 0
	}
	id, err := strconv.ParseInt(raw, 10, 64)
	if err != nil {
		return 0
	}
	return id
}

// LoadConfig .env-ро мехонад ва объекти Config-ро бармегардонад
func LoadConfig() *Config {
	loadDotEnv(".env")

	return &Config{
		TelegramToken:    getEnv("TELEGRAM_BOT_TOKEN", ""),
		JikanBaseURL:     getEnv("JIKAN_BASE_URL", "https://api.jikan.moe/v4"),
		DBPath:           getEnv("DB_PATH", "./data/anime.db"),
		DefaultLanguage:  getEnv("DEFAULT_LANGUAGE", "en"),
		Debug:            getEnv("DEBUG", "false") == "true",
		Port:             getEnv("PORT", "10000"),
		YouTubeAPIKey:    getEnv("YOUTUBE_API_KEY", ""),
		RequiredChannels: parseRequiredChannels(getEnv("REQUIRED_CHANNELS", "")),
		AdminChatID:      parseAdminChatID(getEnv("ADMIN_CHAT_ID", "")),
		PublicBaseURL:    strings.TrimSuffix(getEnv("RENDER_EXTERNAL_URL", ""), "/"),
		WorldCupEmail:    getEnv("WORLDCUP_API_EMAIL", ""),
		WorldCupPassword: getEnv("WORLDCUP_API_PASSWORD", ""),
	}
}
