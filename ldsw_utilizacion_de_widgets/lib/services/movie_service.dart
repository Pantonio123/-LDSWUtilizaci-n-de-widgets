import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final _collection = 'movies';

  Stream<List<Movie>> streamMovies() {
    return _fire.collection(_collection).orderBy('title').snapshots().map((snap) {
      return snap.docs.map((d) => Movie.fromMap(d.id, d.data())).toList();
    });
  }

  Future<Movie> getMovie(String id) async {
    final doc = await _fire.collection(_collection).doc(id).get();
    return Movie.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> addMovie({
    required String title,
    required String year,
    required String director,
    required String genre,
    required String synopsis,
    required String imageUrl,
  }) async {
    final id = const Uuid().v4();

    await _fire.collection(_collection).doc(id).set({
      'title': title,
      'year': year,
      'director': director,
      'genre': genre,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMovie(String id) async {
    await _fire.collection(_collection).doc(id).delete();
  }
}
