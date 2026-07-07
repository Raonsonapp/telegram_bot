package keyboard

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/models"
	"anime-bot/backend/utils"
)

// SearchResultsKeyboard рӯйхати натиҷаҳои ҷустуҷӯро ба тугмаҳо табдил медиҳад
func SearchResultsKeyboard(results []models.Anime) tgbotapi.InlineKeyboardMarkup {
	var rows [][]tgbotapi.InlineKeyboardButton
	for _, anime := range results {
		title := utils.Truncate(anime.Title, 45)
		btnText := title
		if anime.Year > 0 {
			btnText = fmt.Sprintf("%s (%d)", title, anime.Year)
		}
		rows = append(rows, tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(btnText, fmt.Sprintf("anime:%d", anime.MalID)),
		))
	}
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// AnimeDetailKeyboard тугмаҳои зери маълумоти яктои аниме.
// isFavorite ва status ҳолати ҷории корбарро нисбат ба ин аниме нишон медиҳанд,
// то тугмаҳо мутобиқан тағйир ёбанд (масалан "Илова кун" ё "Хориҷ кун")
func AnimeDetailKeyboard(anime models.Anime, lang string, isFavorite bool, status models.WatchStatus) tgbotapi.InlineKeyboardMarkup {
	favLabel := api.GetMessage(lang, "btn_add_favorite")
	if isFavorite {
		favLabel = api.GetMessage(lang, "btn_remove_favorite")
	}

	watchingLabel := api.GetMessage(lang, "btn_mark_watching")
	if status == models.StatusWatching {
		watchingLabel = api.GetMessage(lang, "btn_watching_active")
	}
	completedLabel := api.GetMessage(lang, "btn_mark_completed")
	if status == models.StatusCompleted {
		completedLabel = api.GetMessage(lang, "btn_completed_active")
	}

	// Барои анимеи дуруш (зиёда аз 25 қисм) ба ҷои рӯйхати дароз, аввал менюи
	// фаслҳо (ҳар фасл 25 қисм) нишон дода мешавад — ин кушодани қисмҳоро осон мекунад
	episodesCallback := fmt.Sprintf("episodes:%d:1", anime.MalID)
	if anime.Episodes > 25 {
		episodesCallback = fmt.Sprintf("seasons:%d", anime.MalID)
	}

	rows := [][]tgbotapi.InlineKeyboardButton{
		{
			tgbotapi.NewInlineKeyboardButtonData(
				api.GetMessage(lang, "btn_episodes"),
				episodesCallback,
			),
			tgbotapi.NewInlineKeyboardButtonData(
				api.GetMessage(lang, "btn_find_dub"),
				fmt.Sprintf("dub:%d", anime.MalID),
			),
		},
		{
			tgbotapi.NewInlineKeyboardButtonData(favLabel, fmt.Sprintf("fav:%d", anime.MalID)),
		},
		{
			tgbotapi.NewInlineKeyboardButtonData(watchingLabel, fmt.Sprintf("watch:%d:watching", anime.MalID)),
			tgbotapi.NewInlineKeyboardButtonData(completedLabel, fmt.Sprintf("watch:%d:completed", anime.MalID)),
		},
		{
			tgbotapi.NewInlineKeyboardButtonURL(api.GetMessage(lang, "btn_open_mal"), anime.URL),
		},
		{
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_back_to_menu"), "back:menu"),
		},
	}
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// EpisodesKeyboard тугмаҳои саҳифабандӣ ва бозгашт барои рӯйхати эпизодҳо
func EpisodesKeyboard(animeID int, page int, hasNext bool, lang string) tgbotapi.InlineKeyboardMarkup {
	var navRow []tgbotapi.InlineKeyboardButton
	if page > 1 {
		navRow = append(navRow, tgbotapi.NewInlineKeyboardButtonData("⬅️", fmt.Sprintf("episodes:%d:%d", animeID, page-1)))
	}
	if hasNext {
		navRow = append(navRow, tgbotapi.NewInlineKeyboardButtonData("➡️", fmt.Sprintf("episodes:%d:%d", animeID, page+1)))
	}

	rows := [][]tgbotapi.InlineKeyboardButton{}
	if len(navRow) > 0 {
		rows = append(rows, navRow)
	}
	rows = append(rows, tgbotapi.NewInlineKeyboardRow(
		tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_back"), fmt.Sprintf("anime:%d", animeID)),
	))

	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// SeasonMenuKeyboard рӯйхати фаслҳоро (ҳар кадом seasonSize қисм) ба тугмаҳо табдил медиҳад
func SeasonMenuKeyboard(animeID int, totalEpisodes int, totalSeasons int, lang string) tgbotapi.InlineKeyboardMarkup {
	const seasonSize = 25
	var rows [][]tgbotapi.InlineKeyboardButton
	var currentRow []tgbotapi.InlineKeyboardButton

	for s := 1; s <= totalSeasons; s++ {
		start := (s-1)*seasonSize + 1
		end := s * seasonSize
		if end > totalEpisodes {
			end = totalEpisodes
		}
		label := fmt.Sprintf("📁 %d (%d-%d)", s, start, end)
		currentRow = append(currentRow, tgbotapi.NewInlineKeyboardButtonData(label, fmt.Sprintf("season:%d:%d", animeID, s)))
		if len(currentRow) == 2 {
			rows = append(rows, currentRow)
			currentRow = nil
		}
	}
	if len(currentRow) > 0 {
		rows = append(rows, currentRow)
	}
	rows = append(rows, tgbotapi.NewInlineKeyboardRow(
		tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_back"), fmt.Sprintf("anime:%d", animeID)),
	))
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}

// SeasonEpisodesKeyboard тугмаҳои гузариш байни фаслҳо ва бозгашт
func SeasonEpisodesKeyboard(animeID int, seasonNum int, totalSeasons int, lang string) tgbotapi.InlineKeyboardMarkup {
	var navRow []tgbotapi.InlineKeyboardButton
	if seasonNum > 1 {
		navRow = append(navRow, tgbotapi.NewInlineKeyboardButtonData("⬅️", fmt.Sprintf("season:%d:%d", animeID, seasonNum-1)))
	}
	if seasonNum < totalSeasons {
		navRow = append(navRow, tgbotapi.NewInlineKeyboardButtonData("➡️", fmt.Sprintf("season:%d:%d", animeID, seasonNum+1)))
	}

	rows := [][]tgbotapi.InlineKeyboardButton{}
	if len(navRow) > 0 {
		rows = append(rows, navRow)
	}
	rows = append(rows,
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_all_seasons"), fmt.Sprintf("seasons:%d", animeID)),
		),
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_back"), fmt.Sprintf("anime:%d", animeID)),
		),
	)
	return tgbotapi.NewInlineKeyboardMarkup(rows...)
}
