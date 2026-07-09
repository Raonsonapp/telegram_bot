package keyboard

import (
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
)

// ToolsMenu менюи абзорҳои ёрирасон (на ба аниме алоқаманд)-ро месозад
func ToolsMenu(lang string) tgbotapi.ReplyKeyboardMarkup {
	return tgbotapi.NewReplyKeyboard(
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_password_gen")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_qr_gen")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_currency")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_worldcup")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_app_builder")),
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_fetch_apk")),
		),
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_back_to_menu")),
		),
	)
}
