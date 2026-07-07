package handlers

import (
	"fmt"
	"strings"
	"sync"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// dubResult натиҷаи якхелаи видео новобаста аз он ки аз кадом платформа омадааст
type dubResult struct {
	Title string
	URL   string
}

// rawDubResult натиҷаи хоми видео пеш аз илова кардани пешванди манбаъ —
// барои филтри рақами қисм лозим аст, то унвони аслӣ (бе "YouTube: " ва ғ.) санҷида шавад
type rawDubResult struct {
	Source string
	Title  string
	URL    string
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

	raw := fetchRawDubResults(d, searchQuery, 4, 0)
	results := capResults(prefixResults(raw), 6)
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

	raw := fetchRawDubResults(d, anime.Title, 4, id)
	results := capResults(prefixResults(raw), 6)
	sendDubResults(d, chatID, sentMsg.MessageID, lang, results)
}

// HandleSeasonDubCallback callback-и "seasondub:<animeID>:<seasonNum>"-ро
// коркард мекунад — дубляжро махсус барои қисмҳои ҳамин фасл (бо тартиби
// рақами қисм) меҷӯяд, то натиҷаҳои беробитаи франшизаҳои дигар (масалан
// Boruto ба ҷои Naruto) омехта нашаванд
func HandleSeasonDubCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	parts := strings.Split(cb.Data, ":")
	if len(parts) != 3 {
		return
	}
	animeID := atoi(parts[1])
	seasonNum := atoi(parts[2])
	if animeID == 0 || seasonNum <= 0 {
		return
	}

	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	anime := fetchAnimeCached(d, animeID)
	if anime == nil {
		sendText(d, chatID, api.GetMessage(lang, "anime_not_found"))
		return
	}

	minEp := (seasonNum-1)*seasonSize + 1
	maxEp := seasonNum * seasonSize

	searchingMsg := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "dub_season_searching"))
	sentMsg, _ := d.Bot.Send(searchingMsg)

	// Ба ҷои як ҷустуҷӯи умумӣ (ки танҳо натиҷаҳои болои рейтинги худи Aparat/
	// Dailymotion-ро мебинад ва аксар вақт бисёр қисмҳоро гум мекунад), ҳар
	// қисми фаслро АЛОҲИДА меҷӯем — ин сустар аст, вале имконияти ёфтани
	// ҳамаи 25 қисмро хеле зиёд мекунад
	results := searchSeasonPerEpisode(d, anime.Title, minEp, maxEp, animeID)

	if len(results) == 0 {
		// Ҳатто ҷустуҷӯи алоҳида чизе наёфт — ба ҷустуҷӯи умумии эҳтиётӣ мегузарем
		raw := fetchRawDubResultsWithLimits(d, anime.Title, dubSearchLimits{Aparat: 40, Dailymotion: 40, YouTube: 10, MaxRaw: 90}, animeID)
		ordered := api.FilterBySeasonRange(raw, func(r rawDubResult) string { return r.Title }, anime.Title, minEp, maxEp)
		if len(ordered) == 0 {
			edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, api.GetMessage(lang, "dub_season_fallback"))
			d.Bot.Send(edit)
			sendDubResults(d, chatID, 0, lang, prefixResults(raw))
			return
		}
		for _, r := range ordered {
			ep, _ := api.ExtractEpisodeNumber(r.Title)
			results = append(results, dubResult{
				Title: fmt.Sprintf("📺 #%d — %s: %s", ep, r.Source, r.Title),
				URL:   r.URL,
			})
		}
	}

	totalInSeason := maxEp - minEp + 1
	summary := fmt.Sprintf(api.GetMessage(lang, "dub_season_found_count"), len(results), totalInSeason)
	edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, summary)
	d.Bot.Send(edit)

	for _, r := range results {
		message := tgbotapi.NewMessage(chatID, fmt.Sprintf("%s\n%s", r.Title, r.URL))
		d.Bot.Send(message)
	}
}

