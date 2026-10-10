import 'package:moviego/models/movie_model.dart';

/// Provider chỉ phụ thuộc interface này, không phụ thuộc lớp TMDB cụ thể.
abstract interface class MovieRepository {
  Future<List<MovieModel>> fetchNowPlaying();
  Future<List<MovieModel>> fetchPopular();
  Future<List<MovieModel>> fetchUpcoming();
  Future<List<MovieModel>> fetchTopRated();
  Future<List<MovieModel>> searchMovies(String query);
}
