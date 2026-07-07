package handlers

import (
	"fmt"
	"strings"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/keyboard"
	"anime-bot/backend/models"
	"anime-bot/backend/utils"
)

// seasonSize шумораи қисмҳо дар як "фасл"-и намоишӣ. MAL/Jikan фасли воқеӣ
// надорад — ин танҳо тақсимоти намоишӣ аст, то рӯйхати анимеҳои дуруши
// (масалан 220 қисм) осонтар кушода шавад
const seasonSize = 25

// episodesPerJikanPage шумораи қисмҳо дар як саҳифаи Jikan (собит аз рӯи API)
const episodesPerJikanPage = 100

// HandleSeasonMenuCallback callback-и "seasons:<animeID>"-ро коркард мекунад —
// рӯйхати фаслҳоро (ҳар фасл seasonSize қисм) нишон медиҳад
func HandleSeasonMenuCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	id, ok := utils.ParseCallbackID(cb.Data, "seasons:")
	if !ok {
		return
	}

	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	anime := fetchAnimeCached(d, id)
	if anime == nil || anime.Episodes <= 0 {
		sendText(d, chatID, api.GetMessage(lang, "anime_not_found"))
		return
	}

	totalSeasons := (anime.Episodes + seasonSize - 1) / seasonSize
	text := fmt.Sprintf(api.GetMessage(lang, "choose_season"), utils.EscapeMarkdown(anime.Title))

	message := tgbotapi.NewMessage(chatID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyboard.SeasonMenuKeyboard(id, anime.Episodes, totalSeasons, lang)
	d.Bot.Send(message)
}

// HandleSeasonEpisodesCallback callback-и "season:<animeID>:<seasonNum>"-ро
// коркард мекунад — ҳамаи қисмҳои он фаслро якҷоя нишон медиҳад
func HandleSeasonEpisodesCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
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
	animeTitle := "Anime"
	totalEpisodes := 0
	if anime != nil {
		animeTitle = anime.Title
		totalEpisodes = anime.Episodes
	}

	cacheKey := fmt.Sprintf("season:%d:%d", animeID, seasonNum)
	var episodesText string
	if cached, ok := d.Cache.Get(cacheKey); ok {
		if text, valid := cached.(string); valid {
			episodesText = text
		}
	}

	if episodesText == "" {
		seasonsPerJikanPage := episodesPerJikanPage / seasonSize
		jikanPage := ((seasonNum - 1) / seasonsPerJikanPage) + 1
		localIndex := (seasonNum - 1) % seasonsPerJikanPage

		episodes, _, err := d.Jikan.GetAnimeEpisodes(animeID, jikanPage)
		if err != nil {
			utils.LogError("failed to get episodes for anime=%d season=%d: %v", animeID, seasonNum, err)
			sendText(d, chatID, api.GetMessage(lang, "error_generic"))
			return
		}

		start := localIndex * seasonSize
		end := start + seasonSize
		if start > len(episodes) {
			start = len(episodes)
		}
		if end > len(episodes) {
			end = len(episodes)
		}
		episodesText = formatEpisodesList(episodes[start:end], lang)
		d.Cache.Set(cacheKey, episodesText)
	}

	totalSeasons := 1
	if totalEpisodes > 0 {
		totalSeasons = (totalEpisodes + seasonSize - 1) / seasonSize
	}

	title := fmt.Sprintf(api.GetMessage(lang, "season_title"), seasonNum, utils.EscapeMarkdown(animeTitle))
	fullText := title + "\n\n" + episodesText

	message := tgbotapi.NewMessage(chatID, fullText)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyboard.SeasonEpisodesKeyboard(animeID, seasonNum, totalSeasons, lang)
	d.Bot.Send(message)
}

// HandleEpisodesCallback callback-и "episodes:<animeID>:<page>"-ро коркард мекунад.
// Ин роҳи кӯҳна барои анимеҳое истифода мешавад, ки ба фасл тақсим намешаванд
// (масалан камтар аз seasonSize қисм ё шумораи қисмҳояшон маълум нест)
func HandleEpisodesCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	// data формат: episodes:123:1
	parts := strings.Split(cb.Data, ":")
	if len(parts) != 3 {
		return
	}
	animeID := atoi(parts[1])
	page := atoi(parts[2])
	if animeID == 0 {
		return
	}
	if page <= 0 {
		page = 1
	}

	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	anime := fetchAnimeCached(d, animeID)
	animeTitle := "Anime"
	if anime != nil {
		animeTitle = anime.Title
	}

	cacheKey := fmt.Sprintf("episodes:%d:%d", animeID, page)
	var episodesText string
	var hasNext bool

	if cached, ok := d.Cache.Get(cacheKey); ok {
		if data, valid := cached.(cachedEpisodes); valid {
			episodesText = data.Text
			hasNext = data.HasNext
		}
	}

	if episodesText == "" {
		episodes, next, err := d.Jikan.GetAnimeEpisodes(animeID, page)
		if err != nil {
			utils.LogError("failed to get episodes for anime=%d page=%d: %v", animeID, page, err)
			sendText(d, chatID, api.GetMessage(lang, "error_generic"))
			return
		}
		hasNext = next
		episodesText = formatEpisodesList(episodes, lang)
		d.Cache.Set(cacheKey, cachedEpisodes{Text: episodesText, HasNext: hasNext})
	}

	title := fmt.Sprintf(api.GetMessage(lang, "episodes_title"), utils.EscapeMarkdown(animeTitle))
	fullText := title + "\n\n" + episodesText

	message := tgbotapi.NewMessage(chatID, fullText)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyboard.EpisodesKeyboard(animeID, page, hasNext, lang)
	d.Bot.Send(message)
}

type cachedEpisodes struct {
	Text    string
	HasNext bool
}

// formatEpisodesList рӯйхати эпизодҳоро ба матн табдил медиҳад
func formatEpisodesList(episodes []models.Episode, lang string) string {
	if len(episodes) == 0 {
		return api.GetMessage(lang, "no_episodes")
	}

	var b strings.Builder
	for _, ep := range episodes {
		line := fmt.Sprintf(api.GetMessage(lang, "episode_line_label"), ep.MalID)
		if ep.Title != "" {
			line += ": " + ep.Title
		}
		if date := formatAiredDate(ep.Aired); date != "" {
			line += fmt.Sprintf(" (%s)", date)
		}
		if ep.Filler {
			line += " " + api.GetMessage(lang, "episode_filler_tag")
		}
		if ep.Recap {
			line += " " + api.GetMessage(lang, "episode_recap_tag")
		}
		b.WriteString("• ")
		b.WriteString(utils.EscapeMarkdown(line))
		b.WriteString("\n")
	}
	return b.String()
}

// formatAiredDate санаи хоми ISO 8601-и Jikan (масалан "2002-10-03T00:00:00+00:00")-ро
// ба формати сода ва хонотаро "02.01.2006" табдил медиҳад. Агар парс нашавад,
// сатри холӣ бармегардонад (беҳтар аз нишон додани матни хоми техникӣ)
func formatAiredDate(raw string) string {
	if raw == "" {
		return ""
	}
	t, err := time.Parse(time.RFC3339, raw)
	if err != nil {
		return ""
	}
	return t.Format("02.01.2006")
}
