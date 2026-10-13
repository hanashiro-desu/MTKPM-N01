import 'package:flutter/foundation.dart';

import 'package:moviego/db/repositories/movie_repository.dart';
import 'package:moviego/db/repositories/tmdb_movie_repository.dart';
import 'package:moviego/models/movie_model.dart';

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repo;

  MovieProvider({MovieRepository? repository}) : _repo = repository ?? TmdbMovieRepository();

  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;

  List<MovieModel> nowPlaying = [];
  List<MovieModel> popular = [];
  List<MovieModel> upcoming = [];
  List<MovieModel> topRated = [];
  List<MovieModel> searchResults = [];
  List<MovieModel> favoriteMovies = [];
  final Set<int> favoriteIds = <int>{};

  Future<void> loadAll() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.fetchNowPlaying(),
        _repo.fetchPopular(),
        _repo.fetchUpcoming(),
        _repo.fetchTopRated(),
      ]);

      nowPlaying = results[0];
      popular = results[1];
      upcoming = results[2];
      topRated = results[3];

      final base = <MovieModel>[];
      base.addAll(nowPlaying);
      base.addAll(popular);
      base.addAll(upcoming);
      base.addAll(topRated);
      final byId = <int, MovieModel>{};
      for (final movie in base) {
        byId[movie.id] = movie;
      }
      final all = byId.values.toList();
      favoriteMovies = all.where((movie) => favoriteIds.contains(movie.id)).toList();
    } catch (e) {
      errorMessage = 'Không thể tải dữ liệu phim. Vui lòng thử lại.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    try {
      searchResults = await _repo.searchMovies(q);
    } catch (_) {
      searchResults = [];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void toggleFavorite(MovieModel movie) {
    if (favoriteIds.remove(movie.id)) {
      favoriteMovies = favoriteMovies.where((item) => item.id != movie.id).toList();
    } else {
      favoriteIds.add(movie.id);
      favoriteMovies = [...favoriteMovies, movie];
    }
    notifyListeners();
  }
}
