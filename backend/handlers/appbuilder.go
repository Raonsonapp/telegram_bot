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
// корбар дар кадом зинаи сохтани барномаи НАВ қарор дорад: аввал номи
// намоишӣ, баъд логотип (ихтиёрӣ), баъд тавсифи функсияҳо
var PendingAppDisplayName = make(map[int64]bool)
var PendingAppLogo = make(map[int64]bool)
var PendingAppName = make(map[int64]bool)

// PendingAppEditDescription, PendingAppEditName ва PendingAppEditLogo барои
// корбароне истифода мешаванд, ки АЛЛАКАЙ барнома доранд ва аз менюи
// таҳрир танҳо ЯК қисматро иваз карданӣ ҳастанд (то ҳар дафъа ҳамаи
// ном+логотип+тавсифро аз нав нагӯянд)
var PendingAppEditDescription = make(map[int64]bool)
var PendingAppEditName = make(map[int64]bool)
var PendingAppEditLogo = make(map[int64]bool)

// HandleAppBuilderButton вақте пахш мешавад. Агар корбар аллакай барнома
// дошта бошад, менюи таҳрир (танҳо тавсиф/ном/логотип ё ҳама аз нав)
// нишон дода мешавад; вагарна зинаи якуми сохтани барномаи нав (номи
// намоишӣ) оғоз мешавад
func HandleAppBuilderButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	if !d.GitHubApp.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_not_configured"))
		return
	}

	if repo, err := d.DB.GetUserRepo(msg.From.ID); err == nil && repo != nil {
		showAppEditMenu(d, msg.Chat.ID, lang)
		return
	}

	startNewAppFlow(d, msg.From.ID, msg.Chat.ID, lang)
}

// startNewAppFlow зинаи якуми сохтани барномаи нав (номи намоишӣ)-ро оғоз мекунад
func startNewAppFlow(d *Deps, userID, chatID int64, lang string) {
	appBuilderSessions[userID] = &appBuilderState{}
	PendingAppDisplayName[userID] = true
	sendText(d, chatID, api.GetMessage(lang, "ask_app_display_name"))
}

// showAppEditMenu менюи интихоби навъи таҳрирро (тугмаҳои inline) нишон медиҳад
func showAppEditMenu(d *Deps, chatID int64, lang string) {
	message := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "appbuilder_edit_menu"))
	message.ReplyMarkup = tgbotapi.NewInlineKeyboardMarkup(
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_edit_description"), "appedit:description"),
		),
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_edit_name"), "appedit:name"),
		),
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_edit_logo"), "appedit:logo"),
		),
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_edit_all"), "appedit:all"),
		),
	)
	d.Bot.Send(message)
}

// HandleAppEditCallback интихоби корбарро аз менюи таҳрир мегирад ва
// зинаи дурусти навбатиро оғоз мекунад
func HandleAppEditCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID
	mode := strings.TrimPrefix(cb.Data, "appedit:")

	switch mode {
	case "description":
		PendingAppEditDescription[cb.From.ID] = true
		sendText(d, chatID, api.GetMessage(lang, "ask_app_name"))
	case "name":
		PendingAppEditName[cb.From.ID] = true
		sendText(d, chatID, api.GetMessage(lang, "ask_app_display_name"))
	case "logo":
		PendingAppEditLogo[cb.From.ID] = true
		sendText(d, chatID, api.GetMessage(lang, "ask_app_logo"))
	case "all":
		startNewAppFlow(d, cb.From.ID, chatID, lang)
	}
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

