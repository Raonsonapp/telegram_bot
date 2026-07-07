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

// injectedQueryTerms калимаҳое, ки худи бот ба дархости ҷустуҷӯ илова
// мекунад (масалан калимаи забони дубляж ё "episode"/"قسمت") — инҳо қисми
// номи аниме нестанд, барои ҳамин набояд дар санҷиши мутобиқат ҳамчун
// калимаи "асосии" аниме ҳисоб шаванд. Вагарна масалан калимаи маъмули
// "dub" метавонад ба видеои комилан бемаънӣ бо тасодуф мувофиқат кунад
var injectedQueryTerms = map[string]bool{
	"episode": true, "دوبله": true, "فارسی": true, "قسمت": true,
	"русская": true, "озвучка": true, "english": true, "dub": true, "dubbed": true,
}

// isAllDigits месанҷад, ки оё калима танҳо аз рақам иборат аст (рақами
// қисм, ки ба дархост илова шудааст — на қисми номи аниме)
func isAllDigits(s string) bool {
	for _, r := range s {
		if r < '0' || r > '9' {
			return false
		}
	}
	return len(s) > 0
}

// coreQueryWords аз матни дархост танҳо калимаҳои асосии номи анимеро
// мебарорад — рақамҳои қисм ва калимаҳои иловашудаи худи бот (дубляж/забон/
// "episode") хориҷ карда мешаванд, то санҷиши мутобиқат ба номи воқеии
// аниме такя кунад, на ба калимаҳои ёрирасон
func coreQueryWords(query string) []string {
	var core []string
	for _, w := range significantWords(query) {
		if injectedQueryTerms[w] || isAllDigits(w) {
			continue
		}
		core = append(core, w)
	}
	if len(core) == 0 {
		return significantWords(query)
	}
	return core
}

// filterEpisodeCandidates аз рӯйхати натиҷаҳои ҷустуҷӯи видео танҳо онҳоеро
// мегузаронад, ки (1) унвонашон ба номи аниме воқеан рабт дорад ва (2)
// дарозиашон ба як қисми аниме монанд аст (агар дарозӣ маълум бошад). Ин ҳам
// видеоҳои комилан бемаънӣ ва ҳам филмҳо/компиляцияҳоро хориҷ мекунад.
// Барои унвонҳои бисёркалимагӣ (масалан "Sakamoto Days") як калимаи ягона
// (масалан "days") кофӣ нест — вагарна видеоҳои комилан беробита танҳо аз
// рӯи як калимаи маъмул мувофиқат мекунанд. Барои ≤2 калима ҳамаашон лозиманд,
// барои бештар аз он — ақаллан нисфи онҳо (то боло гирдогирд карда шуда)
func filterEpisodeCandidates[T any](items []T, titleOf func(T) string, durationOf func(T) (seconds int, known bool), query string, limit int) []T {
	core := coreQueryWords(query)
	required := len(core)
	if required > 2 {
		required = (required + 1) / 2
	}
	if required == 0 {
		required = 1
	}

	var result []T
	for _, item := range items {
		titleLower := strings.ToLower(titleOf(item))
		count := 0
		for _, w := range core {
			if strings.Contains(titleLower, w) {
				count++
			}
		}
		if count < required {
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
