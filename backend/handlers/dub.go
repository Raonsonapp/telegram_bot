package handlers

import (
	"fmt"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// dubResult натиҷаи якхелаи видео новобаста аз он ки аз кадом платформа омадааст
type dubResult struct {
	Title string
	URL   string
}

// PendingDub нигоҳ медорад кадом корбарон мунтазири фиристодани номи аниме
// барои ҷустуҷӯи мустақими дубляж ҳастанд (тугмаи "🎬 Дубляж ёфт кун" дар меню)
var PendingDub = make(map[int64]bool)

// HandleDubMenuButton вақте ки корбар тугмаи "🎬 Дубляж ёфт кун"-ро дар менюи
// асосӣ пахш мекунад — мустақим номи анимеро мепурсад, бе кушодани корти пурра.
// Ин роҳи кӯтоҳтар аст: аз 3-4 қадам (ҷустуҷӯ → интихоб → корти аниме → тугма)
// ба 2 қадам (ном → натиҷа) мерасонад
func HandleDubMenuButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	PendingDub[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_dub_query"))
}

// HandleDubTextQuery номи анимеи фиристодаи корбарро мегирад ва бевосита дар
// манбаъҳои видео меҷӯяд — бе гирифтани маълумоти пурраи аниме аз Jikan/AniList
func HandleDubTextQuery(d *Deps, msg *tgbotapi.Message) {
	PendingDub[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)
	chatID := msg.Chat.ID
	query := strings.TrimSpace(msg.Text)

	if query == "" {
		sendText(d, chatID, api.GetMessage(lang, "ask_dub_query"))
		return
	}

	searchQuery := query
	if utils.ContainsCyrillic(query) {
		if translit := utils.TransliterateCyrillicToLatin(query); translit != "" {
			searchQuery = translit
		}
	}

	searchingMsg := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "dub_searching"))
	sentMsg, _ := d.Bot.Send(searchingMsg)

	results := searchAllDubSources(d, searchQuery, 0)
	sendDubResults(d, chatID, sentMsg.MessageID, lang, results)
}

// HandleDubCallback callback-и "dub:<animeID>"-ро коркард мекунад — дар якчанд
// платформа (Aparat, Dailymotion, YouTube) видеои дубляжшудаи анимеро меҷӯяд
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
	sendDubResults(d, chatID, sentMsg.MessageID, lang, results)
}

// sendDubResults натиҷаҳоро нишон медиҳад. Пайвандҳо ҳамчун паёми оддии матнӣ
// (на тугмаи inline) фиристода мешаванд — Telegram худаш барои чунин пайвандҳо
// (алалхусус YouTube) видеои дарунсохти тамошошавандаро дар дохили чат нишон
// медиҳад, корбар аз Telegram берун намебарояд
func sendDubResults(d *Deps, chatID int64, searchingMsgID int, lang string, results []dubResult) {
	if len(results) == 0 {
		edit := tgbotapi.NewEditMessageText(chatID, searchingMsgID, api.GetMessage(lang, "dub_no_results"))
		d.Bot.Send(edit)
		return
	}

	edit := tgbotapi.NewEditMessageText(chatID, searchingMsgID, api.GetMessage(lang, "dub_results_title"))
	d.Bot.Send(edit)

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
