package handlers

import (
	"fmt"
	"sort"
	"strings"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// worldCupDateLayouts форматҳои имконпазири санаи бозӣ, ки API метавонад
// баргардонад — то дуруст парс шавад новобаста аз шакли дақиқаш
var worldCupDateLayouts = []string{
	time.RFC3339,
	"2006-01-02T15:04:05",
	"2006-01-02 15:04:05",
	"2006-01-02",
}

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

	upcoming := filterRelevantMatches(matches)
	if len(upcoming) == 0 {
		edit := tgbotapi.NewEditMessageText(msg.Chat.ID, sentMsg.MessageID, api.GetMessage(lang, "worldcup_no_matches"))
		d.Bot.Send(edit)
		return
	}

	var b strings.Builder
	for _, m := range upcoming {
		b.WriteString(formatWorldCupMatch(m))
		b.WriteString("\n")
	}

	edit := tgbotapi.NewEditMessageText(msg.Chat.ID, sentMsg.MessageID, api.GetMessage(lang, "worldcup_title")+"\n\n"+b.String())
	d.Bot.Send(edit)
}

// filterRelevantMatches бозиҳоеро мегузаронад, ки санаашон дуруст парс шуд
// ва дар доираи 3 соати гузашта то 7 рӯзи оянда ҳастанд, баъд аз рӯи вақт
// мураттаб карда то 5-тоашро бармегардонад
func filterRelevantMatches(matches []api.WorldCupMatch) []api.WorldCupMatch {
	now := time.Now()
	type withTime struct {
		match api.WorldCupMatch
		at    time.Time
	}
	var candidates []withTime
	for _, m := range matches {
		t, ok := parseWorldCupDate(m.Date)
		if !ok {
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

func parseWorldCupDate(raw string) (time.Time, bool) {
	for _, layout := range worldCupDateLayouts {
		if t, err := time.Parse(layout, raw); err == nil {
			return t, true
		}
	}
	return time.Time{}, false
}

func formatWorldCupMatch(m api.WorldCupMatch) string {
	home, away := m.HomeTeam, m.AwayTeam
	if home == "" {
		home = "?"
	}
	if away == "" {
		away = "?"
	}

	score := "vs"
	if m.HomeScore != nil && m.AwayScore != nil {
		score = fmt.Sprintf("%d - %d", *m.HomeScore, *m.AwayScore)
	}

	return fmt.Sprintf("🏟 %s %s %s", home, score, away)
}
