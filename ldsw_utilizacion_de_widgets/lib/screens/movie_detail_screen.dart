import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';

class MovieDetailScreen extends StatelessWidget {
  final String movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final svc = MovieService();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: FutureBuilder<Movie>(
        future: svc.getMovie(movieId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final m = snap.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (m.imageUrl != null) Image.network(m.imageUrl!, height: 300, fit: BoxFit.cover) else Container(height: 300, color: Colors.grey[300]),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Año: ${m.year}'),
                    const SizedBox(height: 4),
                    Text('Director: ${m.director}'),
                    const SizedBox(height: 4),
                    Text('Género: ${m.genre}'),
                    const SizedBox(height: 12),
                    const Text('Sinopsis', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(m.synopsis),
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
