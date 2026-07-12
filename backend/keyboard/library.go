package keyboard

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/models"
)

// animeButtonLabel матни тугмаро аз номи аниме ва сол месозад
func animeButtonLabel(title string, year int) string {
	if len(title) > 45 {
		title = title[:45] + "..."
	}
	if year > 0 {
		return fmt.Sprintf("%s (%d)", title, year)
	}
	return title
}

// FavoritesKeyboard рӯйхати Севимиҳои корбарро ба тугмаҳо табдил медиҳад
func FavoritesKeyboard(favorites []models.Favorite) tgbotapi.InlineKeyboardMarkup {
	var rows [][]tgbotapi.InlineKeyboardButton
	for _, f := range favorites {
		rows = append(rows, tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(animeButtonLabel(f.Title, f.Year), fmt.Sprintf("anime:%d", f.AnimeID)),
		))
	}
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// WatchListKeyboard рӯйхати аниме-ҳоро мутобиқи ҳолати тамошо ба тугмаҳо табдил медиҳад
func WatchListKeyboard(entries []models.WatchEntry) tgbotapi.InlineKeyboardMarkup {
	var rows [][]tgbotapi.InlineKeyboardButton
	for _, e := range entries {
		rows = append(rows, tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(animeButtonLabel(e.Title, e.Year), fmt.Sprintf("anime:%d", e.AnimeID)),
		))
	}
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// RecentlyViewedKeyboard рӯйхати анимеҳои ба наздикӣ дидашударо ба тугмаҳо табдил медиҳад
func RecentlyViewedKeyboard(items []models.RecentlyViewed) tgbotapi.InlineKeyboardMarkup {
	var rows [][]tgbotapi.InlineKeyboardButton
	for _, r := range items {
		rows = append(rows, tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(animeButtonLabel(r.Title, r.Year), fmt.Sprintf("anime:%d", r.AnimeID)),
		))
	}
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// ProfileKeyboard тугмаҳои дохили саҳифаи профил (Севимиҳо, дар ҳоли тамошо, ба наздикӣ дидашуда)
func ProfileKeyboard(lang string) tgbotapi.InlineKeyboardMarkup {
	return tgbotapi.NewInlineKeyboardMarkup(
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_my_favorites"), "profile:favorites"),
		),
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_my_watching"), "profile:watching"),
		),
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_my_recent"), "profile:recent"),
		),
	)
}
