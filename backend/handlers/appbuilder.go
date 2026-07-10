package handlers

import (
	"fmt"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// PendingAppName нигоҳ медорад кадом корбарон мунтазири фиристодани
// тавсифи барнома (барои сохтани репо) ҳастанд
var PendingAppName = make(map[int64]bool)

// HandleAppBuilderButton номи барномаи навро мепурсад, то репои GitHub
// бо workflow-и build-и APK сохта шавад
func HandleAppBuilderButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	if !d.GitHubApp.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_not_configured"))
		return
	}
	PendingAppName[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_name"))
}

// HandleAppNameText тавсифи фиристодаи корбарро мегирад. Агар корбар
// аллакай репо дошта бошад, экрани навро дар ҳамон репо навсозӣ мекунад
// (на репои дигар месозад — ҳар корбар танҳо 1 репо дорад, то GitHub-и
// соҳиби бот бо репоҳои бешумор пур нашавад); вагарна репои нав месозад
// (бо workflow-и Flutter build-и тайёр)
func HandleAppNameText(d *Deps, msg *tgbotapi.Message) {
	PendingAppName[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)
	description := strings.TrimSpace(msg.Text)
	if description == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_name"))
		return
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
