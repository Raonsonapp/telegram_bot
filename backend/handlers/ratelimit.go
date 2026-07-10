package handlers

import (
	"sync"
	"time"
)

// Ҳадди истифодаи ройгони AI: то freeAIUsagePerDay бор дар як тиреза
// (aiUsageWindow) бе монеъ. Аз он зиёд — cooldown, ки вобаста ба дараҷаи
// истифодаи барзиёд аз 1 то 3 соат меафзояд (на ҳамеша якхела — "вобаста ба
// коркарди корбар", тавре ки дархост шуда буд)
const (
	freeAIUsagePerDay = 10
	aiUsageWindow     = 24 * time.Hour
	minCooldownHours  = 1
	maxCooldownHours  = 3
	// ба ҳар overageStep дархости иловагӣ, 1 соати дигар ба cooldown илова мешавад
	overageStep = 3
)

var (
	aiUsageMu       sync.Mutex
	aiUsageLog      = make(map[int64][]time.Time)
	aiCooldownUntil = make(map[int64]time.Time)
)

// checkAIRateLimit санҷиш мекунад, ки оё корбар ҳозир метавонад AI-ро
// истифода барад. Агар cooldown фаъол бошад, false ва вақти боқимондаро
// бармегардонад. Вагарна дархостро сабт мекунад (барои санҷиши навбатӣ)
// ва агар аз ҳад гузашт, cooldown-и нав месозад
func checkAIRateLimit(userID int64) (allowed bool, retryAfter time.Duration) {
	aiUsageMu.Lock()
	defer aiUsageMu.Unlock()

	now := time.Now()

	if until, ok := aiCooldownUntil[userID]; ok {
		if now.Before(until) {
			return false, until.Sub(now)
		}
		delete(aiCooldownUntil, userID)
	}

	var recent []time.Time
	for _, t := range aiUsageLog[userID] {
		if now.Sub(t) < aiUsageWindow {
			recent = append(recent, t)
		}
	}
	recent = append(recent, now)
	aiUsageLog[userID] = recent

	if len(recent) <= freeAIUsagePerDay {
		return true, 0
	}

	overage := len(recent) - freeAIUsagePerDay
	hours := minCooldownHours + overage/overageStep
	if hours > maxCooldownHours {
		hours = maxCooldownHours
	}
	cooldown := time.Duration(hours) * time.Hour
	aiCooldownUntil[userID] = now.Add(cooldown)
	return false, cooldown
}
