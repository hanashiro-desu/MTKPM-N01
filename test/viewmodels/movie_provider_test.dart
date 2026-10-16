import 'package:flutter_test/flutter_test.dart';

import 'package:moviego/db/mock/mock_data.dart';
import 'package:moviego/db/repositories/movie_repository.dart';
import 'package:moviego/models/movie_model.dart';
import 'package:moviego/viewmodels/movie_provider.dart';

/// Provider chỉ phụ thuộc interface MovieRepository nên thay bằng bản giả được.
class FakeMovieRepository implements MovieRepository {
  @override
  Future<List<MovieModel>> fetchNowPlaying() async => demoMovies.take(2).toList();

  @override
  Future<List<MovieModel>> fetchPopular() async => const [];

  @override
  Future<List<MovieModel>> fetchUpcoming() async => const [];

  @override
  Future<List<MovieModel>> fetchTopRated() async => const [];

  @override
  Future<List<MovieModel>> searchMovies(String query) async => demoMovies.where((m) => m.title.contains(query)).toList();
}

void main() {
  test('loadAll dùng repository được tiêm vào', () async {
    final provider = MovieProvider(repository: FakeMovieRepository());

    await provider.loadAll();

    expect(provider.nowPlaying, hasLength(2));
    expect(provider.errorMessage, isNull);
  });

  test('toggleFavorite thêm rồi bỏ yêu thích', () {
    final provider = MovieProvider(repository: FakeMovieRepository());
    final movie = demoMovies.first;

    provider.toggleFavorite(movie);
    expect(provider.favoriteMovies.map((m) => m.id), [movie.id]);

    provider.toggleFavorite(movie);
    expect(provider.favoriteMovies, isEmpty);
    expect(provider.favoriteIds, isEmpty);
  });
}
