package keyboard

import (
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
)

// MainMenu менюи асосии клавиатура (reply keyboard)-ро месозад мутобиқи забон.
// Бот акнун танҳо ба App Builder бахшида шудааст — хусусиятҳои дигар (аниме,
// абзорҳо ва ғ.) дар код мемонанд (архив), вале дигар дар меню нестанд
func MainMenu(lang string) tgbotapi.ReplyKeyboardMarkup {
	return tgbotapi.NewReplyKeyboard(
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_app_builder")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_fetch_apk")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_import_code")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_ai_chat")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_price_calc")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_invite")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_feedback")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_settings")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_help")),
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
