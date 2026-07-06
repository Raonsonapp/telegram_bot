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

// HandleEpisodesCallback callback-и "episodes:<animeID>:<page>"-ро коркард мекунад
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
		line := fmt.Sprintf("• #%d %s", ep.MalID, ep.Title)
		if ep.Aired != "" {
			line += fmt.Sprintf(" (%s)", ep.Aired)
		}
		if ep.Filler {
			line += " [filler]"
		}
		if ep.Recap {
			line += " [recap]"
		}
		b.WriteString(utils.EscapeMarkdown(line))
		b.WriteString("\n")
	}
	return b.String()
}
