package utils

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// Translator тавсифи анимеро (матни озод) ба забони интихобкардаи корбар тарҷума мекунад.
// Агар хидмати тарҷума дастнорас бошад, серкор бошад ё хато диҳад, ин НЕСТ хатогӣ
// ҳисоб мешавад — танҳо матни аслӣ (англисӣ) бе тарҷума бармегардад, то саҳифаи
// аниме ҳеҷ гоҳ ба сабаби ин хидмати иловагӣ вайрон нашавад
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
	text = strings.TrimSpace(text)
	target, ok := translateLangCodes[lang]
	if !ok || text == "" {
		return text
	}

	endpoint := fmt.Sprintf("https://api.mymemory.translated.net/get?q=%s&langpair=en|%s", url.QueryEscape(text), target)
	req, err := http.NewRequest(http.MethodGet, endpoint, nil)
	if err != nil {
		return text
	}
	req.Header.Set("Accept", "application/json")

	resp, err := t.client.Do(req)
	if err != nil {
		return text
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return text
	}

	var result struct {
		ResponseData struct {
			TranslatedText string `json:"translatedText"`
		} `json:"responseData"`
		ResponseStatus int `json:"responseStatus"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return text
	}
	if result.ResponseStatus != http.StatusOK {
		return text
	}

	translated := strings.TrimSpace(result.ResponseData.TranslatedText)
	if translated == "" || strings.Contains(strings.ToUpper(translated), "MYMEMORY WARNING") {
		return text
	}
	return translated
}
