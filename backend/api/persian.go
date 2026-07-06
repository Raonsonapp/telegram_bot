package api

// PersianMessages сатрҳои интерфейс барои забони форсӣ (فارسی)
var PersianMessages = map[string]string{
	"welcome":            "👋 به *AnimeBot* خوش آمدید!\n\nلطفاً زبان خود را انتخاب کنید:",
	"welcome_back":       "👋 خوش برگشتید، %s!\n\nچه کاری می‌خواهید انجام دهید؟",
	"language_set":       "✅ زبان به فارسی تغییر یافت!",
	"main_menu":          "چه کاری می‌خواهید انجام دهید؟",
	"btn_search":         "🔍 جستجوی انیمه",
	"btn_random":         "🎲 انیمه تصادفی",
	"btn_top":            "🏆 برترین انیمه‌ها",
	"btn_settings":       "⚙️ تنظیمات",
	"btn_help":           "❓ راهنما",
	"ask_search_query":   "🔍 نام انیمه‌ای که می‌خواهید جستجو کنید را بفرستید:",
	"searching":          "🔎 در حال جستجوی \"%s\"...",
	"no_results":         "😔 انیمه‌ای برای \"%s\" یافت نشد. نام دیگری را امتحان کنید.",
	"search_results":     "🔍 نتایج برای \"%s\":",
	"loading_anime":      "⏳ در حال بارگذاری اطلاعات انیمه...",
	"anime_not_found":    "😔 انیمه یافت نشد.",
	"episodes_title":     "📺 قسمت‌های *%s*",
	"no_episodes":        "اطلاعات قسمت‌ها هنوز موجود نیست.",
	"btn_episodes":       "📺 قسمت‌ها",
	"btn_open_mal":       "🔗 مشاهده در MyAnimeList",
	"btn_back":           "⬅️ بازگشت",
	"btn_back_to_menu":   "⬅️ بازگشت به منو",
	"settings_title":     "⚙️ *تنظیمات*\n\nزبان فعلی: %s",
	"btn_change_lang":    "🌐 تغییر زبان",
	"help_text":          "🤖 *راهنمای AnimeBot*\n\nنام هر انیمه‌ای را برای جستجو بفرستید یا از دکمه‌های منو استفاده کنید.\n\nدستورات:\n/start - راه‌اندازی مجدد ربات\n/search <نام> - جستجوی انیمه\n/random - انیمه تصادفی\n/top - لیست برترین‌ها\n/settings - تغییر زبان\n/help - نمایش این پیام",
	"error_generic":      "⚠️ مشکلی پیش آمد. لطفاً بعداً دوباره تلاش کنید.",
	"score_label":        "⭐ امتیاز",
	"episodes_label":     "📺 قسمت‌ها",
	"status_label":       "📌 وضعیت",
	"type_label":         "🎞 نوع",
	"year_label":         "📅 سال",
	"genres_label":       "🏷 ژانرها",
	"top_title":          "🏆 برترین انیمه‌های حال حاضر",
	"random_loading":     "🎲 در حال انتخاب یک انیمه تصادفی...",
}

// GetMessage паёми маҳаллисозишударо аз рӯи забон ва калид бармегардонад.
// Агар забон ё калид ёфт нашавад, ба забони англисӣ бармегардад.
func GetMessage(lang, key string) string {
	var dict map[string]string
	switch lang {
	case "ru":
		dict = RussianMessages
	case "fa":
		dict = PersianMessages
	default:
		dict = EnglishMessages
	}

	if val, ok := dict[key]; ok {
		return val
	}
	// fallback ба англисӣ
	if val, ok := EnglishMessages[key]; ok {
		return val
	}
	return key
}
