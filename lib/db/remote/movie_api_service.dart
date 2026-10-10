import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:moviego/core/constants/app_constants.dart';
import 'package:moviego/db/mock/mock_data.dart';
import 'package:moviego/models/movie_model.dart';

class MovieApiService {
  final http.Client client;
  final String? _providedApiKey;

  MovieApiService({http.Client? client, String? apiKey})
      : client = client ?? http.Client(),
        _providedApiKey = apiKey;

  String get _apiKey {
    if (_providedApiKey != null) return _providedApiKey.trim();
    try {
      return dotenv.env['TMDB_API_KEY']?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  bool get _hasApiKey {
    final key = _apiKey.toUpperCase();
    return key.isNotEmpty &&
        key != 'DEMO_KEY' &&
        key != 'YOUR_TMDB_API_KEY' &&
        key != 'YOUR_API_KEY' &&
        key != 'REPLACE_ME';
  }

  Future<List<MovieModel>> fetchNowPlaying({int page = 1}) async {
    final data = await _fetchPage('/movie/now_playing', page: page);
    return data;
  }

  Future<List<MovieModel>> fetchPopular({int page = 1}) async {
    final data = await _fetchPage('/movie/popular', page: page);
    return data;
  }

  Future<List<MovieModel>> fetchUpcoming({int page = 1}) async {
    final data = await _fetchPage('/movie/upcoming', page: page);
    return data;
  }

  Future<List<MovieModel>> fetchTopRated({int page = 1}) async {
    final data = await _fetchPage('/movie/top_rated', page: page);
    return data;
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return const [];

    if (!_hasApiKey) return _searchDemoMovies(query);

    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}/search/movie').replace(
      queryParameters: {
        'api_key': _apiKey,
        'query': query,
        'page': page.toString(),
        'language': 'vi-VN',
      },
    );

    try {
      final res = await client.get(uri);
      if (res.statusCode != 200) return _searchDemoMovies(query);

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>? ?? const [];
      final movies = results
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return movies.isEmpty ? _searchDemoMovies(query) : movies;
    } catch (_) {
      return _searchDemoMovies(query);
    }
  }

  Future<List<MovieModel>> _fetchPage(String path, {int page = 1}) async {
    if (!_hasApiKey) return _demoPage(path);

    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}$path').replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'vi-VN',
        'page': page.toString(),
      },
    );

    try {
      final res = await client.get(uri);
      if (res.statusCode != 200) return _demoPage(path);

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>? ?? const [];
      final movies = results
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return movies.isEmpty ? _demoPage(path) : movies;
    } catch (_) {
      return _demoPage(path);
    }
  }

  List<MovieModel> _demoPage(String path) {
    if (path.contains('now_playing')) return demoMovies.take(10).toList();
    if (path.contains('popular')) return demoMovies.skip(10).take(10).toList();
    if (path.contains('upcoming')) return demoMovies.skip(20).take(10).toList();
    return demoMovies.take(10).toList();
  }

  List<MovieModel> _searchDemoMovies(String query) {
    final normalizedQuery = query.toLowerCase();
    return demoMovies.where((movie) {
      return movie.title.toLowerCase().contains(normalizedQuery) ||
          movie.originalTitle.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}
