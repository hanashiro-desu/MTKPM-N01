import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:moviego/db/mock/mock_data.dart';
import 'package:moviego/db/remote/movie_api_service.dart';

void main() {
  test('uses demo movies when no environment key is loaded', () async {
    final service = MovieApiService();

    final movies = await service.fetchNowPlaying();

    expect(movies, isNotEmpty);
    expect(movies.first.id, demoMovies.first.id);
  });

  test('uses demo movies when TMDB is unavailable', () async {
    final service = MovieApiService(
      apiKey: 'test-key',
      client: MockClient((_) async => http.Response('{}', 503)),
    );

    final nowPlaying = await service.fetchNowPlaying();
    final searchResults = await service.searchMovies('Dune');

    expect(nowPlaying, isNotEmpty);
    expect(nowPlaying.first.id, demoMovies.first.id);
    expect(searchResults, isNotEmpty);
    expect(searchResults.any((movie) => movie.title.contains('Dune')), isTrue);
  });
}