// episodeHit як видеои ёфтшуда барои рақами қисми мушаххас
type episodeHit struct {
	source string
	title  string
	url    string
}

// searchSeasonPerEpisode барои ҳар рақами қисм дар доираи [minEp, maxEp]
// ҷустуҷӯи ҷудогона мекунад (масалан "Naruto قسمت 5"), на як ҷустуҷӯи
// умумии "Naruto". Ин муҳим аст, зеро ҷустуҷӯи умумӣ танҳо натиҷаҳои болои
// рейтинги худи платформаро медиҳад, ки метавонанд бисёр қисмҳоро дар бар
// нагиранд. Aparat ва Dailymotion ҳамзамон (дар ду goroutine) санҷида
// мешаванд, то вақти умумӣ кӯтоҳтар шавад; YouTube (сеҳмияи маҳдуд дорад)
// дар ин ҷустуҷӯи серхарҷ иштирок намекунад
func searchSeasonPerEpisode(d *Deps, animeTitle string, minEp int, maxEp int, animeID int) []dubResult {
	aparatHits := make(map[int]episodeHit)
	dailymotionHits := make(map[int]episodeHit)

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		for ep := minEp; ep <= maxEp; ep++ {
			query := fmt.Sprintf("%s قسمت %d", animeTitle, ep)
			videos, err := d.Aparat.SearchVideos(query, 3)
			if err != nil {
				utils.LogError("aparat per-episode search failed anime=%d ep=%d: %v", animeID, ep, err)
				continue
			}
			for _, v := range videos {
				if api.IsFranchiseMismatch(animeTitle, v.Title) {
					continue
				}
				if foundEp, ok := api.ExtractEpisodeNumber(v.Title); ok && foundEp == ep {
					aparatHits[ep] = episodeHit{source: "Aparat", title: v.Title, url: v.URL()}
					break
				}
			}
		}
	}()

	go func() {
		defer wg.Done()
		for ep := minEp; ep <= maxEp; ep++ {
			query := fmt.Sprintf("%s episode %d", animeTitle, ep)
			videos, err := d.Dailymotion.SearchVideos(query, 3)
			if err != nil {
				utils.LogError("dailymotion per-episode search failed anime=%d ep=%d: %v", animeID, ep, err)
				continue
			}
			for _, v := range videos {
				if api.IsFranchiseMismatch(animeTitle, v.Title) {
					continue
				}
				if foundEp, ok := api.ExtractEpisodeNumber(v.Title); ok && foundEp == ep {
					dailymotionHits[ep] = episodeHit{source: "Dailymotion", title: v.Title, url: v.URL}
					break
				}
			}
		}
	}()

	wg.Wait()

	results := make([]dubResult, 0, maxEp-minEp+1)
	for ep := minEp; ep <= maxEp; ep++ {
		hit, ok := aparatHits[ep]
		if !ok {
			hit, ok = dailymotionHits[ep]
		}
		if !ok {
			continue
		}
		results = append(results, dubResult{
			Title: fmt.Sprintf("📺 #%d — %s: %s", ep, hit.source, hit.title),
			URL:   hit.url,
		})
	}
	return results
}

// sendDubResults натиҷаҳоро нишон медиҳад. Пайвандҳо ҳамчун паёми оддии матнӣ
// (на тугмаи inline) фиристода мешаванд — Telegram худаш барои чунин пайвандҳо
// (алалхусус YouTube) видеои дарунсохти тамошошавандаро дар дохили чат нишон
// медиҳад, корбар аз Telegram берун намебарояд.
// Агар searchingMsgID=0 бошад (масалан вақте баъд аз паёми fallback фиристода
// мешавад), паёми "ҷустуҷӯ дар ҳол..." тағйир дода намешавад, танҳо натиҷаҳо илова мешаванд
func sendDubResults(d *Deps, chatID int64, searchingMsgID int, lang string, results []dubResult) {
	if len(results) == 0 {
		if searchingMsgID != 0 {
			edit := tgbotapi.NewEditMessageText(chatID, searchingMsgID, api.GetMessage(lang, "dub_no_results"))
			d.Bot.Send(edit)
		} else {
			sendText(d, chatID, api.GetMessage(lang, "dub_no_results"))
		}
		return
	}

	if searchingMsgID != 0 {
		edit := tgbotapi.NewEditMessageText(chatID, searchingMsgID, api.GetMessage(lang, "dub_results_title"))
		d.Bot.Send(edit)
	}

	for _, r := range results {
		message := tgbotapi.NewMessage(chatID, fmt.Sprintf("%s\n%s", r.Title, r.URL))
		d.Bot.Send(message)
	}
}

