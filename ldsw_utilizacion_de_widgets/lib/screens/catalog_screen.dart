import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';
import 'admin_screen.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movieService = MovieService();
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          StreamBuilder(
            stream: auth.authStateChanges(),
            builder: (context, snap) {
              final user = snap.data;

              if (user == null) {
                // Solo botón de login
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen(isRegister: false)),
                  ),
                );
              } else {
                // Botón admin + cerrar sesión
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await auth.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión cerrada')),
                        );
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Movie>>(
        stream: movieService.streamMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return const Center(child: Text('No hay películas en el catálogo'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.64,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, i) {
              final m = movies[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: m.id)),
                ),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: m.imageUrl != null
                            ? Image.network(m.imageUrl!, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.movie, size: 64),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          m.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}