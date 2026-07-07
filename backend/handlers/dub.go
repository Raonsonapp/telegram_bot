package handlers

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// HandleDubCallback callback-и "dub:<animeID>"-ро коркард мекунад — дар Aparat
// видеои дубляжшудаи анимеро меҷӯяд ва ҳамчун тугмаҳои пайванд нишон медиҳад
func HandleDubCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	id, ok := utils.ParseCallbackID(cb.Data, "dub:")
	if !ok {
		return
	}

	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	anime := fetchAnimeCached(d, id)
	if anime == nil {
		sendText(d, chatID, api.GetMessage(lang, "anime_not_found"))
		return
	}

	searchingMsg := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "dub_searching"))
	sentMsg, _ := d.Bot.Send(searchingMsg)

	videos, err := d.Aparat.SearchVideos(anime.Title, 5)
	if err != nil {
		utils.LogError("aparat search failed for anime=%d: %v", id, err)
		edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, api.GetMessage(lang, "dub_no_results"))
		d.Bot.Send(edit)
		return
	}
	if len(videos) == 0 {
		edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, api.GetMessage(lang, "dub_no_results"))
		d.Bot.Send(edit)
		return
	}

	var rows [][]tgbotapi.InlineKeyboardButton
	for _, v := range videos {
		title := utils.Truncate(v.Title, 50)
		rows = append(rows, tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonURL(fmt.Sprintf("▶️ %s", title), v.URL()),
		))
	}
	keyb := tgbotapi.NewInlineKeyboardMarkup(rows...)

	edit := tgbotapi.NewEditMessageTextAndMarkup(chatID, sentMsg.MessageID, api.GetMessage(lang, "dub_results_title"), keyb)
	d.Bot.Send(edit)
}
