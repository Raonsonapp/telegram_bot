package handlers

import (
	"fmt"
	"math/rand"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/keyboard"
	"appbuilder-bot/backend/utils"
)

// PendingMood нигоҳ медорад кадом корбарон мунтазири тавсифи кайфияти худ ҳастанд
var PendingMood = make(map[int64]bool)

// genreKeywords вожаҳои калидӣ бо якчанд забон, ки ба жанрҳои Jikan мувофиқат мекунанд.
// ID-ҳо ID-ҳои жанри стандартии MyAnimeList/Jikan мебошанд
var genreKeywords = map[int][]string{
	1:  {"экшн", "боевик", "ҷанг", "джанг", "мубориза", "action"},
	2:  {"саёҳат", "приключен", "adventure"},
	4:  {"ханда", "хандаовар", "комедия", "смешн", "мазах", "comedy", "funny"},
	7:  {"асрор", "детектив", "муаммо", "сирри", "mystery"},
	8:  {"драма", "ғам", "ғамангез", "ғамгин", "грустн", "drama"},
	10: {"сеҳр", "фэнтези", "фантези", "ҷодуги", "магия", "fantasy"},
	14: {"тарс", "тарсовар", "ваҳм", "ужас", "хоррор", "horror", "scary"},
	18: {"робот", "механиком", "меха", "mecha"},
	19: {"мусиқӣ", "музыка", "music"},
	22: {"ошиқ", "ошиқона", "ишқ", "мехрубон", "любов", "романтик", "romance"},
	24: {"фантастика", "илмӣ", "космос", "sci-fi", "scifi"},
	30: {"варзиш", "спорт", "футбол", "sports"},
	36: {"оромона", "хаёти оддӣ", "повседневн", "slice of life"},
	37: {"фавқулодда", "сверхъестествен", "supernatural"},
	40: {"психологи", "psychological"},
	41: {"ҳаяҷон", "триллер", "thriller"},
}

// detectGenres матни корбарро месанҷад ва ID-ҳои жанрҳои мувофиқро бармегардонад
func detectGenres(text string) []int {
	lower := strings.ToLower(text)
	var found []int
	for genreID, words := range genreKeywords {
		for _, w := range words {
			if strings.Contains(lower, w) {
				found = append(found, genreID)
				break
			}
		}
	}
	return found
}

// HandleMoodButton вақте ки корбар тугмаи "🎭 Аз рӯи кайфият пешниҳод кун"-ро пахш мекунад
func HandleMoodButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	PendingMood[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_mood"))
}

// HandleMoodText матни тавсифи кайфияти корбарро коркард мекунад ва аниме пешниҳод мекунад
func HandleMoodText(d *Deps, msg *tgbotapi.Message) {
	PendingMood[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)
	text := strings.TrimSpace(msg.Text)

	loading := tgbotapi.NewMessage(msg.Chat.ID, api.GetMessage(lang, "mood_searching"))
	sentMsg, _ := d.Bot.Send(loading)

	genres := detectGenres(text)
	if len(genres) == 0 {
		// Агар жанре муайян нашуд, ҳамчун ҷустуҷӯи оддӣ бо худи матн амал мекунем
		editErr := tgbotapi.NewEditMessageText(msg.Chat.ID, sentMsg.MessageID, fmt.Sprintf(api.GetMessage(lang, "searching"), text))
		d.Bot.Send(editErr)
		PerformSearch(d, msg.Chat.ID, msg.From.ID, text)
		return
	}
	if len(genres) > 2 {
		rand.Shuffle(len(genres), func(i, j int) { genres[i], genres[j] = genres[j], genres[i] })
		genres = genres[:2]
	}

	results, err := d.Jikan.SearchByGenres(genres, 15)
	if err != nil || len(results) == 0 {
		utils.LogError("mood recommend failed: %v", err)
		edit := tgbotapi.NewEditMessageText(msg.Chat.ID, sentMsg.MessageID, api.GetMessage(lang, "error_generic"))
		d.Bot.Send(edit)
		return
	}

	pickCount := len(results)
	if pickCount > 5 {
		pickCount = 5
	}
	rand.Shuffle(len(results), func(i, j int) { results[i], results[j] = results[j], results[i] })
	picked := results[:pickCount]

	for _, a := range picked {
		d.Cache.Set(fmt.Sprintf("anime:%d", a.MalID), a)
	}

	edit := tgbotapi.NewEditMessageTextAndMarkup(msg.Chat.ID, sentMsg.MessageID, api.GetMessage(lang, "mood_result_intro"), keyboard.SearchResultsKeyboard(picked))
	d.Bot.Send(edit)
}
