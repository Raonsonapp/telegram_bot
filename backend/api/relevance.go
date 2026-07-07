package api

import "strings"

// Дарозии оддии як қисми аниме (бо OP/ED) — видеоҳое, ки берун аз ин доира
// ҳастанд (филмҳо, реклама, компиляцияи якчанд қисм якҷоя) қисми алоҳида нестанд
const (
	minEpisodeSeconds = 15 * 60
	maxEpisodeSeconds = 35 * 60
)

// isEpisodeLength месанҷад, ки оё дарозии видео ба дарозии як қисми аниме монанд аст
func isEpisodeLength(seconds int) bool {
	return seconds >= minEpisodeSeconds && seconds <= maxEpisodeSeconds
}

// subtitleOnlyMarkers калимаҳое, ки нишон медиҳанд видео танҳо зерунвис дорад
// (на дубляжи пурраи овозӣ). Ба мо танҳо дубляж лозим аст, на зерунвис —
// агар унвон яке аз инҳоро дошта бошад ва ҳамзамон калимаи дубляжро надошта
// бошад, ин видео хориҷ карда мешавад
var subtitleOnlyMarkers = []string{"زیرنویس", "subtitle", "subbed", "softsub", "hardsub"}
var dubMarkers = []string{"دوبله", "dub", "dubbed"}

// isSubtitleOnly месанҷад, ки оё видео танҳо зерунвис аст (бе дубляж)
func isSubtitleOnly(title string) bool {
	lower := strings.ToLower(title)
	hasSubtitleMarker := false
	for _, m := range subtitleOnlyMarkers {
		if strings.Contains(lower, m) {
			hasSubtitleMarker = true
			break
		}
	}
	if !hasSubtitleMarker {
		return false
	}
	for _, m := range dubMarkers {
		if strings.Contains(lower, m) {
			return false
		}
	}
	return true
}

// significantWords калимаҳои ≥3-ҳарфаи матнро (бе ҳарфи хурд) бармегардонад,
// то калимаҳои хеле кӯтоҳ (масалан "the", "of") монандии бардурӯғ надиҳанд
func significantWords(text string) []string {
	var words []string
	for _, w := range strings.Fields(strings.ToLower(text)) {
		if len(w) >= 3 {
			words = append(words, w)
		}
	}
	return words
}

// filterEpisodeCandidates аз рӯйхати натиҷаҳои ҷустуҷӯи видео танҳо онҳоеро
// мегузаронад, ки (1) унвонашон ба матни ҷустуҷӯ рабт дорад ва (2) дарозиашон
// ба як қисми аниме монанд аст (агар дарозӣ маълум бошад). Ин ҳам видеоҳои
// комилан бемаънӣ ва ҳам филмҳо/компиляцияҳоро (на қисмҳои алоҳида) хориҷ мекунад.
// Агар дарозӣ маълум набошад (durationOf ok=false бармегардонад), санҷиши
// дарозӣ гузаронда мешавад — беҳтар аст натиҷаи эҳтимолӣ нишон дода шавад,
// то ҳеҷ натиҷа нишон надодан
func filterEpisodeCandidates[T any](items []T, titleOf func(T) string, durationOf func(T) (seconds int, known bool), query string, limit int) []T {
	words := significantWords(query)

	var result []T
	for _, item := range items {
		titleLower := strings.ToLower(titleOf(item))
		matched := false
		for _, w := range words {
			if strings.Contains(titleLower, w) {
				matched = true
				break
			}
		}
		if !matched {
			continue
		}

		if isSubtitleOnly(titleOf(item)) {
			continue
		}

		if seconds, known := durationOf(item); known && !isEpisodeLength(seconds) {
			continue
		}

		result = append(result, item)
		if len(result) >= limit {
			break
		}
	}
	return result
}
