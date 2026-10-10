import 'dart:convert';

import 'package:moviego/core/constants/app_constants.dart';

class MovieModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final int runtime;
  final List<String> genres;
  final List<String> languages;
  final List<String> cast;
  final List<String> directors;
  final String trailerUrl;
  final bool isAdult;
  final bool isPopular;
  final bool isUpcoming;

  const MovieModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.runtime,
    required this.genres,
    required this.languages,
    required this.cast,
    required this.directors,
    required this.trailerUrl,
    this.isAdult = false,
    this.isPopular = false,
    this.isUpcoming = false,
  });

  String get posterUrl => posterPath.isEmpty ? '' : '${AppConstants.tmdbPosterBase}$posterPath';
  String get backdropUrl => backdropPath.isEmpty ? '' : '${AppConstants.tmdbImageBase}$backdropPath';

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : releaseDate;
  String get genresText => genres.isEmpty ? 'Drama' : genres.join(', ');

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final genres = (json['genres'] as List<dynamic>? ?? const [])
        .map((e) => (e is Map ? e['name'] : e).toString())
        .toList();

    final cast = (json['cast'] as List<dynamic>? ?? const [])
        .map((e) => (e is Map ? e['name'] : e).toString())
        .take(6)
        .toList();

    final directors = (json['crew'] as List<dynamic>? ?? const [])
        .where((e) => e is Map && e['job'] == 'Director')
        .map((e) => e['name'].toString())
        .take(3)
        .toList();

    final languages = (json['spoken_languages'] as List<dynamic>? ?? const [])
        .map((e) => (e is Map ? e['english_name'] : e).toString())
        .toList();

    return MovieModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['name'] ?? 'Untitled').toString(),
      originalTitle: (json['original_title'] ?? json['original_name'] ?? '').toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: (json['poster_path'] ?? '').toString(),
      backdropPath: (json['backdrop_path'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? json['first_air_date'] ?? '').toString(),
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      runtime: (json['runtime'] as num?)?.toInt() ?? 120,
      genres: genres,
      languages: languages,
      cast: cast,
      directors: directors,
      trailerUrl: (json['trailer_url'] ?? '').toString(),
      isAdult: json['adult'] == true,
      isPopular: (json['popularity'] as num? ?? 0) > 10,
      isUpcoming: (json['release_date'] ?? '').toString().isNotEmpty,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'original_title': originalTitle,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'release_date': releaseDate,
    'vote_average': voteAverage,
    'vote_count': voteCount,
    'runtime': runtime,
    'genres': genres,
    'languages': languages,
    'cast': cast,
    'crew': directors.map((name) => {'job': 'Director', 'name': name}).toList(),
    'trailer_url': trailerUrl,
  };

  /// Dòng bảng `movies` của Supabase (snake_case) -> model.
  factory MovieModel.fromRow(Map<String, dynamic> row) {
    List<String> strings(dynamic v) =>
        (v as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
    return MovieModel(
      id: (row['id'] as num).toInt(),
      title: (row['title'] ?? '').toString(),
      originalTitle: (row['original_title'] ?? '').toString(),
      overview: (row['overview'] ?? '').toString(),
      posterPath: (row['poster_path'] ?? '').toString(),
      backdropPath: (row['backdrop_path'] ?? '').toString(),
      releaseDate: (row['release_date'] ?? '').toString(),
      voteAverage: ((row['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (row['vote_count'] as num?)?.toInt() ?? 0,
      runtime: (row['runtime'] as num?)?.toInt() ?? 120,
      genres: strings(row['genres']),
      languages: strings(row['languages']),
      cast: strings(row['cast_names']),
      directors: strings(row['directors']),
      trailerUrl: (row['trailer_url'] ?? '').toString(),
      isPopular: row['is_popular'] == true,
      isUpcoming: row['status'] == 'upcoming',
    );
  }

  /// Model -> dòng bảng `movies`. [status]: `now_playing` | `upcoming`.
  Map<String, dynamic> toRow({String status = 'now_playing'}) => {
        'id': id,
        'title': title,
        'original_title': originalTitle,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'release_date': releaseDate.isEmpty ? null : releaseDate,
        'vote_average': voteAverage,
        'vote_count': voteCount,
        'runtime': runtime,
        'genres': genres,
        'languages': languages,
        'cast_names': cast,
        'directors': directors,
        'trailer_url': trailerUrl,
        'status': status,
        'is_popular': isPopular,
      };

  factory MovieModel.empty() => const MovieModel(
    id: 0,
    title: '',
    originalTitle: '',
    overview: '',
    posterPath: '',
    backdropPath: '',
    releaseDate: '',
    voteAverage: 0,
    voteCount: 0,
    runtime: 0,
    genres: [],
    languages: [],
    cast: [],
    directors: [],
    trailerUrl: '',
  );
}

class MovieResponse {
  final int page;
  final List<MovieModel> results;
  final int totalPages;
  final int totalResults;

  const MovieResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['results'] as List<dynamic>? ?? const [])
        .map((result) => MovieModel.fromJson(result as Map<String, dynamic>))
        .toList();

    return MovieResponse(
      page: (json['page'] as num?)?.toInt() ?? 1,
      results: items,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalResults: (json['total_results'] as num?)?.toInt() ?? items.length,
    );
  }
}

class MovieListSection {
  final String title;
  final List<MovieModel> movies;

  const MovieListSection({required this.title, required this.movies});
}

const appMovieSeed = 'moviego';
