package api

import (
	"regexp"
	"sort"
	"strconv"
	"strings"
)

// franchiseMarkers калимаҳое, ки одатан унвони як қисми алоҳидаи франшизаро
// (давом, spin-off, филм) нишон медиҳанд. Агар унвони мақсаднок (масалан "Naruto")
// яке аз инҳоро дар бар нагирад, вале натиҷаи видео дошта бошад, эҳтимол ин
// натиҷа аз сериали дигари ҳамон франшиза аст (масалан Boruto ё Shippuden),
// на қисми дурусти дархостшуда
var franchiseMarkers = []string{"boruto", "shippuden", "shippuuden", "movie", "the last", "ova", "special"}

// structuredEpisodePattern рақами қисмро аз шаклҳои возеҳ мебарорад: "قسمت 12",
// "episode 12", "ep 12", "ep.12", "e12" ё "#12". \b пеш аз калимаҳои лотинӣ
// лозим аст, вагарна ҳарфи танҳои "e" метавонад ба охири калимаҳои маъмулӣ
// (масалан "Movie 2014" -> "...moviE 2014") ба хатогӣ мувофиқат кунад
var structuredEpisodePattern = regexp.MustCompile(`(?i)قسمت\s*[#:.\-]?\s*(\d{1,4})|\b(?:episode|ep\.?|e)\s*[#:.\-]?\s*(\d{1,4})\b|#(\d{1,4})`)

// trailingNumberPattern вақте ки унвон бе калимаи "قسمت"/"episode" аст, вале
// бо рақами танҳо дар охираш тамом мешавад (услуби маъмули фансаб-гурӯҳҳо,
// масалан "Anime Name - 05" ё "Anime Name 05")
var trailingNumberPattern = regexp.MustCompile(`(?:^|[\s\-_\[(])(\d{1,3})[\s\-_\])]*$`)

// persianDigits ҳарф ба ҳарфи рақамҳои форсӣ/арабӣ ба рақами лотинӣ
var persianDigits = map[rune]rune{
	'۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4', '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
	'٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4', '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
}

func normalizeDigits(s string) string {
	var b strings.Builder
	for _, r := range s {
		if latin, ok := persianDigits[r]; ok {
			b.WriteRune(latin)
		} else {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// ExtractEpisodeNumber рақами қисмро аз унвони видео мебарорад (агар мавҷуд бошад).
// Аввал шаклҳои возеҳ ("قسمت 5", "episode 5") месанҷад; агар ёфт нашавад,
// ба рақами танҳо дар охири унвон (услуби фансаб) мегузарад
func ExtractEpisodeNumber(title string) (int, bool) {
	normalized := strings.TrimSpace(normalizeDigits(title))

	if match := structuredEpisodePattern.FindStringSubmatch(normalized); match != nil {
		for _, group := range match[1:] {
			if group != "" {
				if n, err := strconv.Atoi(group); err == nil {
					return n, true
				}
			}
		}
	}

	if match := trailingNumberPattern.FindStringSubmatch(normalized); match != nil {
		if n, err := strconv.Atoi(match[1]); err == nil {
			return n, true
		}
	}

	return 0, false
}

// IsFranchiseMismatch месанҷад, ки оё унвони видео ба сериали дигари ҳамон
// франшиза тааллуқ дорад (масалан ҷустуҷӯ барои "Naruto" видеои "Boruto"-ро ёфтааст)
func IsFranchiseMismatch(animeTitle string, videoTitle string) bool {
	animeLower := strings.ToLower(animeTitle)
	videoLower := strings.ToLower(videoTitle)
	for _, marker := range franchiseMarkers {
		if strings.Contains(videoLower, marker) && !strings.Contains(animeLower, marker) {
			return true
		}
	}
	return false
}

// EpisodeMatch натиҷаи видео бо рақами қисми муайяншуда (агар ёфт шуда бошад)
type EpisodeMatch[T any] struct {
	Item    T
	Episode int
	Known   bool
}

// FilterBySeasonRange натиҷаҳоеро мегузаронад, ки (1) ба франшизаи дигар
// тааллуқ надоранд ва (2) рақами қисмашон дар доираи [minEp, maxEp] аст,
// баъд онҳоро аз рӯи рақами қисм мураттаб мекунад (аз хурд ба калон)
func FilterBySeasonRange[T any](items []T, titleOf func(T) string, animeTitle string, minEp int, maxEp int) []T {
	var matches []EpisodeMatch[T]
	for _, item := range items {
		title := titleOf(item)
		if IsFranchiseMismatch(animeTitle, title) {
			continue
		}
		ep, ok := ExtractEpisodeNumber(title)
		if !ok || ep < minEp || ep > maxEp {
			continue
		}
		matches = append(matches, EpisodeMatch[T]{Item: item, Episode: ep, Known: true})
	}

	sort.Slice(matches, func(i, j int) bool { return matches[i].Episode < matches[j].Episode })

	result := make([]T, 0, len(matches))
	for _, m := range matches {
		result = append(result, m.Item)
	}
	return result
}
