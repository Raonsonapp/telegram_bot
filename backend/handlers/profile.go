package handlers

import (
	"fmt"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/keyboard"
	"anime-bot/backend/models"
	"anime-bot/backend/utils"
)

// HandleProfileButton фармони /profile ва тугмаи "👤 Профил"-ро коркард мекунад
func HandleProfileButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)

	stats, err := d.DB.GetProfileStats(msg.From.ID)
	if err != nil {
		utils.LogError("failed to get profile stats: %v", err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "error_generic"))
		return
	}

	text := formatProfile(stats, lang)
	message := tgbotapi.NewMessage(msg.Chat.ID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyboard.ProfileKeyboard(lang)
	d.Bot.Send(message)
}

// formatProfile матни форматшудаи саҳифаи профилро месозад
func formatProfile(stats *models.ProfileStats, lang string) string {
	langName := models.SupportedLanguages[stats.Language]
	topGenres := api.GetMessage(lang, "profile_no_genres")
	if len(stats.TopGenres) > 0 {
		topGenres = strings.Join(stats.TopGenres, ", ")
	}

	return fmt.Sprintf(
		api.GetMessage(lang, "profile_text"),
		langName,
		stats.RegisteredAt,
		stats.FavoritesCount,
		stats.WatchingCount,
		stats.CompletedCount,
		stats.TotalEpisodes,
		topGenres,
	)
}

// HandleProfileCallback callback-ҳои "profile:favorites" / "profile:watching" / "profile:recent"-ро коркард мекунад
func HandleProfileCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	switch cb.Data {
	case "profile:favorites":
		favorites, err := d.DB.ListFavorites(cb.From.ID)
		if err != nil {
			utils.LogError("failed to list favorites: %v", err)
			sendText(d, chatID, api.GetMessage(lang, "error_generic"))
			return
		}
		if len(favorites) == 0 {
			sendText(d, chatID, api.GetMessage(lang, "profile_favorites_empty"))
			return
		}
		message := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "profile_favorites_title"))
		message.ReplyMarkup = keyboard.FavoritesKeyboard(favorites)
		d.Bot.Send(message)

	case "profile:watching":
		entries, err := d.DB.ListWatchByStatus(cb.From.ID, models.StatusWatching)
		if err != nil {
			utils.LogError("failed to list watching: %v", err)
			sendText(d, chatID, api.GetMessage(lang, "error_generic"))
			return
		}
		if len(entries) == 0 {
			sendText(d, chatID, api.GetMessage(lang, "profile_watching_empty"))
			return
		}
		message := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "profile_watching_title"))
		message.ReplyMarkup = keyboard.WatchListKeyboard(entries)
		d.Bot.Send(message)

	case "profile:recent":
		items, err := d.DB.ListRecentlyViewed(cb.From.ID, 10)
		if err != nil {
			utils.LogError("failed to list recently viewed: %v", err)
			sendText(d, chatID, api.GetMessage(lang, "error_generic"))
			return
		}
		if len(items) == 0 {
			sendText(d, chatID, api.GetMessage(lang, "profile_recent_empty"))
			return
		}
		message := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "profile_recent_title"))
		message.ReplyMarkup = keyboard.RecentlyViewedKeyboard(items)
		d.Bot.Send(message)
	}
}