// HandleAppEditDescriptionText танҳо тавсифи функсияҳоро иваз мекунад —
// экрани навро бо AI аз тавсифи нав месозад ва push мекунад (ном ва
// логотипи мавҷуда дастнахӯрда мемонанд)
func HandleAppEditDescriptionText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	description := strings.TrimSpace(msg.Text)
	if description == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_name"))
		return
	}
	PendingAppEditDescription[msg.From.ID] = false

	repo, err := d.DB.GetUserRepo(msg.From.ID)
	if err != nil || repo == nil {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}

	if !d.AICoder.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_generating_screen"))
	screen, err := d.AICoder.GenerateScreen(description)
	if err != nil {
		utils.LogError("appbuilder: AI screen generation failed for %q: %v", description, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		return
	}
	if err := d.GitHubApp.PushFlutterScreen(repo.FullName, screen); err != nil {
		utils.LogError("appbuilder: failed to push AI-generated scaffold to %s: %v", repo.FullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_waiting_build"))
	if waitForGreenBuild(d, msg, lang, repo.FullName, description, &screen) {
		text := fmt.Sprintf(api.GetMessage(lang, "appbuilder_created"), repo.FullName, repo.URL)
		sendTextMarkdown(d, msg.Chat.ID, text)
	}
}

// HandleAppEditNameText танҳо номи намоиширо иваз мекунад (лого ва
// lib/main.dart-и мавҷуда дастнахӯрда мемонанд)
func HandleAppEditNameText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	name := strings.TrimSpace(msg.Text)
	if name == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_display_name"))
		return
	}
	PendingAppEditName[msg.From.ID] = false

	repo, err := d.DB.GetUserRepo(msg.From.ID)
	if err != nil || repo == nil {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_updating"))
	if err := d.GitHubApp.FinalizeAppSetup(repo.FullName, name, nil); err != nil {
		utils.LogError("appbuilder: failed to update app name for %s: %v", repo.FullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_waiting_build"))
	if waitForGreenBuild(d, msg, lang, repo.FullName, "", nil) {
		text := fmt.Sprintf(api.GetMessage(lang, "appbuilder_created"), repo.FullName, repo.URL)
		sendTextMarkdown(d, msg.Chat.ID, text)
	}
}

// HandleAppEditLogoPhoto танҳо логотипро иваз мекунад — номи ҳозираро аз
// худи репо (AndroidManifest.xml) мехонад, то гум нашавад
func HandleAppEditLogoPhoto(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	PendingAppEditLogo[msg.From.ID] = false

	repo, err := d.DB.GetUserRepo(msg.From.ID)
	if err != nil || repo == nil {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}

	if len(msg.Photo) == 0 {
		PendingAppEditLogo[msg.From.ID] = true
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_logo"))
		return
	}

	largest := msg.Photo[len(msg.Photo)-1]
	data, err := downloadTelegramFile(d, largest.FileID)
	if err != nil {
		utils.LogError("appbuilder: failed to download new logo for user=%d: %v", msg.From.ID, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}

	displayName, err := d.GitHubApp.GetCurrentAppName(repo.FullName)
	if err != nil {
		utils.LogError("appbuilder: failed to resolve current app name for %s, using default: %v", repo.FullName, err)
		displayName = "Flutter App"
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_logo_received"))
	if err := d.GitHubApp.FinalizeAppSetup(repo.FullName, displayName, data); err != nil {
		utils.LogError("appbuilder: failed to update app logo for %s: %v", repo.FullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_waiting_build"))
	if waitForGreenBuild(d, msg, lang, repo.FullName, "", nil) {
		text := fmt.Sprintf(api.GetMessage(lang, "appbuilder_created"), repo.FullName, repo.URL)
		sendTextMarkdown(d, msg.Chat.ID, text)
	}
}

// telegramMaxFileBytes — ҳадди фиристодани файл аз бот (Telegram Bot API,
// ~50МБ). Аз ин боло кӯшиши фиристодан бе хатогии равшан ноком мешавад
const telegramMaxFileBytes = 49 * 1024 * 1024

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

	// Telegram-и бот файлро танҳо то ~50МБ иҷозат медиҳад — агар аз ин
	// зиёд бошад, кӯшиши фиристодан бе хабардор кардани корбар ноком
	// мешавад (ба назар "ҳамту меистад" мерасад). Барои ҳамин пешакӣ санҷем
	if len(apkBytes) > telegramMaxFileBytes {
		utils.LogError("appbuilder: APK for %q is %d bytes, exceeds Telegram's bot upload limit", repoName, len(apkBytes))
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "apk_too_large"))
		return
	}

	doc := tgbotapi.NewDocument(msg.Chat.ID, tgbotapi.FileBytes{Name: apkFileName, Bytes: apkBytes})
	if _, err := d.Bot.Send(doc); err != nil {
		utils.LogError("appbuilder: failed to send APK document for %q: %v", repoName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "apk_send_failed"))
	}
}
