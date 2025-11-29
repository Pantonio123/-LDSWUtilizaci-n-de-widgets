class Movie {
  final String id;
  final String title;
  final String year;
  final String director;
  final String genre;
  final String synopsis;
  final String? imageUrl;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.director,
    required this.genre,
    required this.synopsis,
    this.imageUrl,
  });

  factory Movie.fromMap(String id, Map<String, dynamic> m) {
    return Movie(
      id: id,
      title: m['title'] ?? '',
      year: m['year'] ?? '',
      director: m['director'] ?? '',
      genre: m['genre'] ?? '',
      synopsis: m['synopsis'] ?? '',
      imageUrl: m['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'director': director,
      'genre': genre,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
    };
  }
}
