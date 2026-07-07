package handlers

import (
	"fmt"
	"strconv"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/keyboard"
	"anime-bot/backend/models"
	"anime-bot/backend/utils"
)

// HandleAnimeCallback callback-и "anime:<id>"-ро коркард мекунад
func HandleAnimeCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	id, ok := utils.ParseCallbackID(cb.Data, "anime:")
	if !ok {
		return
	}

	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	anime := fetchAnimeCached(d, id)
	if anime == nil {
		editErr := tgbotapi.NewEditMessageText(chatID, cb.Message.MessageID, api.GetMessage(lang, "anime_not_found"))
		d.Bot.Send(editErr)
		return
	}

	sendAnimeDetail(d, chatID, cb.From.ID, lang, *anime)
}

// fetchAnimeCached аввал cache-ро месанҷад, баъд аз Jikan мегирад
func fetchAnimeCached(d *Deps, id int) *models.Anime {
	cacheKey := fmt.Sprintf("anime:%d", id)
	if cached, ok := d.Cache.Get(cacheKey); ok {
		if anime, valid := cached.(models.Anime); valid {
			return &anime
		}
	}

	anime, err := d.Jikan.GetAnimeByID(id)
	if err != nil {
		utils.LogError("failed to get anime id=%d: %v", id, err)
		return nil
	}
	d.Cache.Set(cacheKey, *anime)
	return anime
}

// sendAnimeDetail паёми пурраи тафсилоти аниме-ро мефиристад
func sendAnimeDetail(d *Deps, chatID int64, telegramID int64, lang string, anime models.Anime) {
	if err := d.DB.LogRecentlyViewed(telegramID, anime); err != nil {
		utils.LogError("failed to log recently viewed anime=%d: %v", anime.MalID, err)
	}
	isFav, err := d.DB.IsFavorite(telegramID, anime.MalID)
	if err != nil {
		utils.LogError("failed to check favorite status anime=%d: %v", anime.MalID, err)
	}
	status, err := d.DB.GetWatchStatus(telegramID, anime.MalID)
	if err != nil {
		utils.LogError("failed to get watch status anime=%d: %v", anime.MalID, err)
	}

	text := formatAnimeDetail(d, anime, lang)
	keyb := keyboard.AnimeDetailKeyboard(anime, lang, isFav, status)

	imageURL := anime.Images.JPG.LargeImageURL
	if imageURL == "" {
		imageURL = anime.Images.JPG.ImageURL
	}

	if imageURL != "" {
		photo := tgbotapi.NewPhoto(chatID, tgbotapi.FileURL(imageURL))
		photo.Caption = text
		photo.ParseMode = tgbotapi.ModeMarkdown
		photo.ReplyMarkup = keyb
		if _, err := d.Bot.Send(photo); err == nil {
			return
		}
		utils.LogError("failed to send anime photo, falling back to text")
	}

	message := tgbotapi.NewMessage(chatID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyb
	d.Bot.Send(message)
}

// formatAnimeDetail матни форматшудаи тафсилоти аниме-ро месозад
func formatAnimeDetail(d *Deps, anime models.Anime, lang string) string {
	title := anime.Title
	if anime.TitleEnglish != "" && anime.TitleEnglish != anime.Title {
		title = fmt.Sprintf("%s (%s)", anime.Title, anime.TitleEnglish)
	}

	var genreNames []string
	for _, g := range anime.Genres {
		genreNames = append(genreNames, g.Name)
	}

	synopsis := utils.Truncate(strings.TrimSpace(anime.Synopsis), 500)
	if synopsis == "" {
		synopsis = "N/A"
	} else {
		synopsis = translatedSynopsis(d, anime.MalID, synopsis, lang)
	}

	return fmt.Sprintf(
		"*%s*\n\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %d\n%s: %s\n\n%s",
		utils.EscapeMarkdown(title),
		api.GetMessage(lang, "score_label"), utils.FormatScore(anime.Score),
		api.GetMessage(lang, "episodes_label"), utils.FormatEpisodes(anime.Episodes),
		api.GetMessage(lang, "status_label"), anime.Status,
		api.GetMessage(lang, "type_label"), anime.Type,
		api.GetMessage(lang, "year_label"), anime.Year,
		api.GetMessage(lang, "genres_label"), utils.JoinGenres(genreNames),
		utils.EscapeMarkdown(synopsis),
	)
}

// translatedSynopsis тавсифро ба забони корбар тарҷума мекунад ва натиҷаро кэш мекунад,
// то барои як аниме дар як забон танҳо як бор ба хидмати тарҷума мурочиат шавад
func translatedSynopsis(d *Deps, animeID int, text string, lang string) string {
	cacheKey := fmt.Sprintf("synopsis:%d:%s", animeID, lang)
	if cached, ok := d.Cache.Get(cacheKey); ok {
		if s, valid := cached.(string); valid {
			return s
		}
	}
	translated := utils.Truncate(d.Translator.Translate(text, lang), 500)
	d.Cache.Set(cacheKey, translated)
	return translated
}

// HandleRandomAnime фармони /random ва тугмаи "🎲 Random Anime"-ро коркард мекунад
func HandleRandomAnime(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	loadingMsg := tgbotapi.NewMessage(msg.Chat.ID, api.GetMessage(lang, "random_loading"))
	d.Bot.Send(loadingMsg)

	anime, err := d.Jikan.GetRandomAnime()
	if err != nil {
		utils.LogError("failed to get random anime: %v", err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "error_generic"))
		return
	}
	d.Cache.Set(fmt.Sprintf("anime:%d", anime.MalID), *anime)
	sendAnimeDetail(d, msg.Chat.ID, msg.From.ID, lang, *anime)
}

// HandleTopAnime фармони /top ва тугмаи "🏆 Top Anime"-ро коркард мекунад
func HandleTopAnime(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)

	topList, err := d.Jikan.GetTopAnime(10)
	if err != nil {
		utils.LogError("failed to get top anime: %v", err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "error_generic"))
		return
	}

	for _, a := range topList {
		d.Cache.Set(fmt.Sprintf("anime:%d", a.MalID), a)
	}

	text := api.GetMessage(lang, "top_title")
	message := tgbotapi.NewMessage(msg.Chat.ID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyboard.SearchResultsKeyboard(topList)
	d.Bot.Send(message)
}

// HandleBackToMenu callback-и "back:menu"-ро коркард мекунад
func HandleBackToMenu(d *Deps, cb *tgbotapi.CallbackQuery) {
	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	text := api.GetMessage(lang, "main_menu")
	message := tgbotapi.NewMessage(cb.Message.Chat.ID, text)
	message.ReplyMarkup = keyboard.MainMenu(lang)
	d.Bot.Send(message)
}

// atoi як ёрирасони кӯтоҳ барои табдили сатр ба рақам (истифода дар episodes.go низ)
func atoi(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}
