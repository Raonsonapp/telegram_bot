package models

// WatchStatus ҳолати тамошои аниме аз ҷониби корбар
type WatchStatus string

const (
	StatusWatching  WatchStatus = "watching"
	StatusCompleted WatchStatus = "completed"
)

// Favorite сабти анимее, ки корбар ба Севимиҳо илова кардааст
type Favorite struct {
	AnimeID int
	Title   string
	Year    int
	Genres  string
}

// WatchEntry сабти таърихи тамошои корбар барои як аниме
type WatchEntry struct {
	AnimeID       int
	Title         string
	Year          int
	Status        WatchStatus
	TotalEpisodes int
	Genres        string
}

// RecentlyViewed сабти анимее, ки корбар ба наздикӣ дидааст
type RecentlyViewed struct {
	AnimeID int
	Title   string
	Year    int
}

// ProfileStats омори шахсии корбар барои саҳифаи профил
type ProfileStats struct {
	Language       string
	RegisteredAt   string
	FavoritesCount int
	WatchingCount  int
	CompletedCount int
	TotalEpisodes  int
	TopGenres      []string
}
