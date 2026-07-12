package handlers

import (
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/keyboard"
	"appbuilder-bot/backend/utils"
)

// HandleLanguageCallback интихоби забонро (lang:en / lang:ru / lang:fa) коркард мекунад
func HandleLanguageCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	data := cb.Data // "lang:en"
	lang := data[len("lang:"):]

	if _, ok := supportedLang(lang); !ok {
		return
	}

	telegramID := cb.From.ID
	username := cb.From.UserName

	user, _, err := d.DB.GetOrCreateUser(telegramID, username, lang)
	if err != nil {
		utils.LogError("failed to get/create user on language select: %v", err)
		return
	}
	if user.Language != lang {
		if err := d.DB.UpdateLanguage(telegramID, lang); err != nil {
			utils.LogError("failed to update language: %v", err)
		}
	}

	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	text := api.GetMessage(lang, "language_set")
	editMsg := tgbotapi.NewEditMessageText(cb.Message.Chat.ID, cb.Message.MessageID, text)
	d.Bot.Send(editMsg)

	menuText := api.GetMessage(lang, "main_menu")
	menuMsg := tgbotapi.NewMessage(cb.Message.Chat.ID, menuText)
	menuMsg.ReplyMarkup = keyboard.MainMenu(lang)
	d.Bot.Send(menuMsg)
}

func supportedLang(lang string) (string, bool) {
	switch lang {
	case "en", "ru", "fa":
		return lang, true
	default:
		return "", false
	}
}
