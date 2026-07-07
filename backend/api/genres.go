package api

// jikanGenreNames номи расмии жанрҳо мутобиқи ID-и Jikan/MyAnimeList.
// Барои AniList (манбаи эҳтиётӣ) лозим аст, зеро он бо номи жанр кор мекунад, на ID
var jikanGenreNames = map[int]string{
	1:  "Action",
	2:  "Adventure",
	4:  "Comedy",
	7:  "Mystery",
	8:  "Drama",
	10: "Fantasy",
	14: "Horror",
	18: "Mecha",
	19: "Music",
	22: "Romance",
	24: "Sci-Fi",
	30: "Sports",
	36: "Slice of Life",
	37: "Supernatural",
	40: "Psychological",
	41: "Thriller",
}

// GenreIDsToNames ID-ҳои жанрро ба номҳои мутобиқ табдил медиҳад
func GenreIDsToNames(ids []int) []string {
	names := make([]string, 0, len(ids))
	for _, id := range ids {
		if name, ok := jikanGenreNames[id]; ok {
			names = append(names, name)
		}
	}
	return names
}
