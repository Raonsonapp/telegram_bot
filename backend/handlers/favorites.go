package handlers

import (
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/keyboard"
	"anime-bot/backend/models"
	"anime-bot/backend/utils"
)

// HandleFavoriteCallback callback-и "fav:<animeID>"-ро коркард мекунад — илова/хориҷ аз Севимиҳо
func HandleFavoriteCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	id, ok := utils.ParseCallbackID(cb.Data, "fav:")
	if !ok {
		return
	}

	lang := getUserLang(d, cb.From.ID)
	anime := fetchAnimeCached(d, id)
	if anime == nil {
		d.Bot.Request(tgbotapi.NewCallback(cb.ID, api.GetMessage(lang, "anime_not_found")))
		return
	}

	added, err := d.DB.ToggleFavorite(cb.From.ID, *anime)
	if err != nil {
		utils.LogError("failed to toggle favorite anime=%d: %v", id, err)
		d.Bot.Request(tgbotapi.NewCallback(cb.ID, api.GetMessage(lang, "error_generic")))
		return
	}

	toast := api.GetMessage(lang, "favorite_removed")
	if added {
		toast = api.GetMessage(lang, "favorite_added")
	}
	d.Bot.Request(tgbotapi.NewCallback(cb.ID, toast))

	refreshAnimeKeyboard(d, cb, *anime, lang)
}

// HandleWatchStatusCallback callback-и "watch:<animeID>:<status>"-ро коркард мекунад
func HandleWatchStatusCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	parts := strings.Split(cb.Data, ":")
	if len(parts) != 3 {
		return
	}
	id := atoi(parts[1])
	status := models.WatchStatus(parts[2])
	if id == 0 || (status != models.StatusWatching && status != models.StatusCompleted) {
		return
	}

	lang := getUserLang(d, cb.From.ID)
	anime := fetchAnimeCached(d, id)
	if anime == nil {
		d.Bot.Request(tgbotapi.NewCallback(cb.ID, api.GetMessage(lang, "anime_not_found")))
		return
	}

	if err := d.DB.SetWatchStatus(cb.From.ID, *anime, status); err != nil {
		utils.LogError("failed to set watch status anime=%d: %v", id, err)
		d.Bot.Request(tgbotapi.NewCallback(cb.ID, api.GetMessage(lang, "error_generic")))
		return
	}

	toastKey := "watch_status_watching"
	if status == models.StatusCompleted {
		toastKey = "watch_status_completed"
	}
	d.Bot.Request(tgbotapi.NewCallback(cb.ID, api.GetMessage(lang, toastKey)))

	refreshAnimeKeyboard(d, cb, *anime, lang)
}

// refreshAnimeKeyboard тугмаҳои зери маълумоти анимеро мутобиқи ҳолати нави
// корбар (Севимӣ/Ҳолати тамошо) аз нав месозад
func refreshAnimeKeyboard(d *Deps, cb *tgbotapi.CallbackQuery, anime models.Anime, lang string) {
	isFav, err := d.DB.IsFavorite(cb.From.ID, anime.MalID)
	if err != nil {
		utils.LogError("failed to check favorite status anime=%d: %v", anime.MalID, err)
	}
	status, err := d.DB.GetWatchStatus(cb.From.ID, anime.MalID)
	if err != nil {
		utils.LogError("failed to get watch status anime=%d: %v", anime.MalID, err)
	}

	keyb := keyboard.AnimeDetailKeyboard(anime, lang, isFav, status)
	edit := tgbotapi.NewEditMessageReplyMarkup(cb.Message.Chat.ID, cb.Message.MessageID, keyb)
	d.Bot.Send(edit)
}
