package api

import "strings"

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

// filterByRelevance аз рӯйхати натиҷаҳои ҷустуҷӯи видео танҳо онҳоеро мегузаронад,
// ки унвонашон ҳадди ақал як калимаи боаҳамияти матни ҷустуҷӯро дар бар мегирад —
// ин пеши роҳи нишон додани видеоҳои комилан бемаъние, ки платформа тасодуфан
// бармегардонад, мегирад
func filterByRelevance[T any](items []T, titleOf func(T) string, query string, limit int) []T {
	words := significantWords(query)

	var result []T
	for _, item := range items {
		titleLower := strings.ToLower(titleOf(item))
		for _, w := range words {
			if strings.Contains(titleLower, w) {
				result = append(result, item)
				break
			}
		}
		if len(result) >= limit {
			break
		}
	}
	return result
}
