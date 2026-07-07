package handlers

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"

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

	raw := fetchRawDubResults(d, searchQuery, 4, 0, lang)
	results := capResults(prefixResults(raw, lang, searchQuery), 6)
	results = filterAliveLinks(results)
	sendDubResults(d, chatID, sentMsg.MessageID, lang, results, searchQuery)
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

	raw := fetchRawDubResults(d, anime.Title, 4, id, lang)
	results := capResults(prefixResults(raw, lang, anime.Title), 6)
	results = filterAliveLinks(results)
	sendDubResults(d, chatID, sentMsg.MessageID, lang, results, anime.Title)
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
	results := searchSeasonPerEpisode(d, lang, anime.Title, minEp, maxEp, animeID)

	if len(results) == 0 {
		// Ҳатто ҷустуҷӯи алоҳида чизе наёфт — ба ҷустуҷӯи умумии эҳтиётӣ мегузарем
		raw := fetchRawDubResultsWithLimits(d, anime.Title, dubSearchLimits{Aparat: 40, Dailymotion: 40, YouTube: 10, MaxRaw: 90}, animeID, lang)
		ordered := api.FilterBySeasonRange(raw, func(r rawDubResult) string { return r.Title }, anime.Title, minEp, maxEp)
		if len(ordered) == 0 {
			edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, api.GetMessage(lang, "dub_season_fallback"))
			d.Bot.Send(edit)
			sendDubResults(d, chatID, 0, lang, filterAliveLinks(prefixResults(raw, lang, anime.Title)), anime.Title)
			return
		}
		for _, r := range ordered {
			results = append(results, dubResult{
				Title: buildResultLabel(lang, anime.Title, r.Source, r.Title),
				URL:   r.URL,
			})
		}
	}

	results = filterAliveLinks(results)

	if len(results) == 0 {
		sendDubResults(d, chatID, sentMsg.MessageID, lang, results, anime.Title)
		return
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

// dubBiasTerm калимаи иловагиро бармегардонад, ки ба ҷустуҷӯ мувофиқи забони
// корбар илова карда мешавад, то видеои дубляжшуда бо ҳамон забон ёфт шавад
// (на бо забони дигар — масалан корбари русзабон дубляжи форсӣ намехоҳад)
func dubBiasTerm(lang string) string {
	switch lang {
	case "fa":
		return "دوبله فارسی"
	case "ru":
		return "русская озвучка"
	default:
		return "english dub"
	}
}

// searchSeasonPerEpisode барои ҳар рақами қисм дар доираи [minEp, maxEp]
// ҷустуҷӯи ҷудогона мекунад (масалан "Naruto قسمت 5"), на як ҷустуҷӯи
// умумии "Naruto". Ин муҳим аст, зеро ҷустуҷӯи умумӣ танҳо натиҷаҳои болои
// рейтинги худи платформаро медиҳад, ки метавонанд бисёр қисмҳоро дар бар
// нагиранд. Aparat платформаи форсизабон аст (дубляжи русӣ/англисӣ надорад),
// барои ҳамин танҳо вақте ки забони корбар "fa" (тоҷикӣ) аст санҷида мешавад.
// Dailymotion ҳамеша (дар goroutine-и алоҳида) санҷида мешавад; YouTube
// (сеҳмияи маҳдуд дорад) дар ин ҷустуҷӯи серхарҷи аввала иштирок намекунад,
// вале баъд танҳо барои қисмҳое, ки то ин ҷо ёфт нашуданд, санҷида мешавад
func searchSeasonPerEpisode(d *Deps, lang string, animeTitle string, minEp int, maxEp int, animeID int) []dubResult {
	aparatHits := make(map[int]episodeHit)
	dailymotionHits := make(map[int]episodeHit)
	bias := dubBiasTerm(lang)

	var wg sync.WaitGroup

	if lang == "fa" {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for ep := minEp; ep <= maxEp; ep++ {
				query := fmt.Sprintf("%s قسمت %d دوبله", animeTitle, ep)
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
	}

	wg.Add(1)
	go func() {
		defer wg.Done()
		for ep := minEp; ep <= maxEp; ep++ {
			query := fmt.Sprintf("%s episode %d %s", animeTitle, ep, bias)
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

	youtubeHits := make(map[int]episodeHit)
	if d.YouTube.Enabled() {
		for ep := minEp; ep <= maxEp; ep++ {
			if _, ok := aparatHits[ep]; ok {
				continue
			}
			if _, ok := dailymotionHits[ep]; ok {
				continue
			}
			query := fmt.Sprintf("%s episode %d %s", animeTitle, ep, bias)
			videos, err := d.YouTube.SearchVideos(query, 3)
			if err != nil {
				utils.LogError("youtube per-episode search failed anime=%d ep=%d: %v", animeID, ep, err)
				continue
			}
			for _, v := range videos {
				if api.IsFranchiseMismatch(animeTitle, v.Title) {
					continue
				}
				if foundEp, ok := api.ExtractEpisodeNumber(v.Title); ok && foundEp == ep {
					youtubeHits[ep] = episodeHit{source: "YouTube", title: v.Title, url: v.URL}
					break
				}
			}
		}
	}

	results := make([]dubResult, 0, maxEp-minEp+1)
	for ep := minEp; ep <= maxEp; ep++ {
		hit, ok := aparatHits[ep]
		if !ok {
			hit, ok = dailymotionHits[ep]
		}
		if !ok {
			hit, ok = youtubeHits[ep]
		}
		if !ok {
			continue
		}
		results = append(results, dubResult{
			Title: buildResultLabel(lang, animeTitle, hit.source, hit.title),
			URL:   hit.url,
		})
	}
	return results
}

// filimoSuggestionKeyboard тугмаи "Санҷидан дар Filimo"-ро месозад, ки ба
// саҳифаи миёнарави худи мо мебарад (на бевосита ба Filimo, то матни тоҷикӣ
// пеш аз он нишон дода шавад). Агар PublicBaseURL танзим нашуда бошад (масалан
// дар рушди маҳаллӣ), nil бармегардонад — тугма нишон дода намешавад
func filimoSuggestionKeyboard(d *Deps, lang string, animeTitle string) *tgbotapi.InlineKeyboardMarkup {
	if d.Config.PublicBaseURL == "" {
		return nil
	}
	link := d.Config.PublicBaseURL + "/filimo?title=" + url.QueryEscape(animeTitle)
	keyboard := tgbotapi.NewInlineKeyboardMarkup(
		tgbotapi.NewInlineKeyboardRow(tgbotapi.NewInlineKeyboardButtonURL(api.GetMessage(lang, "btn_check_filimo"), link)),
	)
	return &keyboard
}

// sendDubResults натиҷаҳоро нишон медиҳад. Пайвандҳо ҳамчун паёми оддии матнӣ
// (на тугмаи inline) фиристода мешаванд — Telegram худаш барои чунин пайвандҳо
// (алалхусус YouTube) видеои дарунсохти тамошошавандаро дар дохили чат нишон
// медиҳад, корбар аз Telegram берун намебарояд.
// Агар searchingMsgID=0 бошад (масалан вақте баъд аз паёми fallback фиристода
// мешавад), паёми "ҷустуҷӯ дар ҳол..." тағйир дода намешавад, танҳо натиҷаҳо илова мешаванд.
// refTitle барои сохтани тугмаи пешниҳоди Filimo дар ҳолати натиҷаи холӣ лозим аст
func sendDubResults(d *Deps, chatID int64, searchingMsgID int, lang string, results []dubResult, refTitle string) {
	if len(results) == 0 {
		noResultsText := api.GetMessage(lang, "dub_no_results")
		keyboard := filimoSuggestionKeyboard(d, lang, refTitle)
		if searchingMsgID != 0 {
			if keyboard != nil {
				edit := tgbotapi.NewEditMessageTextAndMarkup(chatID, searchingMsgID, noResultsText, *keyboard)
				d.Bot.Send(edit)
			} else {
				edit := tgbotapi.NewEditMessageText(chatID, searchingMsgID, noResultsText)
				d.Bot.Send(edit)
			}
		} else {
			message := tgbotapi.NewMessage(chatID, noResultsText)
			if keyboard != nil {
				message.ReplyMarkup = *keyboard
			}
			d.Bot.Send(message)
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

// prefixResults ба ҳар натиҷа лейбели пурраи маҳаллисозишударо месозад (ба
// ҷои нишон додани унвони хоми платформа, ки одатан бо забони форсӣ аст)
func prefixResults(raw []rawDubResult, lang string, refTitle string) []dubResult {
	results := make([]dubResult, 0, len(raw))
	for _, r := range raw {
		results = append(results, dubResult{Title: buildResultLabel(lang, refTitle, r.Source, r.Title), URL: r.URL})
	}
	return results
}

// buildResultLabel ба ҷои унвони хоми платформа (ки одатан бо забони форсӣ
// аст ва корбар онро намефаҳмад), лейбели пурра дар забони интерфейси корбар
// месозад — масалан "📺 Naruto — Қисми 5 (Aparat)" ба ҷои матни хоми форсӣ
func buildResultLabel(lang, refTitle, source, rawTitle string) string {
	if ep, ok := api.ExtractEpisodeNumber(rawTitle); ok {
		epLabel := fmt.Sprintf(api.GetMessage(lang, "episode_line_label"), ep)
		return fmt.Sprintf("📺 %s — %s (%s)", refTitle, epLabel, source)
	}
	return fmt.Sprintf("📺 %s (%s)", refTitle, source)
}

// linkCheckClient барои санҷиши зудаи он ки оё пайванди видео воқеан кор
// мекунад (на 404-и вайроншуда), пеш аз фиристодан ба корбар
var linkCheckClient = &http.Client{Timeout: 5 * time.Second}

// isLinkAlive месанҷад, ки пайванд ҳанӯз дастрас аст. Аз GET бо Range
// истифода мешавад (на HEAD), зеро баъзе платформаҳо (масалан Aparat) HEAD-ро
// дуруст дастгирӣ намекунанд ва метавонанд хатои бардурӯғ диҳанд. Танҳо 404-и
// возеҳ (саҳифа воқеан ҳазф шудааст) сабаби хориҷ кардан аст — дар ҳар гуна
// ҳолати номуайян (хатои шабака, коди дигар) пайванд нигоҳ дошта мешавад,
// беҳтар аз хориҷ кардани натиҷаи эҳтимолан дурусте, ки дар назорати мо нест
func isLinkAlive(rawURL string) bool {
	req, err := http.NewRequest(http.MethodGet, rawURL, nil)
	if err != nil {
		return true
	}
	req.Header.Set("User-Agent", "anime-bot/1.0 (+https://github.com)")
	req.Header.Set("Range", "bytes=0-2048")
	resp, err := linkCheckClient.Do(req)
	if err != nil {
		return true
	}
	defer resp.Body.Close()
	io.Copy(io.Discard, resp.Body)
	return resp.StatusCode != http.StatusNotFound
}

// filterAliveLinks пайвандҳои вайроншударо (масалан видеоҳои ҳазфшудаи
// Aparat, ки 404 бармегардонанд) хориҷ мекунад, то корбар пайванди мурда
// нагирад. Санҷиш ҳамзамон (concurrent) аст, то вақти умумӣ кӯтоҳ монад
func filterAliveLinks(results []dubResult) []dubResult {
	alive := make([]bool, len(results))
	var wg sync.WaitGroup
	for i, r := range results {
		wg.Add(1)
		go func(i int, url string) {
			defer wg.Done()
			alive[i] = isLinkAlive(url)
		}(i, r.URL)
	}
	wg.Wait()

	filtered := make([]dubResult, 0, len(results))
	for i, r := range results {
		if alive[i] {
			filtered = append(filtered, r)
		}
	}
	return filtered
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
func fetchRawDubResults(d *Deps, title string, perSource int, animeID int, lang string) []rawDubResult {
	return fetchRawDubResultsWithLimits(d, title, dubSearchLimits{
		Aparat: perSource, Dailymotion: perSource, YouTube: perSource, MaxRaw: 30,
	}, animeID, lang)
}

// fetchRawDubResultsWithLimits ҳамаи платформаҳои видеоро мепурсад ва
// натиҷаҳоро якҷоя мекунад (бе пешванди манбаъ). Агар як платформа хато диҳад
// ё чизе наёбад, платформаҳои дигар ҳамоно санҷида мешаванд. Aparat
// платформаи форсизабон аст — танҳо вақте ки забони корбар "fa" (тоҷикӣ)
// аст санҷида мешавад, вагарна барои корбарони русу англисзабон вақти беҳуда
// сарф мешуд (Aparat дубляжи русӣ/англисӣ надорад)
func fetchRawDubResultsWithLimits(d *Deps, title string, limits dubSearchLimits, animeID int, lang string) []rawDubResult {
	var raw []rawDubResult
	bias := dubBiasTerm(lang)

	if lang == "fa" {
		aparatVideos, err := d.Aparat.SearchVideos(title+" دوبله", limits.Aparat)
		if err != nil {
			utils.LogError("aparat search failed for anime=%d: %v", animeID, err)
		}
		for _, v := range aparatVideos {
			if api.IsFranchiseMismatch(title, v.Title) {
				continue
			}
			raw = append(raw, rawDubResult{Source: "Aparat", Title: v.Title, URL: v.URL()})
		}
	}

	dailymotionVideos, err := d.Dailymotion.SearchVideos(title+" "+bias, limits.Dailymotion)
	if err != nil {
		utils.LogError("dailymotion search failed for anime=%d: %v", animeID, err)
	}
	for _, v := range dailymotionVideos {
		if api.IsFranchiseMismatch(title, v.Title) {
			continue
		}
		raw = append(raw, rawDubResult{Source: "Dailymotion", Title: v.Title, URL: v.URL})
	}

	if d.YouTube.Enabled() {
		// Ҷустуҷӯи танҳо номи аниме бисёр натиҷаи расмии бе дубляж медиҳад —
		// калимаи иловагии мувофиқи забон мушаххас каналҳои дубляжро меёбад
		youtubeVideos, err := d.YouTube.SearchVideos(title+" "+bias, limits.YouTube)
		if err != nil {
			utils.LogError("youtube search failed for anime=%d: %v", animeID, err)
		}
		for _, v := range youtubeVideos {
			if api.IsFranchiseMismatch(title, v.Title) {
				continue
			}
			raw = append(raw, rawDubResult{Source: "YouTube", Title: v.Title, URL: v.URL})
		}
	}

	if limits.MaxRaw > 0 && len(raw) > limits.MaxRaw {
		raw = raw[:limits.MaxRaw]
	}
	return raw
}
