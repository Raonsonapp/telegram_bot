package models

// Genre намояндаи жанри аниме аз Jikan API
type Genre struct {
	MalID int    `json:"mal_id"`
	Name  string `json:"name"`
}

// Images сохтори тасвирҳо дар Jikan API
type Images struct {
	JPG struct {
		ImageURL      string `json:"image_url"`
		LargeImageURL string `json:"large_image_url"`
	} `json:"jpg"`
}

// Aired давраи намоиши аниме
type Aired struct {
	String string `json:"string"`
}

// Anime сохтори асосии маълумоти аниме (зермаҷмӯаи майдонҳои Jikan v4)
type Anime struct {
	MalID         int     `json:"mal_id"`
	Title         string  `json:"title"`
	TitleEnglish  string  `json:"title_english"`
	TitleJapanese string  `json:"title_japanese"`
	Synopsis      string  `json:"synopsis"`
	Score         float64 `json:"score"`
	Episodes      int     `json:"episodes"`
	Status        string  `json:"status"`
	Type          string  `json:"type"`
	Rating        string  `json:"rating"`
	Year          int     `json:"year"`
	URL           string  `json:"url"`
	Images        Images  `json:"images"`
	Aired         Aired   `json:"aired"`
	Genres        []Genre `json:"genres"`
}

// Episode сохтори як қисми (эпизод) аниме
type Episode struct {
	MalID   int    `json:"mal_id"`
	Title   string `json:"title"`
	Aired   string `json:"aired"`
	Score   float64 `json:"score"`
	Filler  bool   `json:"filler"`
	Recap   bool   `json:"recap"`
}

// JikanSearchResponse формати ҷавоби API барои ҷустуҷӯи аниме
type JikanSearchResponse struct {
	Data []Anime `json:"data"`
}

// JikanAnimeResponse формати ҷавоби API барои як аниме
type JikanAnimeResponse struct {
	Data Anime `json:"data"`
}

// JikanEpisodesResponse формати ҷавоби API барои рӯйхати эпизодҳо
type JikanEpisodesResponse struct {
	Data []Episode `json:"data"`
	Pagination struct {
		HasNextPage bool `json:"has_next_page"`
	} `json:"pagination"`
}
