import 'package:flutter/material.dart';
import 'services/tmdb_service.dart';
import 'pages/movies_page.dart';

const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY', defaultValue: '');

void main() => runApp(const CatalogoPeliculasApp());

class CatalogoPeliculasApp extends StatelessWidget {
  const CatalogoPeliculasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDSW - Catálogo de Películas',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LaunchAlwaysWelcome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LaunchAlwaysWelcome extends StatefulWidget {
  const LaunchAlwaysWelcome({super.key});

  @override
  State<LaunchAlwaysWelcome> createState() => _LaunchAlwaysWelcomeState();
}

class _LaunchAlwaysWelcomeState extends State<LaunchAlwaysWelcome> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => WelcomeScreen(
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const CatalogPage();
  }
}

/// Pantalla modal de bienvenida
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onClose;
  const WelcomeScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen local
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cine_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Capa oscura arriba del fondo
          Container(
            color: Colors.black.withOpacity(0.60),
          ),

          SafeArea(
            child: Stack(
              children: [
                // Botón X para cerrar
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // Tarjeta de bienvenida centrada
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_movies,
                                size: 50, color: Colors.indigo),
                            const SizedBox(height: 12),
                            const Text(
                              '¡Bienvenido a 🍿 RecomiedaPelis',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Explora películas, estrenos y clásicos del cine 🍿🎬',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: onClose,
                              child: const Text('Comenzar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Página principal (catálogo)
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Crea el servicio de TMDb 
    final tmdb = TMDBService(apiKey: tmdbApiKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Catálogo de Películas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.movie),
            tooltip: 'Películas (TMDb)',
            onPressed: () {
              if (tmdbApiKey.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Falta TMDB_API_KEY. Ejecuta con --dart-define=TMDB_API_KEY=TU_KEY')),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MoviesPage(tmdb: tmdb)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Explora los estrenos y clásicos', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            _movieCard(
              'Inception',
              'Ciencia ficción',
              4.8,
              'https://image.tmdb.org/t/p/w500/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg',
            ),
            _movieCard(
              'Interstellar',
              'Drama / Ciencia ficción',
              4.9,
              'https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
            ),
            _movieCard(
              'The Dark Knight',
              'Acción / Suspenso',
              4.7,
              'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _movieCard(String title, String genre, double rating, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 4))
      ]),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover)),
          Container(height: 220, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.35))),
          Positioned(bottom: 12, left: 12, right: 12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(genre, style: const TextStyle(color: Colors.white70)),
              Row(children: [const Icon(Icons.star, color: Colors.yellow, size: 18), const SizedBox(width: 6), Text(rating.toString(), style: const TextStyle(color: Colors.white))])
            ])
          ])),
        ],
      ),
    );
  }
}
