package keyboard

import (
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
)

// MainMenu менюи асосии клавиатура (reply keyboard)-ро месозад мутобиқи забон
func MainMenu(lang string) tgbotapi.ReplyKeyboardMarkup {
	return tgbotapi.NewReplyKeyboard(
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_search")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_dub_menu")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_random")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_mood")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_top")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_profile")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_settings")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_help")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_feedback")),
		),
	)
}

// SettingsKeyboard тугмаи тағйири забон дар менюи танзимот
func SettingsKeyboard(lang string) tgbotapi.InlineKeyboardMarkup {
	return tgbotapi.NewInlineKeyboardMarkup(
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_change_lang"), "settings:change_lang"),
		),
	)
}
