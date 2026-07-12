package handlers

import (
	"fmt"
	"sort"
	"strings"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/utils"
)

// worldCupDateLayout формати санаи "local_date"-и API мутобиқи мисоли
// README-и лоиҳа ("06/11/2026 13:00" — MM/DD/YYYY HH:MM)
const worldCupDateLayout = "01/02/2006 15:04"

// HandleWorldCupButton бозиҳои наздики Ҷоми Ҷаҳонии 2026-ро нишон медиҳад
// (натиҷа/вақт — маълумоти матнист, на видео)
func HandleWorldCupButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	loadingMsg := tgbotapi.NewMessage(msg.Chat.ID, api.GetMessage(lang, "worldcup_loading"))
	sentMsg, _ := d.Bot.Send(loadingMsg)

	matches, err := d.WorldCup.GetGames()
	if err != nil {
		utils.LogError("worldcup: failed to fetch games: %v", err)
		edit := tgbotapi.NewEditMessageText(msg.Chat.ID, sentMsg.MessageID, api.GetMessage(lang, "worldcup_error"))
		d.Bot.Send(edit)
		return
	}

	relevant := filterRelevantMatches(matches)
	if len(relevant) == 0 {
		edit := tgbotapi.NewEditMessageText(msg.Chat.ID, sentMsg.MessageID, api.GetMessage(lang, "worldcup_no_matches"))
		d.Bot.Send(edit)
		return
	}

	var b strings.Builder
	for _, m := range relevant {
		b.WriteString(formatWorldCupMatch(m))
		b.WriteString("\n")
	}

	edit := tgbotapi.NewEditMessageText(msg.Chat.ID, sentMsg.MessageID, api.GetMessage(lang, "worldcup_title")+"\n\n"+b.String())
	d.Bot.Send(edit)
}

// filterRelevantMatches бозиҳоеро мегузаронад, ки санаашон дуруст парс шуд
// ва дар доираи 3 соати гузашта то 7 рӯзи оянда ҳастанд (бозиҳои ба наздикӣ
// тамомшуда + ҳозира дар ҳол + наздиктарин оянда), баъд аз рӯи вақт мураттаб
// карда то 5-тоашро бармегардонад
func filterRelevantMatches(matches []api.WorldCupMatch) []api.WorldCupMatch {
	now := time.Now()
	type withTime struct {
		match api.WorldCupMatch
		at    time.Time
	}
	var candidates []withTime
	for _, m := range matches {
		t, err := time.Parse(worldCupDateLayout, m.LocalDate)
		if err != nil {
			continue
		}
		if t.Before(now.Add(-3*time.Hour)) || t.After(now.Add(7*24*time.Hour)) {
			continue
		}
		candidates = append(candidates, withTime{match: m, at: t})
	}
	sort.Slice(candidates, func(i, j int) bool { return candidates[i].at.Before(candidates[j].at) })

	result := make([]api.WorldCupMatch, 0, len(candidates))
	for i, c := range candidates {
		if i >= 5 {
			break
		}
		result = append(result, c.match)
	}
	return result
}

// formatWorldCupMatch як бозиро ба сатри хониш форматонида мебарорад:
// тамомшуда бо ҳисоби ниҳоӣ, дар ҳоли бозӣ бо ҳисоби зинда, оянда бо вақт
func formatWorldCupMatch(m api.WorldCupMatch) string {
	home := m.HomeTeamNameEn
	if home == "" {
		home = "TBD"
	}
	away := m.AwayTeamNameEn
	if away == "" {
		away = "TBD"
	}

	switch {
	case m.Finished:
		return fmt.Sprintf("🏁 %s %d - %d %s", home, m.HomeScore, m.AwayScore, away)
	case m.TimeElapsed != "" && m.TimeElapsed != "notstarted":
		return fmt.Sprintf("🔴 %s %d - %d %s", home, m.HomeScore, m.AwayScore, away)
	default:
		return fmt.Sprintf("🏟 %s vs %s (%s)", home, away, m.LocalDate)
	}
}
