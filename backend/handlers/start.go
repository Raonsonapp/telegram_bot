package handlers

import (
	"fmt"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"anime-bot/api"
	"anime-bot/config"
	"anime-bot/database"
	"anime-bot/keyboard"
	"anime-bot/utils"
)

// Deps тамоми вобастагиҳои муштарак барои ҳамаи handler-ҳо
type Deps struct {
	Bot    *tgbotapi.BotAPI
	DB     *database.DB
	Jikan  *api.JikanClient
	Cache  *utils.Cache
	Config *config.Config
}

// PendingSearch нигоҳ медорад кадом корбарон мунтазири фиристодани матни ҷустуҷӯ ҳастанд
var PendingSearch = make(map[int64]bool)

// HandleStart дархости /start-ро коркард мекунад
func HandleStart(d *Deps, msg *tgbotapi.Message) {
	telegramID := msg.From.ID
	username := msg.From.UserName

	user, isNew, err := d.DB.GetOrCreateUser(telegramID, username, d.Config.DefaultLanguage)
	if err != nil {
		utils.LogError("failed to get/create user: %v", err)
		sendText(d, msg.Chat.ID, "⚠️ Database error. Please try again.")
		return
	}

	if isNew {
		text := api.GetMessage(d.Config.DefaultLanguage, "welcome")
		message := tgbotapi.NewMessage(msg.Chat.ID, text)
		message.ParseMode = tgbotapi.ModeMarkdown
		message.ReplyMarkup = keyboard.LanguageKeyboard()
		d.Bot.Send(message)
		return
	}

	name := msg.From.FirstName
	if name == "" {
		name = "there"
	}
	text := fmt.Sprintf(api.GetMessage(user.Language, "welcome_back"), name)
	message := tgbotapi.NewMessage(msg.Chat.ID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	message.ReplyMarkup = keyboard.MainMenu(user.Language)
	d.Bot.Send(message)
}

// sendText функсияи ёрирасон барои фиристодани матни оддӣ
func sendText(d *Deps, chatID int64, text string) {
	message := tgbotapi.NewMessage(chatID, text)
	d.Bot.Send(message)
}

// sendTextMarkdown паёмро бо форматгузории Markdown мефиристад
func sendTextMarkdown(d *Deps, chatID int64, text string) {
	message := tgbotapi.NewMessage(chatID, text)
	message.ParseMode = tgbotapi.ModeMarkdown
	d.Bot.Send(message)
}

// getUserLang забони корбарро мегирад ё пешфарзро бармегардонад
func getUserLang(d *Deps, telegramID int64) string {
	user, err := d.DB.GetUserByTelegramID(telegramID)
	if err != nil || user == nil {
		return d.Config.DefaultLanguage
	}
	return user.Language
}
