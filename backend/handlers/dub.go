package handlers

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// dubResult натиҷаи якхелаи видео новобаста аз он ки аз кадом платформа омадааст
type dubResult struct {
	Title string
	URL   string
}

// HandleDubCallback callback-и "dub:<animeID>"-ро коркард мекунад — дар якчанд
// платформа (Aparat, Dailymotion) видеои дубляжшудаи анимеро меҷӯяд ва ҳамчун
// тугмаҳои пайванд нишон медиҳад
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

	results := searchAllDubSources(d, anime.Title, id)
	if len(results) == 0 {
		edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, api.GetMessage(lang, "dub_no_results"))
		d.Bot.Send(edit)
		return
	}

	edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, api.GetMessage(lang, "dub_results_title"))
	d.Bot.Send(edit)

	// Пайвандҳоро ҳамчун паёми оддии матнӣ (на тугмаи inline) мефиристем — Telegram
	// худаш барои чунин пайвандҳо (алалхусус YouTube) видеои дарунсохти
	// тамошошавандаро дар дохили чат нишон медиҳад, корбар аз Telegram берун намебарояд
	for _, r := range results {
		message := tgbotapi.NewMessage(chatID, fmt.Sprintf("%s\n%s", r.Title, r.URL))
		d.Bot.Send(message)
	}
}

// searchAllDubSources ҳамаи платформаҳои видеоро мепурсад ва натиҷаҳоро якҷоя
// мекунад. Агар як платформа хато диҳад ё чизе наёбад, платформаҳои дигар
// ҳамоно санҷида мешаванд — ин имконияти ёфтани дубляжро зиёд мекунад
func searchAllDubSources(d *Deps, title string, animeID int) []dubResult {
	const maxResults = 6
	var results []dubResult

	aparatVideos, err := d.Aparat.SearchVideos(title, 4)
	if err != nil {
		utils.LogError("aparat search failed for anime=%d: %v", animeID, err)
	}
	for _, v := range aparatVideos {
		results = append(results, dubResult{Title: "Aparat: " + v.Title, URL: v.URL()})
	}

	dailymotionVideos, err := d.Dailymotion.SearchVideos(title, 4)
	if err != nil {
		utils.LogError("dailymotion search failed for anime=%d: %v", animeID, err)
	}
	for _, v := range dailymotionVideos {
		results = append(results, dubResult{Title: "Dailymotion: " + v.Title, URL: v.URL})
	}

	if d.YouTube.Enabled() {
		// Дар YouTube ҷустуҷӯи танҳо номи аниме бисёр натиҷаи расмии бе дубляж
		// медиҳад — "дубле форсӣ" мушаххас каналҳои дубляжро меёбад
		youtubeVideos, err := d.YouTube.SearchVideos(title+" دوبله فارسی", 4)
		if err != nil {
			utils.LogError("youtube search failed for anime=%d: %v", animeID, err)
		}
		for _, v := range youtubeVideos {
			results = append(results, dubResult{Title: "YouTube: " + v.Title, URL: v.URL})
		}
	}

	if len(results) > maxResults {
		results = results[:maxResults]
	}
	return results
}
