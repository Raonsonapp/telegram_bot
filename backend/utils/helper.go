package utils

import (
	"strconv"
	"strings"
)

// Truncate матни дарозро то ҳадди муайян кӯтоҳ мекунад
func Truncate(s string, max int) string {
	runes := []rune(s)
	if len(runes) <= max {
		return s
	}
	return string(runes[:max]) + "..."
}

// EscapeMarkdown аломатҳои махсуси MarkdownV2-ро эҳтиёт мекунад
func EscapeMarkdown(s string) string {
	replacer := strings.NewReplacer(
		"_", "\\_", "*", "\\*", "[", "\\[", "]", "\\]", "(", "\\(", ")", "\\)",
		"~", "\\~", "`", "\\`", ">", "\\>", "#", "\\#", "+", "\\+", "-", "\\-",
		"=", "\\=", "|", "\\|", "{", "\\{", "}", "\\}", ".", "\\.", "!", "\\!",
	)
	return replacer.Replace(s)
}

// FormatScore холи аниме (масалан 8.35)-ро ба сатр табдил медиҳад
func FormatScore(score float64) string {
	if score <= 0 {
		return "N/A"
	}
	return strconv.FormatFloat(score, 'f', 2, 64)
}

// FormatEpisodes шумораи қисмҳоро ба сатр мегардонад
func FormatEpisodes(episodes int) string {
	if episodes <= 0 {
		return "?"
	}
	return strconv.Itoa(episodes)
}

// ParseCallbackID аз сатри callback (масалан "anime:123") ID-ро мебарорад
func ParseCallbackID(data string, prefix string) (int, bool) {
	if !strings.HasPrefix(data, prefix) {
		return 0, false
	}
	idStr := strings.TrimPrefix(data, prefix)
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return 0, false
	}
	return id, true
}

// JoinGenres номи жанрҳоро якҷоя мекунад
func JoinGenres(genres []string) string {
	if len(genres) == 0 {
		return "N/A"
	}
	return strings.Join(genres, ", ")
}
