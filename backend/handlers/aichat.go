package handlers

import (
	"fmt"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/utils"
)

// PendingAIChat корбароне, ки дар "ҳолати гуфтугӯ бо AI" ҳастанд — то вақте
// ки аз он набароянд, ҳар паёми матниашон ба AI фиристода мешавад ва
// ҷавоб мегиранд
var PendingAIChat = make(map[int64]bool)

// aiChatKeyboard клавиатураи хурд бо як тугмаи "баромадан" — то корбар
// ҳамеша роҳи баромадан аз ҳолати чатро дошта бошад
func aiChatKeyboard(lang string) tgbotapi.ReplyKeyboardMarkup {
	kb := tgbotapi.NewReplyKeyboard(
		tgbotapi.NewKeyboardButtonRow(
			tgbotapi.NewKeyboardButton(api.GetMessage(lang, "btn_exit_chat")),
		),
	)
	kb.ResizeKeyboard = true
	return kb
}

// HandleAIChatButton ҳолати гуфтугӯ бо AI-ро оғоз мекунад
func HandleAIChatButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	if !d.AICoder.Enabled() {
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "appbuilder_not_configured"))
		return
	}
	PendingAIChat[msg.From.ID] = true
	message := tgbotapi.NewMessage(msg.Chat.ID, api.GetMessage(lang, "ai_chat_intro"))
	message.ReplyMarkup = aiChatKeyboard(lang)
	d.Bot.Send(message)
}

// HandleExitAIChatButton ҳолати чатро мебандад ва менюи асосиро бармегардонад
func HandleExitAIChatButton(d *Deps, msg *tgbotapi.Message) {
	delete(PendingAIChat, msg.From.ID)
	HandleUnknownText(d, msg) // менюи асосиро бо клавиатураи асосӣ бармегардонад
}

// HandleAIChatText паёми корбарро ба AI мефиристад ва ҷавобро бармегардонад
func HandleAIChatText(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)

	// лимити истифодаи AI ба чат низ дахл дорад (агар корбар "бемаҳдуд" набошад)
	unlimited, _ := d.Referrals.HasUnlimitedAI(msg.From.ID)
	if !unlimited {
		if allowed, retryAfter := checkAIRateLimit(msg.From.ID); !allowed {
			minutes := int(retryAfter.Round(time.Minute) / time.Minute)
			if minutes < 1 {
				minutes = 1
			}
			sendText(d, msg.Chat.ID, fmt.Sprintf(api.GetMessage(lang, "ai_rate_limited"), minutes))
			return
		}
	}

	// "чоп мекунад..." нишон медиҳем, то корбар донад ҷавоб дар роҳ аст
	typing := tgbotapi.NewChatAction(msg.Chat.ID, tgbotapi.ChatTyping)
	d.Bot.Request(typing)

	reply, err := d.AICoder.Chat(msg.Text)
	if err != nil {
		utils.LogError("aichat: chat failed for user=%d: %v", msg.From.ID, err)
		sendText(d, msg.Chat.ID, api.GetMessage(lang, "ai_chat_error"))
		return
	}
	sendText(d, msg.Chat.ID, reply)
}
