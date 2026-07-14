package main

import (
	"fmt"
	"html"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/config"
	"appbuilder-bot/backend/database"
	"appbuilder-bot/backend/handlers"
	"appbuilder-bot/backend/utils"
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
	currencyClient := api.NewCurrencyClient()
	worldCupClient := api.NewWorldCupClient(cfg.WorldCupEmail, cfg.WorldCupPassword)
	gitHubAppClient := api.NewGitHubAppClient(cfg.GitHubAppToken)
	if gitHubAppClient.Enabled() {
		utils.LogInfo("App Builder: GitHub integration фаъол аст")
	} else {
		utils.LogInfo("App Builder: GITHUB_APP_BUILDER_TOKEN танзим нашудааст, ин хусусият ғайрифаъол мемонад")
	}

	aiCoderClient := api.NewAICoderClient(cfg.OpenRouterToken, cfg.OpenRouterModel)
	if aiCoderClient.Enabled() {
		utils.LogInfo("App Builder: сохтани экрани AI (Qwen тавассути OpenRouter) фаъол аст")
	} else {
		utils.LogInfo("App Builder: OPENROUTER_API_KEY танзим нашудааст, репо бе экрани AI сохта мешавад")
	}

	if cfg.AdminChatID != 0 {
		utils.LogInfo("Admin: ADMIN_CHAT_ID хонда шуд = %d — паёмҳои \"Бо админ гап зан\" ба ин чат мераванд", cfg.AdminChatID)
	} else {
		utils.LogInfo("Admin: ADMIN_CHAT_ID танзим нашудааст (холӣ ё нодуруст) — хусусияти \"Бо админ гап зан\" паёмро намефиристад")
	}

	if cfg.SponsorEnabled {
		utils.LogInfo("Sponsor: gate-и обуна ФАЪОЛ аст (%d канал) — барои хомӯш кардан SPONSOR_ENABLED-ро тоза кунед", len(cfg.RequiredChannels))
	} else {
		utils.LogInfo("Sponsor: gate-и обуна ХОМӮШ аст — ҳеҷ спонсор нишон дода намешавад (барои фаъол кардан SPONSOR_ENABLED=true)")
	}

	// ReferralStore маълумоти даъватҳоро дар репои давлатии GitHub (на дар
	// SQLite-и муваққатии Render) нигоҳ медорад — то бо ҳар деплой гум нашавад
	referralStore := api.NewReferralStore(gitHubAppClient)

	deps := &handlers.Deps{
		Bot:         bot,
		DB:          db,
		Jikan:       animeProvider,
		Aparat:      aparatClient,
		Dailymotion: dailymotionClient,
		YouTube:     youtubeClient,
		Currency:    currencyClient,
		WorldCup:    worldCupClient,
		GitHubApp:   gitHubAppClient,
		AICoder:     aiCoderClient,
		Referrals:   referralStore,
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

		// Render (нақшаи ройгон) пас аз ~15 дақиқа бе фаъолият инстансро
		// хомӯш (spin down) мекунад — баъд дархости навбатӣ 30-60с (ё зиёдтар)
		// интизор мешавад, то контейнер аз нав бор шавад. Барои пешгирӣ, бот
		// ҳар 10 дақиқа худашро ping мекунад (ба /health-и худаш) — то Render
		// инстансро ҳеҷ гоҳ хомӯш накунад ва ҷавобҳо фаврӣ бошанд
		startKeepAlive(externalURL)
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
		w.Write([]byte("App Builder Bot is running"))
	})
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})
	mux.HandleFunc("/filimo", filimoLandingHandler)

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

// startKeepAlive ҳар 10 дақиқа ба /health-и худи бот дархост мефиристад, то
// Render (нақшаи ройгон) инстансро аз сабаби "бе фаъолият" хомӯш накунад.
// Ин трафики воридотии мунтазам эҷод мекунад, ки таймери idle-и Render-ро
// нав мекунад — бинобар ин бот ҳамеша "гарм" мемонад ва фаврӣ ҷавоб медиҳад
func startKeepAlive(externalURL string) {
	healthURL := externalURL + "/health"
	client := &http.Client{Timeout: 20 * time.Second}
	go func() {
		ticker := time.NewTicker(10 * time.Minute)
		defer ticker.Stop()
		for range ticker.C {
			resp, err := client.Get(healthURL)
			if err != nil {
				utils.LogError("keep-alive: ping ноком шуд: %v", err)
				continue
			}
			resp.Body.Close()
		}
	}()
	utils.LogInfo("Keep-alive фаъол шуд: ҳар 10 дақиқа %s ping мешавад (то Render хомӯш накунад)", healthURL)
}

