package main

import (
	"log"
	"strings"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/config"
	"anime-bot/backend/database"
	"anime-bot/backend/handlers"
	"anime-bot/backend/utils"
)

func main() {
	cfg := config.LoadConfig()
	utils.DebugEnabled = cfg.Debug

	if cfg.TelegramToken == "" {
		log.Fatal("TELEGRAM_BOT_TOKEN нест дар .env — лутфан онро танзим кунед")
	}

	bot, err := tgbotapi.NewBotAPI(cfg.TelegramToken)
	if err != nil {
		log.Fatalf("Хатогӣ ҳангоми пайвастшавӣ ба Telegram: %v", err)
	}
	bot.Debug = cfg.Debug
	utils.LogInfo("Бот оғоз шуд: @%s", bot.Self.UserName)

	db, err := database.Init(cfg.DBPath)
	if err != nil {
		log.Fatalf("Хатогии пойгоҳи додаҳо: %v", err)
	}
	defer db.Close()

	if err := database.Migrate(db); err != nil {
		log.Fatalf("Хатогии миграция: %v", err)
	}
	utils.LogInfo("Пойгоҳи додаҳо омода аст: %s", cfg.DBPath)

	jikanClient := api.NewJikanClient(cfg.JikanBaseURL)
	cache := utils.NewCache(10 * time.Minute)

	deps := &handlers.Deps{
		Bot:    bot,
		DB:     db,
		Jikan:  jikanClient,
		Cache:  cache,
		Config: cfg,
	}

	updateConfig := tgbotapi.NewUpdate(0)
	updateConfig.Timeout = 30
	updates := bot.GetUpdatesChan(updateConfig)

	utils.LogInfo("Бот омода аст ва дархостҳоро мегирад...")

	for update := range updates {
		go routeUpdate(deps, update)
	}
}

// routeUpdate ҳар як update-и воридотиро ба handler-и дурусташ равона мекунад
func routeUpdate(d *handlers.Deps, update tgbotapi.Update) {
	defer func() {
		if r := recover(); r != nil {
			utils.LogError("panic recovered in routeUpdate: %v", r)
		}
	}()

	if update.CallbackQuery != nil {
		routeCallback(d, update.CallbackQuery)
		return
	}

	if update.Message == nil {
		return
	}

	msg := update.Message

	if msg.IsCommand() {
		routeCommand(d, msg)
		return
	}

	routeText(d, msg)
}

// routeCommand фармонҳои /start, /search, /random, /top, /settings, /help-ро равона мекунад
func routeCommand(d *handlers.Deps, msg *tgbotapi.Message) {
	switch msg.Command() {
	case "start":
		handlers.HandleStart(d, msg)
	case "search":
		handlers.HandleSearchCommand(d, msg)
	case "random":
		handlers.HandleRandomAnime(d, msg)
	case "top":
		handlers.HandleTopAnime(d, msg)
	case "settings":
		handlers.HandleSettings(d, msg)
	case "help":
		handlers.HandleHelp(d, msg)
	default:
		handlers.HandleStart(d, msg)
	}
}

// routeText паёмҳои матнии оддиро (на фармон) равона мекунад — тугмаҳои менюи асосӣ
// ва матни ҷустуҷӯи аниме дар инҷо коркард мешаванд
func routeText(d *handlers.Deps, msg *tgbotapi.Message) {
	text := strings.TrimSpace(msg.Text)
	if text == "" {
		return
	}

	// Санҷиши мутобиқат бо тугмаҳои менюи асосӣ дар ҳар се забон
	for _, lang := range []string{"en", "ru", "fa"} {
		switch text {
		case buttonLabel(lang, "btn_search"):
			handlers.HandleSearchButton(d, msg)
			return
		case buttonLabel(lang, "btn_random"):
			handlers.HandleRandomAnime(d, msg)
			return
		case buttonLabel(lang, "btn_top"):
			handlers.HandleTopAnime(d, msg)
			return
		case buttonLabel(lang, "btn_settings"):
			handlers.HandleSettings(d, msg)
			return
		case buttonLabel(lang, "btn_help"):
			handlers.HandleHelp(d, msg)
			return
		}
	}

	// Агар корбар дар ҳолати "мунтазири ҷустуҷӯ" бошад ё на, ба ҳар ҳол
	// матни фиристодашударо ҳамчун дархости ҷустуҷӯи аниме мешуморем
	handlers.HandlePlainTextSearch(d, msg)
}

// routeCallback callback query-ҳоро (тугмаҳои inline) равона мекунад
func routeCallback(d *handlers.Deps, cb *tgbotapi.CallbackQuery) {
	data := cb.Data
	switch {
	case strings.HasPrefix(data, "lang:"):
		handlers.HandleLanguageCallback(d, cb)
	case strings.HasPrefix(data, "anime:"):
		handlers.HandleAnimeCallback(d, cb)
	case strings.HasPrefix(data, "episodes:"):
		handlers.HandleEpisodesCallback(d, cb)
	case strings.HasPrefix(data, "settings:"):
		handlers.HandleSettingsCallback(d, cb)
	case data == "back:menu":
		handlers.HandleBackToMenu(d, cb)
	default:
		callback := tgbotapi.NewCallback(cb.ID, "")
		d.Bot.Request(callback)
	}
}

func buttonLabel(lang, key string) string {
	return api.GetMessage(lang, key)
}
