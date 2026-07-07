package main

import (
	"log"
	"net/http"
	"os"
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
		log.Fatal("TELEGRAM_BOT_TOKEN нест дар муҳити система — лутфан онро дар Render Environment Variables танзим кунед")
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
	anilistClient := api.NewAniListClient()
	animeProvider := api.NewAnimeProvider(jikanClient, anilistClient)
	aparatClient := api.NewAparatClient()
	dailymotionClient := api.NewDailymotionClient()
	youtubeClient := api.NewYouTubeClient(cfg.YouTubeAPIKey)
	if youtubeClient.Enabled() {
		utils.LogInfo("YouTube: манбаи видео фаъол аст")
	} else {
		utils.LogInfo("YouTube: YOUTUBE_API_KEY танзим нашудааст, ин манбаъ ғайрифаъол мемонад")
	}
	translator := utils.NewTranslator()
	cache := utils.NewCache(10 * time.Minute)

	deps := &handlers.Deps{
		Bot:         bot,
		DB:          db,
		Jikan:       animeProvider,
		Aparat:      aparatClient,
		Dailymotion: dailymotionClient,
		YouTube:     youtubeClient,
		Translator:  translator,
		Cache:       cache,
		Config:      cfg,
	}

	var updates <-chan tgbotapi.Update

	// Render зинаи "zero-downtime deploy" дорад: ҳангоми ҳар деплой нусхаи кӯҳна
	// ва нав муддате ҳамзамон кор мекунанд. Бо long polling (getUpdates) ин ба
	// хатои "Conflict: terminated by other getUpdates request" оварда мерасонад,
	// зеро Telegram танҳо як истеъмолкунандаро иҷозат медиҳад. Webhook ин
	// мушкилотро пурра бартараф мекунад — Telegram худ ба сервери мо мефиристад,
	// новобаста аз он ки чанд нусха ҳамзамон кор мекунанд
	externalURL := strings.TrimSuffix(os.Getenv("RENDER_EXTERNAL_URL"), "/")
	if externalURL != "" {
		webhookPath := "/webhook/" + cfg.TelegramToken
		webhookURL := externalURL + webhookPath

		webhookConfig, err := tgbotapi.NewWebhook(webhookURL)
		if err != nil {
			log.Fatalf("Хатогии сохтани webhook: %v", err)
		}
		webhookConfig.DropPendingUpdates = true

		if _, err := bot.Request(webhookConfig); err != nil {
			log.Fatalf("Хатогии танзими webhook: %v", err)
		}
		utils.LogInfo("Webhook танзим шуд: %s", webhookURL)

		updatesChan := make(chan tgbotapi.Update, 100)
		updates = updatesChan
		startServer(cfg.Port, webhookPath, bot, updatesChan)
	} else {
		// Дар муҳити маҳаллӣ (беруна аз Render) webhook надорем — агар қаблан
		// монда бошад, тоза мекунем, вагарна getUpdates хато медиҳад
		if _, err := bot.Request(tgbotapi.DeleteWebhookConfig{}); err != nil {
			utils.LogError("failed to delete webhook: %v", err)
		}
		startServer(cfg.Port, "", bot, nil)

		updateConfig := tgbotapi.NewUpdate(0)
		updateConfig.Timeout = 30
		updates = bot.GetUpdatesChan(updateConfig)
	}

	utils.LogInfo("Бот омода аст ва дархостҳоро мегирад...")

	for update := range updates {
		go routeUpdate(deps, update)
	}
}

// startServer HTTP-серверро дар goroutine оғоз мекунад: "/" ва "/health" барои
// Render health check, ва агар webhookPath холӣ набошад — суроғаи қабули
// webhook-и Telegram низ дар ҳамин сервер (бо ҳамин порт) кушода мешавад
func startServer(port string, webhookPath string, bot *tgbotapi.BotAPI, updates chan tgbotapi.Update) {
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Anime Bot Running"))
	})
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})

	if webhookPath != "" {
		mux.HandleFunc(webhookPath, func(w http.ResponseWriter, r *http.Request) {
			webhookUpdates := bot.ListenForWebhookRespReqFormat(w, r)
			for update := range webhookUpdates {
				updates <- update
			}
		})
	}

	go func() {
		addr := ":" + port
		utils.LogInfo("HTTP-сервер дар порти %s оғоз шуд (барои Render health check ва webhook)", port)
		if err := http.ListenAndServe(addr, mux); err != nil {
			utils.LogError("Хатогии HTTP-сервер: %v", err)
		}
	}()
}

