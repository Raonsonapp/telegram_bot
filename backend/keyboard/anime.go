package keyboard

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/models"
	"anime-bot/backend/utils"
)

// SearchResultsKeyboard рӯйхати натиҷаҳои ҷустуҷӯро ба тугмаҳо табдил медиҳад
func SearchResultsKeyboard(results []models.Anime) tgbotapi.InlineKeyboardMarkup {
	var rows [][]tgbotapi.InlineKeyboardButton
	for _, anime := range results {
		title := utils.Truncate(anime.Title, 45)
		btnText := title
		if anime.Year > 0 {
			btnText = fmt.Sprintf("%s (%d)", title, anime.Year)
		}
		rows = append(rows, tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(btnText, fmt.Sprintf("anime:%d", anime.MalID)),
		))
	}
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// AnimeDetailKeyboard тугмаҳои зери маълумоти яктои аниме
func AnimeDetailKeyboard(anime models.Anime, lang string) tgbotapi.InlineKeyboardMarkup {
	rows := [][]tgbotapi.InlineKeyboardButton{
		{
			tgbotapi.NewInlineKeyboardButtonData(
				api.GetMessage(lang, "btn_episodes"),
				fmt.Sprintf("episodes:%d:1", anime.MalID),
			),
		},
		{
			tgbotapi.NewInlineKeyboardButtonURL(api.GetMessage(lang, "btn_open_mal"), anime.URL),
		},
		{
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_back_to_menu"), "back:menu"),
		},
	}
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// EpisodesKeyboard тугмаҳои саҳифабандӣ ва бозгашт барои рӯйхати эпизодҳо
func EpisodesKeyboard(animeID int, page int, hasNext bool, lang string) tgbotapi.InlineKeyboardMarkup {
	var navRow []tgbotapi.InlineKeyboardButton
	if page > 1 {
		navRow = append(navRow, tgbotapi.NewInlineKeyboardButtonData("⬅️", fmt.Sprintf("episodes:%d:%d", animeID, page-1)))
	}
	if hasNext {
		navRow = append(navRow, tgbotapi.NewInlineKeyboardButtonData("➡️", fmt.Sprintf("episodes:%d:%d", animeID, page+1)))
	}

	rows := [][]tgbotapi.InlineKeyboardButton{}
	if len(navRow) > 0 {
		rows = append(rows, navRow)
	}
	rows = append(rows, tgbotapi.NewInlineKeyboardRow(
		tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_back"), fmt.Sprintf("anime:%d", animeID)),
	))

	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}