// filimoLandingHandler саҳифаи хурди ба забони тоҷикӣ месозад, ки корбарро ба
// Filimo (агар обунаи шахсӣ дошта бошад) равона мекунад. Мо худамон видеоро
// намегирем — ин танҳо саҳифаи миёнарав бо матни тоҷикӣ аст, то таҷрибаи
// корбар аз дохили Telegram (браузери дарунсохт) оғоз шавад
func filimoLandingHandler(w http.ResponseWriter, r *http.Request) {
	title := strings.TrimSpace(r.URL.Query().Get("title"))
	heading := "Ҷустуҷӯ дар Filimo"
	if title != "" {
		heading = fmt.Sprintf("Ҷустуҷӯи \"%s\" дар Filimo", html.EscapeString(title))
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprintf(w, `<!DOCTYPE html>
<html lang="tg"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Filimo</title>
<style>
body{font-family:sans-serif;background:#111;color:#eee;text-align:center;padding:2rem 1rem}
h1{font-size:1.3rem;margin-bottom:1rem}
p{color:#aaa;line-height:1.5}
a.btn{display:inline-block;margin-top:1.5rem;padding:0.9rem 1.8rem;background:#e5322d;color:#fff;
text-decoration:none;border-radius:8px;font-weight:bold}
</style></head>
<body>
<h1>%s</h1>
<p>Filimo хизматрасонии пулакии эронист. Агар ту (ё дӯстат) обунаи он дошта бошӣ,
метавонӣ анимеро дар он ҷо ҷустуҷӯ карда тамошо кунӣ.</p>
<a class="btn" href="https://www.filimo.com" target="_blank">Кушодани Filimo</a>
</body></html>`, heading)
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

	// /myid ҳамеша бе манъ кор мекунад — вагарна ҳеҷ кас (ҳатто соҳиби бот)
	// наметавонад ID-и худро гирад, зеро барои гузаштан аз gate-и обуна маҳз
	// ҳамин ID лозим аст (мушкили "мурғ ва тухм")
	if msg.IsCommand() && msg.Command() == "myid" {
		handlers.HandleMyID(d, msg)
		return
	}

	// Агар ин /start бо payload-и линки даъват (ref_<ID>) бошад, ПЕШ АЗ
	// gate-и обунаи ҳатмӣ нигоҳ дошта мешавад — вагарна агар корбар ҳанӯз
	// обуна набошад, payload то тасдиқи обуна гум мешавад
	handlers.CapturePendingReferralArg(msg)

	if msg.Chat.ID != d.Config.AdminChatID {
		if !handlers.EnsureSubscribed(d, msg.From.ID, msg.Chat.ID) {
			return
		}
	}

	if msg.IsCommand() {
		routeCommand(d, msg)
		return
	}

	// Агар корбар пас аз пахши "🏗 Барномасоз" ва пурсидани логотип акс
	// фиристода бошад, ин ба ҷои routeText (ки матни холиро рад мекунад)
	// бояд ба HandleAppLogoPhoto равона шавад
	if len(msg.Photo) > 0 && handlers.PendingAppLogo[msg.From.ID] {
		handlers.HandleAppLogoPhoto(d, msg)
		return
	}
	// Ҳамин тавр, вале барои таҳрири логотипи барномаи МАВҶУДА (аз менюи таҳрир)
	if len(msg.Photo) > 0 && handlers.PendingAppEditLogo[msg.From.ID] {
		handlers.HandleAppEditLogoPhoto(d, msg)
		return
	}
	// Импорти код: агар корбар файли ZIP-и коди худашро фиристад
	if msg.Document != nil && handlers.PendingImportCode[msg.From.ID] {
		handlers.HandleImportCodeDocument(d, msg)
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
		case buttonLabel(lang, "btn_invite"):
			handlers.HandleInviteButton(d, msg)
			return
		case buttonLabel(lang, "btn_help"):
			handlers.HandleHelp(d, msg)
			return
		case buttonLabel(lang, "btn_tools"):
			handlers.HandleToolsMenuButton(d, msg)
			return
		case buttonLabel(lang, "btn_password_gen"):
			handlers.HandlePasswordGenButton(d, msg)
			return
		case buttonLabel(lang, "btn_qr_gen"):
			handlers.HandleQRGenButton(d, msg)
			return
		case buttonLabel(lang, "btn_currency"):
			handlers.HandleCurrencyButton(d, msg)
			return
		case buttonLabel(lang, "btn_worldcup"):
			handlers.HandleWorldCupButton(d, msg)
			return
		case buttonLabel(lang, "btn_price_calc"):
			handlers.HandlePriceCalcButton(d, msg)
			return
		case buttonLabel(lang, "btn_app_builder"):
			handlers.HandleAppBuilderButton(d, msg)
			return
		case buttonLabel(lang, "btn_fetch_apk"):
			handlers.HandleFetchAPKButton(d, msg)
			return
		case buttonLabel(lang, "btn_import_code"):
			handlers.HandleImportCodeButton(d, msg)
			return
		case buttonLabel(lang, "btn_back_to_menu"):
			handlers.HandleBackToMainMenuButton(d, msg)
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

	// Агар корбар пас аз пахши "📷 Генератори QR" матн фиристода бошад,
	// онро ба расми QR-код табдил медиҳем
	if handlers.PendingQR[msg.From.ID] {
		handlers.HandleQRGenText(d, msg)
		return
	}

	// Агар корбар пас аз пахши "💱 Мубодилаи асъор" матн фиристода бошад,
	// онро ҳамчун дархости мубодила коркард мекунем
	if handlers.PendingCurrency[msg.From.ID] {
		handlers.HandleCurrencyText(d, msg)
		return
	}

	// Зинаҳои сохтани барнома: аввал номи намоишӣ, баъд логотип (агар акс
	// нафиристода, ин ҷо ҳамчун матни гузарондан коркард мешавад), баъд
	// тавсифи функсияҳо (репои GitHub бо workflow-и build-и APK сохта мешавад)
	if handlers.PendingAppDisplayName[msg.From.ID] {
		handlers.HandleAppDisplayNameText(d, msg)
		return
	}
	if handlers.PendingAppLogo[msg.From.ID] {
		handlers.HandleAppLogoSkipText(d, msg)
		return
	}
	if handlers.PendingAppName[msg.From.ID] {
		handlers.HandleAppNameText(d, msg)
		return
	}

	// Менюи таҳрири барномаи МАВҶУДА: танҳо як қисматро иваз мекунад
	// (тавсиф/ном/логотип), то ҳар дафъа ҳамаашро аз нав напурсем
	if handlers.PendingAppEditDescription[msg.From.ID] {
		handlers.HandleAppEditDescriptionText(d, msg)
		return
	}
	if handlers.PendingAppEditName[msg.From.ID] {
		handlers.HandleAppEditNameText(d, msg)
		return
	}
	if handlers.PendingAppTransferUsername[msg.From.ID] {
		handlers.HandleAppTransferUsernameText(d, msg)
		return
	}
	if handlers.PendingAppAddFunction[msg.From.ID] {
		handlers.HandleAppAddFunctionText(d, msg)
		return
	}
	// Импорти код тавассути линки репои GitHub (агар ба ҷои ZIP матн фиристад)
	if handlers.PendingImportCode[msg.From.ID] {
		handlers.HandleImportCodeText(d, msg)
		return
	}

	// Ҳисобкунаки нарх: аввал шумораи Screen, баъд шумораи Function
	if handlers.PendingPriceScreens[msg.From.ID] {
		handlers.HandlePriceScreensText(d, msg)
		return
	}
	if handlers.PendingPriceFunctions[msg.From.ID] {
		handlers.HandlePriceFunctionsText(d, msg)
		return
	}

	// Агар корбар пас аз пахши "💬 Бо админ гап зан" матн фиристода бошад,
	// онро ба админ мефиристем
	if handlers.PendingFeedback[msg.From.ID] {
		handlers.HandleFeedbackText(d, msg)
		return
	}

	// Матни номафҳум — менюи асосиро бозмефиристем, то корбар донад чӣ кор кунад
	handlers.HandleUnknownText(d, msg)
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
	case strings.HasPrefix(data, "pricepkg:"):
		handlers.HandlePricePackageCallback(d, cb)
	case strings.HasPrefix(data, "priceorder:"):
		handlers.HandlePriceOrderCallback(d, cb)
	case strings.HasPrefix(data, "appedit:"):
		handlers.HandleAppEditCallback(d, cb)
	case strings.HasPrefix(data, "apptransfer:"):
		handlers.HandleAppTransferConfirmCallback(d, cb)
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
