package handlers

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/keyboard"
	"appbuilder-bot/backend/models"
)

// HandleSettings фармони /settings ва тугмаи "⚙️ Settings"-ро коркард мекунад
func HandleSettings(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	langName := models.SupportedLanguages[lang]

	text := fmt.Sprintf(api.GetMessage(lang, "settings_title"), langName)
	message := tgbotapi.NewMessage(msg.Chat.ID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyboard.SettingsKeyboard(lang)
	d.Bot.Send(message)
}

// HandleSettingsCallback callback-ҳои дохили менюи танзимот
func HandleSettingsCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	if cb.Data == "settings:change_lang" {
		lang := getUserLang(d, cb.From.ID)
		text := api.GetMessage(lang, "welcome")
		editMsg := tgbotapi.NewEditMessageTextAndMarkup(cb.Message.Chat.ID, cb.Message.MessageID, text, keyboard.LanguageKeyboard())
		editMsg.ParseMode = tgbotapi.ModeMarkdown
		d.Bot.Send(editMsg)
	}
}

// HandleHelp фармони /help ва тугмаи "❓ Help"-ро коркард мекунад
func HandleHelp(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	sendTextMarkdown(d, msg.Chat.ID, api.GetMessage(lang, "help_text"))
}
