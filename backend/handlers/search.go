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

// HandleSearchCommand фармони /search [номи аниме]-ро коркард мекунад
func HandleSearchCommand(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	query := strings.TrimSpace(msg.CommandArguments())

	if query == "" {
		PendingSearch[msg.From.ID] = true
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_search_query"))
		return
	}
	PendingSearch[msg.From.ID] = false
	PerformSearch(d, msg.Chat.ID, msg.From.ID, query)
}

// HandleSearchButton вақте ки корбар тугмаи "🔍 Search Anime"-ро пахш мекунад
func HandleSearchButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	PendingSearch[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_search_query"))
}

// HandlePlainTextSearch вақте ки корбар матни оддӣ мефиристад (пас аз дархости ҷустуҷӯ)
func HandlePlainTextSearch(d *Deps, msg *tgbotapi.Message) {
	PendingSearch[msg.From.ID] = false
	PerformSearch(d, msg.Chat.ID, msg.From.ID, strings.TrimSpace(msg.Text))
}

// PerformSearch дархости ҷустуҷӯро ба Jikan API мефиристад ва натиҷаро нишон медиҳад
func PerformSearch(d *Deps, chatID int64, telegramID int64, query string) {
	lang := getUserLang(d, telegramID)

	if query == "" {
		sendText(d, chatID, api.GetMessage(lang, "ask_search_query"))
		return
	}

	searchingMsg := tgbotapi.NewMessage(chatID, fmt.Sprintf(api.GetMessage(lang, "searching"), query))
	sentMsg, _ := d.Bot.Send(searchingMsg)

	animeResults, usedQuery, err := searchWithCyrillicFallback(d, query, lang)
	if err != nil {
		utils.LogError("search failed for query=%q: %v", query, err)
		editErr := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, api.GetMessage(lang, "error_generic"))
		d.Bot.Send(editErr)
		return
	}

	if len(animeResults) == 0 {
		text := fmt.Sprintf(api.GetMessage(lang, "no_results"), query)
		edit := tgbotapi.NewEditMessageText(chatID, sentMsg.MessageID, text)
		d.Bot.Send(edit)
		return
	}

	cacheKey := "search:" + strings.ToLower(usedQuery)
	d.Cache.Set(cacheKey, animeResults)
	for _, a := range animeResults {
		d.Cache.Set(fmt.Sprintf("anime:%d", a.MalID), a)
	}

	text := fmt.Sprintf(api.GetMessage(lang, "search_results"), query)
	edit := tgbotapi.NewEditMessageTextAndMarkup(chatID, sentMsg.MessageID, text, keyboard.SearchResultsKeyboard(animeResults))
	d.Bot.Send(edit)
}

// searchWithCyrillicFallback Jikan/AniList танҳо бо номи англисӣ/лотинии аниме
// ҷустуҷӯ мекунанд. Агар матн кириллӣ (тоҷикӣ/русӣ) бошад, паси ҳам якчанд роҳро
// меозмояд: аввал транслитератсияи фонетикӣ (масалан "Наруто" -> "naruto" — барои
// номҳои хос ин аз тарҷумаи мошинӣ боэътимодтар аст), баъд тарҷумаи мошинӣ (барои
// ибораҳои тавсифӣ). Натиҷаи аввалини муваффақро бармегардонад
func searchWithCyrillicFallback(d *Deps, query string, lang string) ([]models.Anime, string, error) {
	if !utils.ContainsCyrillic(query) {
		results, err := d.Jikan.SearchAnime(query, 6)
		return results, query, err
	}

	var lastErr error

	transliterated := utils.TransliterateCyrillicToLatin(query)
	results, err := d.Jikan.SearchAnime(transliterated, 6)
	if err == nil && len(results) > 0 {
		return results, transliterated, nil
	}
	if err != nil {
		lastErr = err
		utils.LogError("transliterated search failed for query=%q (%q): %v", query, transliterated, err)
	}

	if translated := d.Translator.TranslateToEnglish(query, lang); translated != "" && translated != query {
		results, err = d.Jikan.SearchAnime(translated, 6)
		if err == nil && len(results) > 0 {
			return results, translated, nil
		}
		if err != nil {
			lastErr = err
			utils.LogError("translated search failed for query=%q (%q): %v", query, translated, err)
		}
	}

	if lastErr != nil {
		return nil, transliterated, lastErr
	}
	return nil, transliterated, nil
}
