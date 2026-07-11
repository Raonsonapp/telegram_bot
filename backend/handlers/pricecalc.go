package handlers

import (
	"fmt"
	"strconv"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
)

// priceCalcState ҳолати ҳисоби нархи як корбарро (то фиристодани фармоиш) нигоҳ медорад
type priceCalcState struct {
	Screens   int
	Functions int
	Package   string // "offline" ё "online"
	Price     int
}

// PendingPriceScreens ва PendingPriceFunctions нигоҳ медоранд кадом корбарон
// мунтазири фиристодани шумораи Screen ё Function ҳастанд
var PendingPriceScreens = make(map[int64]bool)
var PendingPriceFunctions = make(map[int64]bool)
var priceCalcSessions = make(map[int64]*priceCalcState)

// Нархҳо (сомонӣ) — асоси ҳисоб. Инҳоро метавон дар оянда танзим кард
const (
	priceBaseScreenOffline  = 100
	priceBaseScreenOnline   = 200
	pricePerFunctionOffline = 20
	pricePerFunctionOnline  = 35
)

// Ҳадди болоӣ — аз ин зиёд лоиҳаи калон ҳисоб мешавад, ки вақти зиёд ва
// нархи алоҳида (аз рӯи муроҷиати мустақим) мехоҳад, на ҳисоби худкор
const (
	maxPriceScreens   = 10
	maxPriceFunctions = 100
)

// HandlePriceCalcButton шумораи Screen-ро мепурсад
func HandlePriceCalcButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	priceCalcSessions[msg.From.ID] = &priceCalcState{}
	PendingPriceScreens[msg.From.ID] = true
	sendTextMarkdown(d, msg.Chat.ID, api.GetMessage(lang, "ask_price_screens"))
}

// HandlePriceScreensText шумораи Screen-ро мегирад, баъд шумораи Function-ро мепурсад
func HandlePriceScreensText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	n, err := strconv.Atoi(strings.TrimSpace(msg.Text))
	if err != nil || n <= 0 {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "price_number_error"))
		return
	}
	if n > maxPriceScreens {
		PendingPriceScreens[msg.From.ID] = false
		delete(priceCalcSessions, msg.From.ID)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "price_too_large"))
		return
	}
	PendingPriceScreens[msg.From.ID] = false

	state := priceCalcSessions[msg.From.ID]
	if state == nil {
		state = &priceCalcState{}
		priceCalcSessions[msg.From.ID] = state
	}
	state.Screens = n

	PendingPriceFunctions[msg.From.ID] = true
	sendTextMarkdown(d, msg.Chat.ID, api.GetMessage(lang, "ask_price_functions"))
}

// HandlePriceFunctionsText шумораи Function-ро мегирад, баъд навъи пакетро мепурсад
func HandlePriceFunctionsText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	n, err := strconv.Atoi(strings.TrimSpace(msg.Text))
	if err != nil || n <= 0 {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "price_number_error"))
		return
	}
	if n > maxPriceFunctions {
		PendingPriceFunctions[msg.From.ID] = false
		delete(priceCalcSessions, msg.From.ID)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "price_too_large"))
		return
	}
	PendingPriceFunctions[msg.From.ID] = false

	state := priceCalcSessions[msg.From.ID]
	if state == nil {
		state = &priceCalcState{}
		priceCalcSessions[msg.From.ID] = state
	}
	state.Functions = n

	message := tgbotapi.NewMessage(msg.Chat.ID, api.GetMessage(lang, "ask_price_package"))
	message.ReplyMarkup = tgbotapi.NewInlineKeyboardMarkup(
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_package_offline"), "pricepkg:offline"),
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_package_online"), "pricepkg:online"),
		),
	)
	d.Bot.Send(message)
}

// HandlePricePackageCallback навъи пакети интихобшударо мегирад, нархро
// ҳисоб мекунад ва бо тугмаҳои тасдиқ/бекор нишон медиҳад
func HandlePricePackageCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	pkg := strings.TrimPrefix(cb.Data, "pricepkg:")
	state := priceCalcSessions[cb.From.ID]
	if state == nil {
		sendText(d, chatID, api.GetMessage(lang, "price_session_expired"))
		return
	}
	state.Package = pkg

	var price int
	var pkgLabel string
	if pkg == "online" {
		price = state.Screens*priceBaseScreenOnline + state.Functions*pricePerFunctionOnline
		pkgLabel = api.GetMessage(lang, "btn_package_online")
	} else {
		price = state.Screens*priceBaseScreenOffline + state.Functions*pricePerFunctionOffline
		pkgLabel = api.GetMessage(lang, "btn_package_offline")
	}
	state.Price = price

	text := fmt.Sprintf(api.GetMessage(lang, "price_result"), state.Screens, state.Functions, pkgLabel, price)
	message := tgbotapi.NewMessage(chatID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = tgbotapi.NewInlineKeyboardMarkup(
		tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_place_order"), "priceorder:confirm"),
			tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_cancel_order"), "priceorder:cancel"),
		),
	)
	d.Bot.Send(message)
}

// HandlePriceOrderCallback фармоишро тасдиқ/бекор мекунад. Дар тасдиқ,
// маълумоти пурра ба ADMIN_CHAT_ID фиристода мешавад
func HandlePriceOrderCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	callback := tgbotapi.NewCallback(cb.ID, "")
	d.Bot.Request(callback)

	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	if cb.Data == "priceorder:cancel" {
		delete(priceCalcSessions, cb.From.ID)
		edit := tgbotapi.NewEditMessageText(chatID, cb.Message.MessageID, api.GetMessage(lang, "price_order_cancelled"))
		d.Bot.Send(edit)
		return
	}

	state := priceCalcSessions[cb.From.ID]
	if state == nil {
		sendText(d, chatID, api.GetMessage(lang, "price_session_expired"))
		return
	}

	if d.Config.AdminChatID != 0 {
		pkgLabel := api.GetMessage(lang, "btn_package_offline")
		if state.Package == "online" {
			pkgLabel = api.GetMessage(lang, "btn_package_online")
		}
		username := cb.From.UserName
		if username == "" {
			username = "-"
		}
		orderText := fmt.Sprintf(
			"🆕 Фармоиши нав аз Ҳисобкунаки нарх!\n\n👤 Username: @%s\n🆔 User ID: %d\n📱 Screen: %d\n⚙️ Function: %d\n📦 Package: %s\n💰 Нархи умумӣ: %d сомонӣ",
			username, cb.From.ID, state.Screens, state.Functions, pkgLabel, state.Price,
		)
		adminMsg := tgbotapi.NewMessage(d.Config.AdminChatID, orderText)
		d.Bot.Send(adminMsg)
	}

	delete(priceCalcSessions, cb.From.ID)
	edit := tgbotapi.NewEditMessageText(chatID, cb.Message.MessageID, api.GetMessage(lang, "price_order_sent"))
	d.Bot.Send(edit)
}