// capResults рӯйхатро то ҳадди муайян кӯтоҳ мекунад
func capResults(results []dubResult, max int) []dubResult {
	if len(results) > max {
		return results[:max]
	}
	return results
}

// prefixResults ба ҳар натиҷа номи манбаъро илова мекунад, то корбар донад аз куҷо омадааст
func prefixResults(raw []rawDubResult) []dubResult {
	results := make([]dubResult, 0, len(raw))
	for _, r := range raw {
		results = append(results, dubResult{Title: r.Source + ": " + r.Title, URL: r.URL})
	}
	return results
}

// dubSearchLimits шумораи натиҷаҳое, ки аз ҳар платформа дархост карда мешавад
type dubSearchLimits struct {
	Aparat      int
	Dailymotion int
	YouTube     int
	MaxRaw      int
}

// fetchRawDubResults ҳамаи платформаҳои видеоро бо ҳадди пешфарз (мувофиқ ба
// ҷустуҷӯи оддӣ) мепурсад
func fetchRawDubResults(d *Deps, title string, perSource int, animeID int) []rawDubResult {
	return fetchRawDubResultsWithLimits(d, title, dubSearchLimits{
		Aparat: perSource, Dailymotion: perSource, YouTube: perSource, MaxRaw: 30,
	}, animeID)
}

// fetchRawDubResultsWithLimits ҳамаи платформаҳои видеоро мепурсад ва
// натиҷаҳоро якҷоя мекунад (бе пешванди манбаъ). Агар як платформа хато диҳад
// ё чизе наёбад, платформаҳои дигар ҳамоно санҷида мешаванд
func fetchRawDubResultsWithLimits(d *Deps, title string, limits dubSearchLimits, animeID int) []rawDubResult {
	var raw []rawDubResult

	aparatVideos, err := d.Aparat.SearchVideos(title, limits.Aparat)
	if err != nil {
		utils.LogError("aparat search failed for anime=%d: %v", animeID, err)
	}
	for _, v := range aparatVideos {
		raw = append(raw, rawDubResult{Source: "Aparat", Title: v.Title, URL: v.URL()})
	}

	dailymotionVideos, err := d.Dailymotion.SearchVideos(title, limits.Dailymotion)
	if err != nil {
		utils.LogError("dailymotion search failed for anime=%d: %v", animeID, err)
	}
	for _, v := range dailymotionVideos {
		raw = append(raw, rawDubResult{Source: "Dailymotion", Title: v.Title, URL: v.URL})
	}

	if d.YouTube.Enabled() {
		// Дар YouTube ҷустуҷӯи танҳо номи аниме бисёр натиҷаи расмии бе дубляж
		// медиҳад — "дубле форсӣ" мушаххас каналҳои дубляжро меёбад
		youtubeVideos, err := d.YouTube.SearchVideos(title+" دوبله فارسی", limits.YouTube)
		if err != nil {
			utils.LogError("youtube search failed for anime=%d: %v", animeID, err)
		}
		for _, v := range youtubeVideos {
			raw = append(raw, rawDubResult{Source: "YouTube", Title: v.Title, URL: v.URL})
		}
	}

	if limits.MaxRaw > 0 && len(raw) > limits.MaxRaw {
		raw = raw[:limits.MaxRaw]
	}
	return raw
}
