import 'package:flutter/material.dart';

void main() => runApp(const CatalogoPeliculasApp());

class CatalogoPeliculasApp extends StatelessWidget {
  const CatalogoPeliculasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecomiedaPelis',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const CatalogoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CatalogoPage extends StatelessWidget {
  const CatalogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍿 RecomiedaPelis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Título principal
            const Text(
              'Explora los estrenos y clásicos del cine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Películas (ejemplo con 3 tarjetas)
            _tarjetaPelicula(
              titulo: 'Inception',
              genero: 'Ciencia ficción',
              calificacion: 4.8,
              urlImagen: 'https://image.tmdb.org/t/p/w500/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg', //usare the movie data base para las imagenes 
            ),
            _tarjetaPelicula(
              titulo: 'Interstellar',
              genero: 'Drama / Ciencia ficción',
              calificacion: 4.9,
              urlImagen: 'https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
            ),
            _tarjetaPelicula(
              titulo: 'The Dark Knight',
              genero: 'Acción / Suspenso',
              calificacion: 4.7,
              urlImagen: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
            ),
          ],
        ),
      ),
    );
  }

  // Widget personalizado: tarjeta de película
  Widget _tarjetaPelicula({
    required String titulo,
    required String genero,
    required double calificacion,
    required String urlImagen,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          // Imagen de fondo (póster)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              urlImagen,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Capa oscura sobre la imagen
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // Contenido de texto superpuesto (Stack)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Row: género y calificación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      genero,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 18),
                        Text(
                          calificacion.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
