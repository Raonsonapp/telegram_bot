package handlers

import (
	"fmt"
	"strings"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/utils"
)

// PendingImportCode корбаронеро нигоҳ медорад, ки мунтазири фиристодани
// коди худашон ҳастанд — ё ҳамчун файли ZIP, ё ҳамчун линки репои GitHub
var PendingImportCode = make(map[int64]bool)

// importTelegramMaxBytes — боти Telegram файлро танҳо то ~20МБ бор карда
// метавонад (маҳдудияти Bot API-и getFile)
const importTelegramMaxBytes = 20 * 1024 * 1024

// HandleImportCodeButton импорти кодро оғоз мекунад — аз корбар ё ZIP ё
// линки репои GitHub мепурсад
func HandleImportCodeButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	if !d.GitHubApp.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_not_configured"))
		return
	}
	PendingImportCode[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_import_code"))
}

// HandleImportCodeDocument вақте даъват мешавад, ки корбар файли ZIP-и
// коди худашро фиристад
func HandleImportCodeDocument(d *Deps, msg *tgbotapi.Message) {
	PendingImportCode[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)

	doc := msg.Document
	if doc == nil {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_import_code"))
		return
	}
	name := strings.ToLower(doc.FileName)
	if !strings.HasSuffix(name, ".zip") && doc.MimeType != "application/zip" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_not_zip"))
		return
	}
	if doc.FileSize > importTelegramMaxBytes {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_too_large"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_receiving"))
	zipBytes, err := downloadTelegramFile(d, doc.FileID)
	if err != nil {
		utils.LogError("import: failed to download zip for user=%d: %v", msg.From.ID, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_download_failed"))
		return
	}

	files, err := api.ExtractZipFiles(zipBytes)
	if err != nil {
		utils.LogError("import: failed to extract zip for user=%d: %v", msg.From.ID, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_bad_zip"))
		return
	}

	runImport(d, msg, lang, files)
}

// HandleImportCodeText вақте даъват мешавад, ки корбар ба ҷои файл линки
// репои GitHub-и худашро фиристад
func HandleImportCodeText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	owner, repo, ok := api.ParseGitHubRepoURL(msg.Text)
	if !ok {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_bad_link"))
		return
	}
	PendingImportCode[msg.From.ID] = false

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_receiving"))
	zipBytes, err := d.GitHubApp.DownloadRepoArchive(owner, repo)
	if err != nil {
		utils.LogError("import: failed to download repo %s/%s: %v", owner, repo, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_repo_failed"))
		return
	}

	files, err := api.ExtractZipFiles(zipBytes)
	if err != nil {
		utils.LogError("import: failed to extract repo archive %s/%s: %v", owner, repo, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_bad_zip"))
		return
	}

	runImport(d, msg, lang, files)
}

// runImport коди воридшударо ба репои корбар мегузорад, build-ро оғоз
// мекунад ва то тайёр шудани APK сабр карда, натиҷаро мегӯяд
func runImport(d *Deps, msg *tgbotapi.Message, lang string, files map[string][]byte) {
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_creating"))

	fullName, htmlURL, _, err := d.GitHubApp.CreateOrGetUserRepo(msg.From.ID, "imported code")
	if err != nil {
		utils.LogError("import: failed to create/get repo for user=%d: %v", msg.From.ID, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}
	if err := d.DB.SaveUserRepo(msg.From.ID, fullName, htmlURL); err != nil {
		utils.LogError("import: failed to save repo mapping for user=%d: %v", msg.From.ID, err)
	}

	if err := d.GitHubApp.ImportCode(fullName, files); err != nil {
		utils.LogError("import: failed to import code to %s: %v", fullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_push_failed"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_waiting_build"))

	time.Sleep(buildRunSettleDelay)
	runID, err := d.GitHubApp.GetLatestRunID(fullName, "build.yml")
	if err != nil {
		utils.LogError("import: failed to resolve build run for %s: %v", fullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_timeout"))
		return
	}
	conclusion, err := d.GitHubApp.WaitForRunCompletion(fullName, runID, buildWaitTimeout, buildPollEvery)
	if err != nil {
		utils.LogError("import: timed out waiting for build run %d on %s: %v", runID, fullName, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_build_timeout"))
		return
	}
	if conclusion != "success" {
		utils.LogError("import: build run %d on %s finished with conclusion=%s", runID, fullName, conclusion)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "import_build_failed"))
		return
	}

	text := fmt.Sprintf(api.GetMessage(lang, "appbuilder_created"), fullName, htmlURL)
	sendTextMarkdown(d, msg.Chat.ID, text)
}