// routeUpdate ҳар як update-и воридотиро ба handler-и дурусташ равона мекунад
func routeUpdate(d *handlers.Deps, update tgbotapi.Update) {
	defer func() {
		if r := recover(); r != nil {
			utils.LogError("panic recovered in routeUpdate: %v", r)
		}
	}()

	if update.CallbackQuery != nil {
		cb := update.CallbackQuery
		if cb.Data == "checksub" {
			handlers.HandleCheckSubscriptionCallback(d, cb)
			return
		}
		if subscribed, _ := handlers.CheckSubscription(d, cb.From.ID); !subscribed {
			handlers.HandleBlockedCallback(d, cb)
			return
		}
		routeCallback(d, cb)
		return
	}

	if update.Message == nil {
		return
	}

	msg := update.Message

	// Агар ин ҷавоби админ ба паёми фиристодашудаи корбар бошад, онро ба
	// корбар мефиристем ва аз коркарди минбаъда мегузарем (админ аз обунаи
	// ҳатмӣ низ озод аст)
	if handlers.HandleAdminReply(d, msg) {
		return
	}

	if msg.Chat.ID != d.Config.AdminChatID {
		if !handlers.EnsureSubscribed(d, msg.From.ID, msg.Chat.ID) {
			return
		}
	}

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
	case "profile":
		handlers.HandleProfileButton(d, msg)
	case "myid":
		handlers.HandleMyID(d, msg)
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
		case buttonLabel(lang, "btn_mood"):
			handlers.HandleMoodButton(d, msg)
			return
		case buttonLabel(lang, "btn_dub_menu"):
			handlers.HandleDubMenuButton(d, msg)
			return
		case buttonLabel(lang, "btn_top"):
			handlers.HandleTopAnime(d, msg)
			return
		case buttonLabel(lang, "btn_settings"):
			handlers.HandleSettings(d, msg)
			return
		case buttonLabel(lang, "btn_profile"):
			handlers.HandleProfileButton(d, msg)
			return
		case buttonLabel(lang, "btn_feedback"):
			handlers.HandleFeedbackButton(d, msg)
			return
		case buttonLabel(lang, "btn_help"):
			handlers.HandleHelp(d, msg)
			return
		}
	}

	// Агар корбар пас аз пахши "🎭 Аз рӯи кайфият пешниҳод кун" матн фиристода бошад,
	// онро ҳамчун тавсифи кайфият коркард мекунем, на ҳамчун номи аниме
	if handlers.PendingMood[msg.From.ID] {
		handlers.HandleMoodText(d, msg)
		return
	}

	// Агар корбар пас аз пахши "🎬 Дубляж ёфт кун" (менюи асосӣ) матн фиристода
	// бошад, онро ҳамчун номи анимеи ҷустуҷӯшаванда барои дубляж коркард мекунем
	if handlers.PendingDub[msg.From.ID] {
		handlers.HandleDubTextQuery(d, msg)
		return
	}

	// Агар корбар пас аз пахши "💬 Бо админ гап зан" матн фиристода бошад,
	// онро ба админ мефиристем
	if handlers.PendingFeedback[msg.From.ID] {
		handlers.HandleFeedbackText(d, msg)
		return
	}

	// Дар ҳолати дигар, матни фиристодашударо ҳамчун дархости ҷустуҷӯи аниме мешуморем
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
	case strings.HasPrefix(data, "seasons:"):
		handlers.HandleSeasonMenuCallback(d, cb)
	case strings.HasPrefix(data, "seasondub:"):
		handlers.HandleSeasonDubCallback(d, cb)
	case strings.HasPrefix(data, "season:"):
		handlers.HandleSeasonEpisodesCallback(d, cb)
	case strings.HasPrefix(data, "settings:"):
		handlers.HandleSettingsCallback(d, cb)
	case strings.HasPrefix(data, "fav:"):
		handlers.HandleFavoriteCallback(d, cb)
	case strings.HasPrefix(data, "dub:"):
		handlers.HandleDubCallback(d, cb)
	case strings.HasPrefix(data, "watch:"):
		handlers.HandleWatchStatusCallback(d, cb)
	case strings.HasPrefix(data, "profile:"):
		handlers.HandleProfileCallback(d, cb)
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
