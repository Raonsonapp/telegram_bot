package handlers

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

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

	var aiScreen *api.GeneratedScreen
	if d.AICoder.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_generating_screen"))
		screen, err := d.AICoder.GenerateScreen(description)
		if err != nil {
			utils.LogError("appbuilder: AI screen generation failed for %q: %v", description, err)
			sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		} else if err := d.GitHubApp.PushFlutterScreen(fullName, screen); err != nil {
			utils.LogError("appbuilder: failed to push AI-generated scaffold to %s: %v", fullName, err)
			sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		} else {
			aiScreen = &screen
		}
	}

	delete(appBuilderSessions, msg.From.ID)

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_waiting_build"))
	if waitForGreenBuild(d, msg, lang, fullName, description, aiScreen) {
		text := fmt.Sprintf(api.GetMessage(lang, "appbuilder_created"), fullName, htmlURL)
		sendTextMarkdown(d, msg.Chat.ID, text)
	}
}

const (
	buildWaitTimeout = 6 * time.Minute
	buildPollEvery   = 10 * time.Second
	// Пеш аз пурсидани "охирин run", лаҳзае интизор мешавем, то push/dispatch-и
	// охирин дар GitHub Actions сабт шавад (run фавран пайдо намешавад)
	buildRunSettleDelay = 5 * time.Second
)

// waitForGreenBuild то тамом шудани build.yml мунтазир мешавад ва натиҷаро
// ба корбар мегӯяд. Агар build ноком шавад ва экрани AI дошта бошем, як
// маротиба AI-ро бо матни хатогии build мехонем, то худкор ислоҳ кунад,
// ва боз як бор мунтазир мешавем. Бо "true" бармегардад, агар дар охир
// build сабз шуда бошад (танҳо дар ин ҳолат паёми "тайёр" фиристода мешавад)
func waitForGreenBuild(d *Deps, msg *tgbotapi.Message, lang, fullName, description string, aiScreen *api.GeneratedScreen) bool {
	time.Sleep(buildRunSettleDelay)

	runID, err := d.GitHubApp.GetLatestRunID(fullName, "build.yml")
	if err != nil {
		utils.LogError("appbuilder: failed to resolve latest build run for %s: %v", fullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_timeout"))
		return false
	}

	conclusion, err := d.GitHubApp.WaitForRunCompletion(fullName, runID, buildWaitTimeout, buildPollEvery)
	if err != nil {
		utils.LogError("appbuilder: timed out waiting for build run %d on %s: %v", runID, fullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_timeout"))
		return false
	}
	if conclusion == "success" {
		return true
	}

	utils.LogError("appbuilder: build run %d on %s finished with conclusion=%s", runID, fullName, conclusion)

	if aiScreen == nil || !d.AICoder.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_failed"))
		return false
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_fixing"))

	errorLog, logErr := d.GitHubApp.GetRunFailureLog(fullName, runID)
	if logErr != nil {
		utils.LogError("appbuilder: failed to fetch failure log for run %d on %s: %v", runID, fullName, logErr)
	}

	fixedScreen, fixErr := d.AICoder.FixScreen(description, aiScreen.MainDart, errorLog)
	if fixErr != nil {
		utils.LogError("appbuilder: AI auto-fix failed for %s: %v", fullName, fixErr)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_failed"))
		return false
	}
	if err := d.GitHubApp.PushFlutterScreen(fullName, fixedScreen); err != nil {
		utils.LogError("appbuilder: failed to push AI-fixed scaffold to %s: %v", fullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_failed"))
		return false
	}

	time.Sleep(buildRunSettleDelay)
	retryRunID, err := d.GitHubApp.GetLatestRunID(fullName, "build.yml")
	if err != nil {
		utils.LogError("appbuilder: failed to resolve retry build run for %s: %v", fullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_failed"))
		return false
	}
	retryConclusion, err := d.GitHubApp.WaitForRunCompletion(fullName, retryRunID, buildWaitTimeout, buildPollEvery)
	if err != nil || retryConclusion != "success" {
		utils.LogError("appbuilder: retry build run %d on %s finished with conclusion=%q err=%v", retryRunID, fullName, retryConclusion, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_failed"))
		return false
	}

	return true
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
