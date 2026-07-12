package handlers

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"strconv"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
	qrcode "github.com/skip2/go-qrcode"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/keyboard"
	"appbuilder-bot/backend/utils"
)

// PendingQR ва PendingCurrency нигоҳ медоранд кадом корбарон мунтазири
// фиристодани матни QR ё дархости мубодилаи асъор ҳастанд
var PendingQR = make(map[int64]bool)
var PendingCurrency = make(map[int64]bool)

// passwordChars маҷмӯи аломатҳое, ки барои сохтани пароли тасодуфӣ истифода мешаванд
const passwordChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+"

// HandleToolsMenuButton менюи абзорҳоро (на ба аниме алоқаманд) нишон медиҳад
func HandleToolsMenuButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	message := tgbotapi.NewMessage(msg.Chat.ID, api.GetMessage(lang, "tools_menu_title"))
	message.ReplyMarkup = keyboard.ToolsMenu(lang)
	d.Bot.Send(message)
}

// HandlePasswordGenButton пароли тасодуфии қавӣ месозад ва фавран мефиристад
func HandlePasswordGenButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	password, err := generatePassword(16)
	if err != nil {
		utils.LogError("failed to generate password: %v", err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "error_generic"))
		return
	}
	text := fmt.Sprintf(api.GetMessage(lang, "password_result"), password)
	sendTextMarkdown(d, msg.Chat.ID, text)
}

// generatePassword пароли тасодуфиро бо дарозии додашуда месозад, бо
// crypto/rand (на math/rand), то натиҷа пешгӯинашаванда бошад
func generatePassword(length int) (string, error) {
	if length <= 0 {
		length = 16
	}
	max := big.NewInt(int64(len(passwordChars)))
	b := make([]byte, length)
	for i := range b {
		n, err := rand.Int(rand.Reader, max)
		if err != nil {
			return "", err
		}
		b[i] = passwordChars[n.Int64()]
	}
	return string(b), nil
}

// HandleQRGenButton матни барои QR-код лозимиро мепурсад
func HandleQRGenButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	PendingQR[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_qr_text"))
}

// HandleQRGenText матни фиристодаи корбарро ба расми QR-код табдил медиҳад
func HandleQRGenText(d *Deps, msg *tgbotapi.Message) {
	PendingQR[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)
	text := strings.TrimSpace(msg.Text)
	if text == "" {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_qr_text"))
		return
	}

	png, err := qrcode.Encode(text, qrcode.Medium, 512)
	if err != nil {
		utils.LogError("failed to generate QR code: %v", err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "error_generic"))
		return
	}

	photo := tgbotapi.NewPhoto(msg.Chat.ID, tgbotapi.FileBytes{Name: "qr.png", Bytes: png})
	d.Bot.Send(photo)
}

// HandleCurrencyButton форматро барои дархости мубодилаи асъор мепурсад
func HandleCurrencyButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	PendingCurrency[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_currency_text"))
}

// HandleCurrencyText матни корбарро ("100 USD EUR") мепорсад ва мубодиларо мекунад
func HandleCurrencyText(d *Deps, msg *tgbotapi.Message) {
	PendingCurrency[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)

	fields := strings.Fields(strings.ToUpper(strings.TrimSpace(msg.Text)))
	if len(fields) != 3 {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "currency_format_error"))
		return
	}

	amount, err := strconv.ParseFloat(fields[0], 64)
	if err != nil {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "currency_format_error"))
		return
	}
	from, to := fields[1], fields[2]

	converted, err := d.Currency.Convert(amount, from, to)
	if err != nil {
		utils.LogError("currency conversion failed (%s->%s): %v", from, to, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "currency_error"))
		return
	}

	text := fmt.Sprintf(api.GetMessage(lang, "currency_result"), amount, from, converted, to)
	sendText(d, msg.Chat.ID, text)
}
