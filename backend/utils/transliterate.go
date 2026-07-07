package utils

import "strings"

// cyrillicToLatin ҳарф ба ҳарфи кириллӣ (тоҷикӣ/русӣ) ба лотинии оддии фонетикӣ
var cyrillicToLatin = map[rune]string{
	'а': "a", 'б': "b", 'в': "v", 'г': "g", 'ғ': "gh", 'д': "d", 'е': "e", 'ё': "yo",
	'ж': "zh", 'з': "z", 'и': "i", 'ӣ': "i", 'й': "y", 'к': "k", 'қ': "q", 'л': "l",
	'м': "m", 'н': "n", 'о': "o", 'п': "p", 'р': "r", 'с': "s", 'т': "t", 'у': "u",
	'ӯ': "u", 'ф': "f", 'х': "kh", 'ҳ': "h", 'ц': "ts", 'ч': "ch", 'ҷ': "j", 'ш': "sh",
	'щ': "shch", 'ъ': "", 'ы': "y", 'ь': "", 'э': "e", 'ю': "yu", 'я': "ya",
}

// TransliterateCyrillicToLatin номҳои хосро (масалан унвони аниме) аз кириллӣ ба
// лотинии фонетикӣ мегардонад — масалан "Наруто" -> "naruto". Барои номҳои хос
// (қаҳрамонҳо, унвонҳо) ин аз тарҷумаи мошинӣ боэътимодтар аст, зеро корбарон
// одатан номро танҳо ба алифбои худ "мегӯянд", на тарҷума мекунанд
func TransliterateCyrillicToLatin(s string) string {
	var b strings.Builder
	for _, r := range strings.ToLower(s) {
		if latin, ok := cyrillicToLatin[r]; ok {
			b.WriteString(latin)
		} else {
			b.WriteRune(r)
		}
	}
	return b.String()
}
