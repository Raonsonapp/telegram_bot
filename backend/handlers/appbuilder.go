package handlers

import (
	"fmt"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// PendingAppName ва PendingAPKRepo нигоҳ медоранд кадом корбарон мунтазири
// фиристодани номи барнома (барои сохтани репо) ё номи репо (барои
// гирифтани APK-и охирин) ҳастанд
var PendingAppName = make(map[int64]bool)
var PendingAPKRepo = make(map[int64]bool)

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

// HandleAppNameText тавсифи фиристодаи корбарро мегирад, репои нав месозад
// (бо workflow-и Android build-и тайёр), ва агар AICoder фаъол бошад,
// экрани 1-саҳифагӣ бо 5 функсия (тавассути Qwen) месозаду push мекунад
func HandleAppNameText(d *Deps, msg *tgbotapi.Message) {
	PendingAppName[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)
	description := strings.TrimSpace(msg.Text)
	if description == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_app_name"))
		return
	}

	sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_creating"))

	fullName, htmlURL, err := d.GitHubApp.CreateAppRepo(description)
	if err != nil {
		utils.LogError("appbuilder: failed to create repo for %q: %v", description, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_error"))
		return
	}

	if d.AICoder.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_generating_screen"))
		screen, err := d.AICoder.GenerateScreen(description)
		if err != nil {
			utils.LogError("appbuilder: AI screen generation failed for %q: %v", description, err)
			sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		} else if err := d.GitHubApp.PushAndroidScaffold(fullName, screen); err != nil {
			utils.LogError("appbuilder: failed to push AI-generated scaffold to %s: %v", fullName, err)
			sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_ai_error"))
		}
	}

	text := fmt.Sprintf(api.GetMessage(lang, "appbuilder_created"), fullName, htmlURL)
	sendTextMarkdown(d, msg.Chat.ID, text)
}

// HandleFetchAPKButton номи репоеро мепурсад, ки бояд APK-и охиринашро гирад
func HandleFetchAPKButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	if !d.GitHubApp.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_not_configured"))
		return
	}
	PendingAPKRepo[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_apk_repo"))
}

// HandleFetchAPKText номи репои фиристодаи корбарро мегирад, охирин
// artifact-и APK-и GitHub Actions-ро мебарорад ва ҳамчун файл мефиристад
func HandleFetchAPKText(d *Deps, msg *tgbotapi.Message) {
	PendingAPKRepo[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)
	repoName := strings.TrimSpace(msg.Text)
	if repoName == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_apk_repo"))
		return
	}

	if !strings.Contains(repoName, "/") {
		if owner, err := d.GitHubApp.CurrentOwner(); err == nil && owner != "" {
			repoName = owner + "/" + repoName
		}
	}

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
