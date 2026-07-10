package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"
)

// RequiredReferralsForUnlimitedAI — шумораи даъватҳои воқеӣ (обунашуда), ки
// барои кушодани ҳуқуқи бемаҳдуди AI дар App Builder лозим аст
const RequiredReferralsForUnlimitedAI = 5

// referralStateRepoName репои махсусе, ки дар он маълумоти даъватҳо (referrals)
// ҳамчун файли JSON нигоҳ дошта мешавад — на дар SQLite-и муваққатии Render,
// ки бо ҳар деплой пок мешавад. GitHub ин ҷо ҳамчун манбаи ягонаи ҳақиқати
// доимӣ истифода мешавад (ҳамон принсипе, ки барои репоҳои корбарон истифода
// шудааст)
const referralStateRepoName = "appbuilder-bot-state"
const referralStateFilePath = "referrals.json"

// ReferralEntry як воқеаи даъватро ифода мекунад
type ReferralEntry struct {
	Referrer int64 `json:"referrer"`
	Referred int64 `json:"referred"`
}

type referralStateFile struct {
	Referrals []ReferralEntry `json:"referrals"`
}

// ReferralStore маълумоти даъватҳоро дар репои давлатии бот (GitHub) нигоҳ
// медорад — доимӣ, новобаста аз деплойҳои Render. Дар хотир кэш карда
// мешавад (як бор аз GitHub хонда мешавад), баъд ҳар тағйирот ҳам дар хотир
// ва ҳам дар GitHub сабт мешавад
type ReferralStore struct {
	gh *GitHubAppClient

	mu           sync.Mutex
	data         referralStateFile
	repoFullName string
	loaded       bool
}

// NewReferralStore ReferralStore-и наверо месозад
func NewReferralStore(gh *GitHubAppClient) *ReferralStore {
	return &ReferralStore{gh: gh}
}

func (s *ReferralStore) ensureLoaded() error {
	if s.loaded {
		return nil
	}

	owner, err := s.gh.CurrentOwner()
	if err != nil {
		return fmt.Errorf("referralstore: failed to resolve owner: %w", err)
	}
	full := fmt.Sprintf("%s/%s", owner, referralStateRepoName)

	if err := s.gh.ensureStateRepoExists(); err != nil {
		return fmt.Errorf("referralstore: failed to ensure state repo exists: %w", err)
	}
	s.repoFullName = full

	content, err := s.gh.getFileContent(full, referralStateFilePath)
	if err != nil {
		// Файл ҳанӯз вуҷуд надорад (репои нав) — холӣ сар мекунем
		s.data = referralStateFile{}
		s.loaded = true
		return nil
	}

	var parsed referralStateFile
	if err := json.Unmarshal([]byte(content), &parsed); err != nil {
		return fmt.Errorf("referralstore: failed to parse referrals.json: %w", err)
	}
	s.data = parsed
	s.loaded = true
	return nil
}

func (s *ReferralStore) save() error {
	body, err := json.MarshalIndent(s.data, "", "  ")
	if err != nil {
		return err
	}
	return s.gh.PushFile(s.repoFullName, referralStateFilePath, "Update referrals", string(body))
}

// AddReferral сабт мекунад, ки referrerID корбари referredID-ро даъват
// кардааст. Ҳар корбар танҳо як бор (аз тарафи аввалин даъваткунанда) ҳисоб
// мешавад. Бо "true" бармегардад, агар воқеан НАВ сабт шуда бошад
func (s *ReferralStore) AddReferral(referrerID, referredID int64) (bool, error) {
	if referrerID == 0 || referredID == 0 || referrerID == referredID {
		return false, nil
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.ensureLoaded(); err != nil {
		return false, err
	}

	for _, r := range s.data.Referrals {
		if r.Referred == referredID {
			return false, nil
		}
	}

	s.data.Referrals = append(s.data.Referrals, ReferralEntry{Referrer: referrerID, Referred: referredID})
	if err := s.save(); err != nil {
		// агар push ноком шавад, тағйиротро дар хотир бозмегардонем, то
		// ҳолати кэш аз GitHub-и воқеӣ дур наравад
		s.data.Referrals = s.data.Referrals[:len(s.data.Referrals)-1]
		return false, err
	}
	return true, nil
}

// CountReferrals шумораи корбароне, ки referrerID даъват кардааст, бармегардонад
func (s *ReferralStore) CountReferrals(referrerID int64) (int, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.ensureLoaded(); err != nil {
		return 0, err
	}

	count := 0
	for _, r := range s.data.Referrals {
		if r.Referrer == referrerID {
			count++
		}
	}
	return count, nil
}

// HasUnlimitedAI нишон медиҳад, ки оё корбар ба ҳадди даъватҳо расидааст
func (s *ReferralStore) HasUnlimitedAI(telegramID int64) (bool, error) {
	count, err := s.CountReferrals(telegramID)
	if err != nil {
		return false, err
	}
	return count >= RequiredReferralsForUnlimitedAI, nil
}

// ensureStateRepoExists репои давлатии ботро (агар набошад) месозад —
// хусусан, шахсӣ (private), бе workflow, танҳо барои нигоҳ доштани JSON
func (c *GitHubAppClient) ensureStateRepoExists() error {
	payload, _ := json.Marshal(map[string]interface{}{
		"name":        referralStateRepoName,
		"description": "App Builder bot: durable state (referrals) — not a user app",
		"private":     true,
		"auto_init":   true,
	})

	body, status, err := c.doRequest(http.MethodPost, "/user/repos", payload)
	if err != nil {
		return err
	}
	if status == http.StatusCreated {
		// то auto_init хотима ёбад, пеш аз навиштани файли дигар
		time.Sleep(2 * time.Second)
		return nil
	}
	if status == http.StatusUnprocessableEntity && strings.Contains(string(body), "already exists") {
		return nil
	}
	return fmt.Errorf("status %d, body: %s", status, string(body))
}
