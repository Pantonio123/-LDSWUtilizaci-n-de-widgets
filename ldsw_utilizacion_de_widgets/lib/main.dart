import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

import 'services/tmdb_service.dart';
import 'pages/movies_page.dart';

import './screens/auth_screen.dart';
import './screens/catalog_screen.dart';
import './services/auth_service.dart';

const String tmdbApiKey = String.fromEnvironment(
  'TMDB_API_KEY', 
  defaultValue: 'd035d7cbf1457be5c528dc9a628ffc11'
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('ERROR Firebase: $e');
  }

  runApp(const CatalogoPeliculasApp());
}

class CatalogoPeliculasApp extends StatelessWidget {
  const CatalogoPeliculasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDSW - Catálogo de Películas',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Pantalla de bienvenida con detección automática de sesión
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se carga el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay usuario logueado, navegar directo al catálogo
        if (snapshot.hasData) {
          Future.microtask(() {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CatalogScreen()),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si no hay usuario, mostrar pantalla de bienvenida
        void onClose() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CatalogScreen()),
          );
        }

        void onRegister() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen(isRegister: true)),
          );
        }

        void onLogin() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen(isRegister: false)),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/cine_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(color: Colors.black.withOpacity(0.6)),
              SafeArea(
                child: Center(
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
                            const Icon(Icons.local_movies, size: 50, color: Colors.indigo),
                            const SizedBox(height: 12),
                            const Text(
                              '¡Bienvenido a RecomiedaPelis 🍿',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Explora películas, estrenos y clásicos del cine 🍿🎬',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Regístrate para ver y administrar el catálogo, o ingresa si ya tienes cuenta.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(onPressed: onRegister, child: const Text('Registrarse')),
                            const SizedBox(height: 10),
                            OutlinedButton(onPressed: onLogin, child: const Text('Iniciar sesión')),
                            const SizedBox(height: 20),
                            ElevatedButton(onPressed: onClose, child: const Text('Ver catálogo como invitado')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Página principal del catálogo
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => MoviesPage(tmdb: tmdb)));
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover),
          ),
          Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.35)),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(genre, style: const TextStyle(color: Colors.white70)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 18),
                        const SizedBox(width: 6),
                        Text(rating.toString(), style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}