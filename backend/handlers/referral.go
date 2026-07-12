package handlers

import (
	"fmt"
	"strconv"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"appbuilder-bot/backend/api"
	"appbuilder-bot/backend/utils"
)

// PendingReferral референси /start-и аввалини корбарро (агар тавассути
// линки даъвати касе омада бошад) то субут кардани обуна нигоҳ медорад —
// зеро агар корбар ҳанӯз обуна набошад, HandleStart то тасдиқи обуна
// иҷро намешавад ва payload-и /start-и такрорӣ гум мешавад
var PendingReferral = make(map[int64]int64)

// referralPrefix пешванди payload-и /start барои линки даъват
const referralPrefix = "ref_"

// CapturePendingReferralArg агар паём /start бо payload-и "ref_<ID>" бошад,
// ID-и даъваткунандаро дар PendingReferral нигоҳ медорад — новобаста аз он
// ки корбар ҳоло обуна аст ё не (то дар HandleStart истифода шавад). Бояд
// ПЕШ АЗ санҷиши ҳатмии обуна даъват карда шавад, вагарна payload гум мешавад
func CapturePendingReferralArg(msg *tgbotapi.Message) {
	if !msg.IsCommand() || msg.Command() != "start" {
		return
	}
	arg := strings.TrimSpace(msg.CommandArguments())
	if !strings.HasPrefix(arg, referralPrefix) {
		return
	}
	referrerID, err := strconv.ParseInt(strings.TrimPrefix(arg, referralPrefix), 10, 64)
	if err != nil || referrerID == 0 {
		return
	}
	PendingReferral[msg.From.ID] = referrerID
}

// ReferralLink линки шахсии даъвати корбарро месозад
func ReferralLink(botUsername string, telegramID int64) string {
	return fmt.Sprintf("https://t.me/%s?start=%s%d", botUsername, referralPrefix, telegramID)
}

// applyPendingReferralIfAny агар барои ин корбар референси интизорӣ мавҷуд
// бошад (аз линки даъват омада бошад) ва корбар воқеан НАВ бошад, референсро
// сабт мекунад ва ба даъваткунанда хабар медиҳад (ин ҷо, азбаски HandleStart
// танҳо БАЪД аз субути ҳатмии обуна иҷро мешавад, шарти "обуна бошад" худкор
// иҷро шудааст)
func applyPendingReferralIfAny(d *Deps, telegramID int64, isNew bool) {
	if !isNew {
		delete(PendingReferral, telegramID)
		return
	}

	referrerID, ok := PendingReferral[telegramID]
	if !ok {
		return
	}
	delete(PendingReferral, telegramID)

	added, err := d.Referrals.AddReferral(referrerID, telegramID)
	if err != nil {
		utils.LogError("referral: failed to record referral %d->%d: %v", referrerID, telegramID, err)
		return
	}
	if !added {
		return
	}

	count, err := d.Referrals.CountReferrals(referrerID)
	if err != nil {
		utils.LogError("referral: failed to count referrals for %d: %v", referrerID, err)
		return
	}

	refLang := getUserLang(d, referrerID)
	var text string
	if count >= api.RequiredReferralsForUnlimitedAI {
		text = fmt.Sprintf(api.GetMessage(refLang, "referral_unlocked"), api.RequiredReferralsForUnlimitedAI)
	} else {
		text = fmt.Sprintf(api.GetMessage(refLang, "referral_progress"), count, api.RequiredReferralsForUnlimitedAI)
	}
	d.Bot.Send(tgbotapi.NewMessage(referrerID, text))
}

// HandleInviteButton линки шахсии даъват ва пешрафти ҳозираи корбарро нишон медиҳад
func HandleInviteButton(d *Deps, msg *tgbotapi.Message) {
	lang := getUserLang(d, msg.From.ID)

	count, err := d.Referrals.CountReferrals(msg.From.ID)
	if err != nil {
		utils.LogError("referral: failed to count referrals for %d: %v", msg.From.ID, err)
		count = 0
	}

	link := ReferralLink(d.Bot.Self.UserName, msg.From.ID)
	remaining := api.RequiredReferralsForUnlimitedAI - count
	if remaining < 0 {
		remaining = 0
	}

	var text string
	if count >= api.RequiredReferralsForUnlimitedAI {
		text = fmt.Sprintf(api.GetMessage(lang, "invite_unlocked"), link)
	} else {
		text = fmt.Sprintf(api.GetMessage(lang, "invite_progress"), link, count, api.RequiredReferralsForUnlimitedAI, remaining)
	}
	sendTextMarkdown(d, msg.Chat.ID, text)
}
