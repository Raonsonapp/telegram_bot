package handlers

import (
	"fmt"
	"io"
	"net/http"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// appBuilderState маълумоти байни зинаҳои сохтани барномаро (ном, логотип)
// то расидан ба тавсифи функсияҳо нигоҳ медорад
type appBuilderState struct {
	DisplayName string
	LogoBytes   []byte
}

var appBuilderSessions = make(map[int64]*appBuilderState)

// PendingAppDisplayName, PendingAppLogo ва PendingAppName нигоҳ медоранд
// корбар дар кадом зинаи сохтани барнома қарор дорад: аввал номи намоишӣ,
// баъд логотип (ихтиёрӣ), баъд тавсифи функсияҳо
var PendingAppDisplayName = make(map[int64]bool)
var PendingAppLogo = make(map[int64]bool)
var PendingAppName = make(map[int64]bool)

// HandleAppBuilderButton зинаи якуми сохтани барномаро оғоз мекунад:
// номи намоишии барнома (он чи дар телефони корбар нишон дода мешавад)
func HandleAppBuilderButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	if !d.GitHubApp.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_not_configured"))
		return
	}
	appBuilderSessions[msg.From.ID] = &appBuilderState{}
	PendingAppDisplayName[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_display_name"))
}

// HandleAppDisplayNameText номи намоишии барномаро мегирад, баъд логотипро мепурсад
func HandleAppDisplayNameText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	name := strings.TrimSpace(msg.Text)
	if name == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_display_name"))
		return
	}
	PendingAppDisplayName[msg.From.ID] = false

	state := appBuilderSessions[msg.From.ID]
	if state == nil {
		state = &appBuilderState{}
		appBuilderSessions[msg.From.ID] = state
	}
	state.DisplayName = name

	PendingAppLogo[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_logo"))
}

// HandleAppLogoPhoto вақте корбар акси логотипро мефиристад даъват мешавад —
// нусхаи бузургтаринашро мегирад ва дар сессия нигоҳ медорад
func HandleAppLogoPhoto(d *Deps, msg *tgbotapi.Message) {
	PendingAppLogo[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)

	if len(msg.Photo) > 0 {
		largest := msg.Photo[len(msg.Photo)-1]
		if data, err := downloadTelegramFile(d, largest.FileID); err != nil {
			utils.LogError("appbuilder: failed to download logo for user=%d: %v", msg.From.ID, err)
		} else {
			state := appBuilderSessions[msg.From.ID]
			if state == nil {
				state = &appBuilderState{}
				appBuilderSessions[msg.From.ID] = state
			}
			state.LogoBytes = data
		}
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_logo_received"))
	PendingAppName[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_name"))
}

// HandleAppLogoSkipText вақте корбар дар ҷои акс матн мефиристад (масалан "-")
// даъват мешавад — логотип гузаронда мешавад
func HandleAppLogoSkipText(d *Deps, msg *tgbotapi.Message) {
	PendingAppLogo[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_logo_skipped"))
	PendingAppName[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_name"))
}

// downloadTelegramFile байти файли Telegram-ро (масалан акс) тавассути
// fileID мегирад
func downloadTelegramFile(d *Deps, fileID string) ([]byte, error) {
	fileURL, err := d.Bot.GetFileDirectURL(fileID)
	if err != nil {
		return nil, err
	}
	resp, err := http.Get(fileURL)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status %d downloading file", resp.StatusCode)
	}
	return io.ReadAll(resp.Body)
}

// HandleAppNameText тавсифи функсияҳои барномаро мегирад — зинаи охирин.
// Агар корбар аллакай репо дошта бошад, экрани навро дар ҳамон репо
// навсозӣ мекунад (на репои дигар месозад — ҳар корбар танҳо 1 репо дорад,
// то GitHub-и соҳиби бот бо репоҳои бешумор пур нашавад); вагарна репои
// нав месозад (бо workflow-и Flutter build-и тайёр)
func HandleAppNameText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	description := strings.TrimSpace(msg.Text)
	if description == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_name"))
		return
	}
	PendingAppName[msg.From.ID] = false

	state := appBuilderSessions[msg.From.ID]
	displayName := description
	var logoBytes []byte
	if state != nil {
		if state.DisplayName != "" {
			displayName = state.DisplayName
		}
		logoBytes = state.LogoBytes
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_creating"))

	fullName, htmlURL, isNew, err := d.GitHubApp.CreateOrGetUserRepo(msg.From.ID, description)
	if err != nil {
		utils.LogError("appbuilder: failed to create/get repo for user=%d %q: %v", msg.From.ID, description, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}
	if !isNew {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_updating_existing"))
	}

	if err := d.DB.SaveUserRepo(msg.From.ID, fullName, htmlURL); err != nil {
		utils.LogError("appbuilder: failed to save repo mapping for user=%d repo=%s: %v", msg.From.ID, fullName, err)
	}

	// Пеш аз коднависии AI: скелети Flutter, номи намоишӣ ва (агар дода
	// шуда бошад) логотипро дар репо омода мекунад
	if err := d.GitHubApp.FinalizeAppSetup(fullName, displayName, logoBytes); err != nil {
		utils.LogError("appbuilder: failed to finalize app setup for %s: %v", fullName, err)
	}

	if d.AICoder.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_generating_screen"))
		screen, err := d.AICoder.GenerateScreen(description)
		if err != nil {
			utils.LogError("appbuilder: AI screen generation failed for %q: %v", description, err)
			sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		} else if err := d.GitHubApp.PushFlutterScreen(fullName, screen); err != nil {
			utils.LogError("appbuilder: failed to push AI-generated scaffold to %s: %v", fullName, err)
			sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		}
	}

	delete(appBuilderSessions, msg.From.ID)

	text := fmt.Sprintf(api.GetMessage(lang, "appbuilder_created"), fullName, htmlURL)
	sendTextMarkdown(d, msg.Chat.ID, text)
}

// HandleFetchAPKButton охирин APK-и репои шахсии корбарро мегирад. Номи
// репо аз ID-и Telegram-и корбар худкор ҳосил мешавад (app-user-<ID>) —
// аз корбар дигар чизе пурсида намешавад, зеро номи репо аллакай муайян аст
func HandleFetchAPKButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	if !d.GitHubApp.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_not_configured"))
		return
	}

	owner, err := d.GitHubApp.CurrentOwner()
	if err != nil || owner == "" {
		utils.LogError("appbuilder: failed to resolve current owner: %v", err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}
	repoName := fmt.Sprintf("%s/app-user-%d", owner, msg.From.ID)

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "apk_fetching"))

	apkBytes, apkFileName, err := d.GitHubApp.GetLatestAPK(repoName)
	if err != nil {
		utils.LogError("appbuilder: failed to fetch APK for %q: %v", repoName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "apk_not_found"))
		return
	}

	doc := tgbotapi.NewDocument(msg.Chat.ID, tgbotapi.FileBytes{Name: apkFileName, Bytes: apkBytes})
	d.Bot.Send(doc)
}
