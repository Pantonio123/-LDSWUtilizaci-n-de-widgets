import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {
  static const _baseUrl = 'api.themoviedb.org';
  static const _imageBase = 'https://image.tmdb.org/t/p/w500';

  final String apiKey;
  TMDBService({required this.apiKey});

  String posterUrl(String? path) {
    if (path == null) return '';
    return '$_imageBase$path';
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    final q = Map<String, String>.from(query ?? {});
    q['api_key'] = apiKey;
    return Uri.https(_baseUrl, path, q);
  }

  /// GET /movie/popular
  Future<List<dynamic>> fetchPopularMovies({int page = 1}) async {
    final uri = _buildUri('/3/movie/popular', {'page': page.toString()});
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}: ${resp.body}');
    final Map<String, dynamic> jsonBody = json.decode(resp.body);
    return jsonBody['results'] as List<dynamic>? ?? [];
  }

  /// GET /search/movie?query=
  Future<List<dynamic>> searchMovies(String query, {int page = 1}) async {
    final uri = _buildUri('/3/search/movie', {'query': query, 'page': page.toString()});
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}: ${resp.body}');
    final Map<String, dynamic> jsonBody = json.decode(resp.body);
    return jsonBody['results'] as List<dynamic>? ?? [];
  }

  /// GET /movie/{movie_id}
  Future<Map<String, dynamic>> getMovieDetail(int movieId) async {
    final uri = _buildUri('/3/movie/$movieId');
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}: ${resp.body}');
    final Map<String, dynamic> jsonBody = json.decode(resp.body);
    return jsonBody;
  }
}
