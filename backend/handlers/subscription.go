package handlers

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// CheckSubscription санҷиш мекунад, ки оё корбар ба ҳамаи каналҳои ҳатмӣ
// (спонсорҳо) обуна аст. Натиҷаи мусбат муддате дар cache нигоҳ дошта мешавад,
// то барои ҳар паёми корбар API-и Telegram-ро дархост накунем
func CheckSubscription(d *Deps, userID int64) (bool, []string) {
	if len(d.Config.RequiredChannels) == 0 {
		return true, nil
	}

	cacheKey := fmt.Sprintf("sub:%d", userID)
	if cached, ok := d.Cache.Get(cacheKey); ok {
		if subscribed, valid := cached.(bool); valid && subscribed {
			return true, nil
		}
	}

	var missing []string
	for _, channel := range d.Config.RequiredChannels {
		member, err := d.Bot.GetChatMember(tgbotapi.GetChatMemberConfig{
			ChatConfigWithUser: tgbotapi.ChatConfigWithUser{SuperGroupUsername: channel, UserID: userID},
		})
		if err != nil {
			// Агар санҷиш ноком шавад (масалан бот ҳанӯз админи канал нашудааст),
			// беҳтар аст корбарро манъ накунем, то боти пурра вайрон нашавад
			utils.LogError("failed to check subscription for channel=%s user=%d: %v", channel, userID, err)
			continue
		}
		if member.Status == "left" || member.Status == "kicked" {
			missing = append(missing, channel)
		}
	}

	if len(missing) == 0 {
		d.Cache.Set(cacheKey, true)
		return true, nil
	}
	return false, missing
}

// EnsureSubscribed агар корбар ба ҳамаи каналҳо обуна набошад, дархости
// обунаро мефиристад ва false бармегардонад
func EnsureSubscribed(d *Deps, userID int64, chatID int64) bool {
	subscribed, missing := CheckSubscription(d, userID)
	if subscribed {
		return true
	}
	lang := getUserLang(d, userID)
	sendSubscriptionPrompt(d, chatID, lang, missing)
	return false
}

// HandleBlockedCallback вақте ки корбари обунанашуда тугмаеро мезанад — паёми
// кӯтоҳи ёдоварӣ (popup) нишон медиҳад, бе фиристодани паёми нави пурра
func HandleBlockedCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	lang := getUserLang(d, cb.From.ID)
	callback := tgbotapi.NewCallback(cb.ID, api.GetMessage(lang, "subscription_required_short"))
	callback.ShowAlert = true
	d.Bot.Request(callback)
}

// HandleCheckSubscriptionCallback тугмаи "✅ Санҷед"-ро коркард мекунад
func HandleCheckSubscriptionCallback(d *Deps, cb *tgbotapi.CallbackQuery) {
	lang := getUserLang(d, cb.From.ID)
	chatID := cb.Message.Chat.ID

	subscribed, missing := CheckSubscription(d, cb.From.ID)
	if subscribed {
		callback := tgbotapi.NewCallback(cb.ID, "")
		d.Bot.Request(callback)
		edit := tgbotapi.NewEditMessageText(chatID, cb.Message.MessageID, api.GetMessage(lang, "subscription_confirmed"))
		d.Bot.Send(edit)
		return
	}

	callback := tgbotapi.NewCallback(cb.ID, api.GetMessage(lang, "subscription_still_missing"))
	callback.ShowAlert = true
	d.Bot.Request(callback)
	_ = missing
}

// sendSubscriptionPrompt паёми дархости обунаро бо тугмаҳои пайванд ба ҳар канал мефиристад
func sendSubscriptionPrompt(d *Deps, chatID int64, lang string, missing []string) {
	var rows [][]tgbotapi.InlineKeyboardButton
	for _, channel := range missing {
		username := channel
		if len(username) > 0 && username[0] == '@' {
			username = username[1:]
		}
		rows = append(rows, tgbotapi.NewInlineKeyboardRow(
			tgbotapi.NewInlineKeyboardButtonURL("📢 "+username, "https://t.me/"+username),
		))
	}
	rows = append(rows, tgbotapi.NewInlineKeyboardRow(
		tgbotapi.NewInlineKeyboardButtonData(api.GetMessage(lang, "btn_check_subscription"), "checksub"),
	))

	message := tgbotapi.NewMessage(chatID, api.GetMessage(lang, "subscription_required"))
	message.ReplyMarkup = tgbotapi.NewInlineKeyboardMarkup(rows...)
	d.Bot.Send(message)
}
