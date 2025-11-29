import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class MoviesPage extends StatefulWidget {
  final TMDBService tmdb;
  const MoviesPage({super.key, required this.tmdb});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late Future<List<dynamic>> _futureMovies;

  @override
  void initState() {
    super.initState();
    _futureMovies = widget.tmdb.fetchPopularMovies();
  }

  void _search(String text) {
    setState(() {
      _futureMovies = text.trim().isEmpty ? widget.tmdb.fetchPopularMovies() : widget.tmdb.searchMovies(text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar películas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final movies = snapshot.data ?? [];
                if (movies.isEmpty) return const Center(child: Text('No hay resultados'));
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: movies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = movies[index] as Map<String, dynamic>;
                    final title = item['title'] ?? 'Sin título';
                    final overview = (item['overview'] ?? '').toString();
                    final posterPath = item['poster_path'] as String?;
                    final poster = posterPath != null ? widget.tmdb.posterUrl(posterPath) : null;
                    final voteAvg = (item['vote_average'] ?? 0).toString();

                    return Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: poster != null
                          ? Image.network(poster, width: 56, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.broken_image))
                          : const Icon(Icons.movie),
                        title: Text(title),
                        subtitle: Text(overview.isNotEmpty ? (overview.length > 120 ? overview.substring(0, 120) + '...' : overview) : 'Sin descripción'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [const Icon(Icons.star, color: Colors.yellow, size: 18), Text(voteAvg)],
                        ),
                        onTap: () {
                          final id = item['id'] as int?;
                          if (id != null) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetailPage(tmdb: widget.tmdb, movieId: id)));
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieDetailPage extends StatefulWidget {
  final TMDBService tmdb;
  final int movieId;
  const MovieDetailPage({super.key, required this.tmdb, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late Future<Map<String, dynamic>> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = widget.tmdb.getMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final movie = snapshot.data!['movie'];
          final credits = snapshot.data!['credits'];
          final posterPath = movie['poster_path'] as String?;
          final poster = posterPath != null ? widget.tmdb.posterUrl(posterPath) : null;
          final title = movie['title'] ?? 'Sin título';
          final overview = movie['overview'] ?? '';
          final releaseDate = movie['release_date'] ?? '';
          final genre = movie['genres'][0]['name'] ?? '';
          final director = (credits['crew'] as List).firstWhere(
            (e) => e['job'] == 'Director', 
            orElse: () => {'name': 'Desconocido'}
          )['name'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (poster != null)
                  Image.network(poster, height: 350, fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(height: 350, color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Genero: $genre', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    Text('Director: $director', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    Text('Fecha de estreno: $releaseDate', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    Text(overview),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
