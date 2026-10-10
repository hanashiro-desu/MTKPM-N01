import 'package:moviego/db/repositories/movie_repository.dart';
import 'package:moviego/models/movie_model.dart';

/// Ưu tiên nguồn chính (Supabase); lỗi mạng hoặc chưa có dữ liệu thì dùng nguồn dự phòng (TMDB/mock).
/// Provider vẫn chỉ biết [MovieRepository], không biết có hai nguồn phía sau.
class FallbackMovieRepository implements MovieRepository {
  FallbackMovieRepository({required this.primary, required this.fallback});

  final MovieRepository primary;
  final MovieRepository fallback;

  @override
  Future<List<MovieModel>> fetchNowPlaying() => _first(primary.fetchNowPlaying, fallback.fetchNowPlaying);

  @override
  Future<List<MovieModel>> fetchPopular() => _first(primary.fetchPopular, fallback.fetchPopular);

  @override
  Future<List<MovieModel>> fetchUpcoming() => _first(primary.fetchUpcoming, fallback.fetchUpcoming);

  @override
  Future<List<MovieModel>> fetchTopRated() => _first(primary.fetchTopRated, fallback.fetchTopRated);

  @override
  Future<List<MovieModel>> searchMovies(String query) =>
      _first(() => primary.searchMovies(query), () => fallback.searchMovies(query));

  Future<List<MovieModel>> _first(
    Future<List<MovieModel>> Function() main,
    Future<List<MovieModel>> Function() backup,
  ) async {
    try {
      final data = await main();
      if (data.isNotEmpty) return data;
    } catch (_) {
      // Rơi xuống nguồn dự phòng.
    }
    return backup();
  }
}
