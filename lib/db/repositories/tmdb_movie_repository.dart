import 'package:moviego/db/remote/movie_api_service.dart';
import 'package:moviego/db/repositories/movie_repository.dart';
import 'package:moviego/models/movie_model.dart';

class TmdbMovieRepository implements MovieRepository {
  final MovieApiService apiService;

  TmdbMovieRepository({MovieApiService? apiService}) : apiService = apiService ?? MovieApiService();

  @override
  Future<List<MovieModel>> fetchNowPlaying() => apiService.fetchNowPlaying();

  @override
  Future<List<MovieModel>> fetchPopular() => apiService.fetchPopular();

  @override
  Future<List<MovieModel>> fetchUpcoming() => apiService.fetchUpcoming();

  @override
  Future<List<MovieModel>> fetchTopRated() => apiService.fetchTopRated();

  @override
  Future<List<MovieModel>> searchMovies(String query) => apiService.searchMovies(query);
}
