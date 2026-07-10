package database

import "time"

// RequiredReferralsForUnlimitedAI — шумораи даъватҳои воқеӣ (обунашуда), ки
// барои кушодани ҳуқуқи бемаҳдуди AI дар App Builder лозим аст
const RequiredReferralsForUnlimitedAI = 5

// AddReferral сабт мекунад, ки referrerID корбари referredID-ро даъват
// кардааст. referred_id UNIQUE аст — ҳар корбар танҳо як бор (аз тарафи
// аввалин даъваткунанда) ҳисоб мешавад, ҳатто агар боз /start занад.
// Бо "true" бармегардад, агар воқеан НАВ сабт шуда бошад
func (d *DB) AddReferral(referrerID, referredID int64) (bool, error) {
	if referrerID == 0 || referredID == 0 || referrerID == referredID {
		return false, nil
	}
	res, err := d.Conn.Exec(
		`INSERT OR IGNORE INTO referrals (referrer_id, referred_id, created_at) VALUES (?, ?, ?)`,
		referrerID, referredID, time.Now().Format(time.RFC3339),
	)
	if err != nil {
		return false, err
	}
	n, err := res.RowsAffected()
	if err != nil {
		return false, err
	}
	return n > 0, nil
}

// CountReferrals шумораи корбароне, ки referrerID даъват кардааст, бармегардонад
func (d *DB) CountReferrals(referrerID int64) (int, error) {
	var count int
	err := d.Conn.QueryRow(`SELECT COUNT(*) FROM referrals WHERE referrer_id = ?`, referrerID).Scan(&count)
	return count, err
}

// HasUnlimitedAI нишон медиҳад, ки оё корбар ба ҳадди даъватҳо расидааст
// (RequiredReferralsForUnlimitedAI) ва ҳуқуқи бемаҳдуди AI-и App Builder дорад
func (d *DB) HasUnlimitedAI(telegramID int64) (bool, error) {
	count, err := d.CountReferrals(telegramID)
	if err != nil {
		return false, err
	}
	return count >= RequiredReferralsForUnlimitedAI, nil
}
