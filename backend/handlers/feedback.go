package handlers

import (
	"fmt"
	"strings"
	"sync"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/backend/api"
	"anime-bot/backend/utils"
)

// PendingFeedback нигоҳ медорад кадом корбарон мунтазири фиристодани матни
// паём/савол/шикоят барои админ ҳастанд
var PendingFeedback = make(map[int64]bool)

// forwardedMessages ID-и паёме, ки ба чати админ фиристода шудааст -> ID-и
// корбари фиристанда. Вақте админ ба он паём Reply мекунад, аз ин ҷадвал
// мефаҳмем ҷавобро ба кӣ бояд баргардонем
var forwardedMessages = make(map[int]int64)
var forwardedMu sync.Mutex

// HandleFeedbackButton вақте ки корбар тугмаи "💬 Бо админ гап зан"-ро
// пахш мекунад — матни паёмашро мепурсад
func HandleFeedbackButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)
	PendingFeedback[msg.From.ID] = true
	sendText(d, msg.Chat.ID, api.GetMessage(lang, "ask_feedback"))
}

// HandleFeedbackText паёми корбарро ба чати админ мефиристад
func HandleFeedbackText(d *Deps, msg *tgbotapi.Message) {
	PendingFeedback[msg.From.ID] = false
	lang := getUserLang(d, msg.From.ID)
	chatID := msg.Chat.ID
	text := strings.TrimSpace(msg.Text)

	if text == "" {
		sendText(d, chatID, api.GetMessage(lang, "ask_feedback"))
		return
	}

	if d.Config.AdminChatID == 0 {
		utils.LogError("feedback received but ADMIN_CHAT_ID is not configured")
		sendText(d, chatID, api.GetMessage(lang, "error_generic"))
		return
	}

	username := msg.From.UserName
	if username == "" {
		username = msg.From.FirstName
	}
	forwardText := fmt.Sprintf("💬 Паём аз @%s (ID: %d, забон: %s):\n\n%s", username, msg.From.ID, lang, text)

	sent, err := d.Bot.Send(tgbotapi.NewMessage(d.Config.AdminChatID, forwardText))
	if err != nil {
		utils.LogError("failed to forward feedback from user=%d: %v", msg.From.ID, err)
		sendText(d, chatID, api.GetMessage(lang, "error_generic"))
		return
	}

	forwardedMu.Lock()
	forwardedMessages[sent.MessageID] = msg.From.ID
	forwardedMu.Unlock()

	sendText(d, chatID, api.GetMessage(lang, "feedback_sent"))
}

// HandleAdminReply вақте ки админ дар чати худ бо бот ба паёми
// фиристодашуда (аз тарафи корбар) Reply мекунад — ҷавобашро ба ҳамон
// корбар мефиристад. Бармегардонад true агар ин воқеан ҷавоби админ буд
func HandleAdminReply(d *Deps, msg *tgbotapi.Message) bool {
	if msg.Chat.ID != d.Config.AdminChatID || msg.ReplyToMessage == nil {
		return false
	}

	forwardedMu.Lock()
	userID, ok := forwardedMessages[msg.ReplyToMessage.MessageID]
	forwardedMu.Unlock()
	if !ok {
		return false
	}

	lang := getUserLang(d, userID)
	text := fmt.Sprintf("%s\n\n%s", api.GetMessage(lang, "admin_reply_prefix"), msg.Text)
	if _, err := d.Bot.Send(tgbotapi.NewMessage(userID, text)); err != nil {
		utils.LogError("failed to relay admin reply to user=%d: %v", userID, err)
		sendText(d, msg.Chat.ID, "⚠️ Натавонистам ҷавобро фиристам — эҳтимол корбар боти шуморо блок кардааст.")
		return true
	}

	sendText(d, msg.Chat.ID, "✅ Ҷавоб фиристода шуд.")
	return true
}
