package utils

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// Translator тавсифи анимеро (матни озод) ва дархости ҷустуҷӯи корбарро байни
// забонҳо тарҷума мекунад. Агар хидмати тарҷума дастнорас бошад, серкор бошад
// ё хато диҳад, ин НЕСТ хатогӣ ҳисоб мешавад — танҳо матни аслӣ бе тарҷума
// бармегардад, то ҳеҷ гоҳ ба сабаби ин хидмати иловагӣ чизе вайрон нашавад
type Translator struct {
	client *http.Client
}

// NewTranslator Translator-и нав месозад
func NewTranslator() *Translator {
	return &Translator{client: &http.Client{Timeout: 6 * time.Second}}
}

// translateLangCodes рамзи забони дохилии бот -> рамзи забон дар хидмати тарҷума
var translateLangCodes = map[string]string{
	"ru": "ru",
	"fa": "tg", // забони тоҷикӣ (кириллӣ)
}

// Translate матни англисиро ба забони lang тарҷума мекунад (масалан "ru", "fa").
// Барои забонҳое, ки тарҷума дастгирӣ намешавад (масалан "en"), матни аслиро бармегардонад
func (t *Translator) Translate(text string, lang string) string {
	target, ok := translateLangCodes[lang]
	if !ok {
		return text
	}
	return t.translate(text, "en|"+target)
}

// TranslateToEnglish матни бо забони lang (масалан "ru" ё "fa") навишташударо ба
// англисӣ тарҷума мекунад — барои он ки Jikan/AniList танҳо бо номи англисӣ/лотинии
// аниме ҷустуҷӯ мекунанд, вале корбарони тоҷику рус бо алифбои худашон менависанд
func (t *Translator) TranslateToEnglish(text string, lang string) string {
	source, ok := translateLangCodes[lang]
	if !ok {
		return text
	}
	return t.translate(text, source+"|en")
}

// translate дархостро ба хидмати MyMemory мефиристад. Дар ҳар гуна хато ё
// ҷавоби номуайян, матни аслиро бе тағйир бармегардонад
func (t *Translator) translate(text string, langpair string) string {
	text = strings.TrimSpace(text)
	if text == "" {
		return text
	}

	endpoint := fmt.Sprintf("https://api.mymemory.translated.net/get?q=%s&langpair=%s", url.QueryEscape(text), langpair)
	req, err := http.NewRequest(http.MethodGet, endpoint, nil)
	if err != nil {
		LogError("translate: failed to build request (langpair=%s): %v", langpair, err)
		return text
	}
	req.Header.Set("Accept", "application/json")

	resp, err := t.client.Do(req)
	if err != nil {
		LogError("translate: request failed (langpair=%s): %v", langpair, err)
		return text
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		LogError("translate: unexpected status %d (langpair=%s)", resp.StatusCode, langpair)
		return text
	}

	var result struct {
		ResponseData struct {
			TranslatedText string `json:"translatedText"`
		} `json:"responseData"`
		ResponseStatus int `json:"responseStatus"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		LogError("translate: failed to decode response (langpair=%s): %v", langpair, err)
		return text
	}
	if result.ResponseStatus != http.StatusOK {
		LogError("translate: mymemory responseStatus=%d (langpair=%s)", result.ResponseStatus, langpair)
		return text
	}

	translated := strings.TrimSpace(result.ResponseData.TranslatedText)
	if translated == "" || strings.Contains(strings.ToUpper(translated), "MYMEMORY WARNING") {
		LogError("translate: mymemory returned empty/warning result (langpair=%s): %q", langpair, translated)
		return text
	}
	return translated
}
