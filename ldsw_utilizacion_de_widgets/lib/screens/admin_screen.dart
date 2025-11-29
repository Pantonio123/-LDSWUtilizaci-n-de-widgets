import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _year = TextEditingController();
  final _director = TextEditingController();
  final _genre = TextEditingController();
  final _synopsis = TextEditingController();
  final _imageURL = TextEditingController();
  final _svc = MovieService();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _svc.addMovie(
        title: _title.text.trim(),
        year: _year.text.trim(),
        director: _director.text.trim(),
        genre: _genre.text.trim(),
        synopsis: _synopsis.text.trim(),
        imageUrl: _imageURL.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Película agregada')));
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Gestionar Películas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => v==null||v.isEmpty ? 'Requerido' : null),
                TextFormField(controller: _year, decoration: const InputDecoration(labelText: 'Año'), validator: (v)=> v==null||v.isEmpty? 'Requerido':null),
                TextFormField(controller: _director, decoration: const InputDecoration(labelText: 'Director')),
                TextFormField(controller: _genre, decoration: const InputDecoration(labelText: 'Género')),
                TextFormField(controller: _synopsis, decoration: const InputDecoration(labelText: 'Sinopsis'), maxLines: 3),
                TextFormField(controller: _imageURL, decoration: const InputDecoration(labelText: 'URL de Imagen')),
                const SizedBox(height: 12),
                _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _submit, child: const Text('Agregar película')),
              ]),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Películas existentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            StreamBuilder(
              stream: _svc.streamMovies(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final movies = snapshot.data as List<Movie>;
                if (movies.isEmpty) return const Text('No hay películas');
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: movies.length,
                  separatorBuilder: (_,__) => const Divider(),
                  itemBuilder: (context, i) {
                    final m = movies[i];
                    return ListTile(
                      leading: m.imageUrl != null ? Image.network(m.imageUrl!, width: 56, fit: BoxFit.cover) : const Icon(Icons.movie),
                      title: Text(m.title),
                      subtitle: Text(m.year),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                          final ok = await showDialog<bool>(context: context, builder: (_) {
                            return AlertDialog(
                              title: const Text('Confirmar'),
                              content: const Text('¿Eliminar película?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context,false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context,true), child: const Text('Eliminar')),
                              ],
                            );
                          });
                          if (ok == true) {
                            await _svc.deleteMovie(m.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminada')));
                          }
                        })]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
