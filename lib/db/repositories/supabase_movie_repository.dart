import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviego/db/repositories/movie_repository.dart';
import 'package:moviego/db/supabase_client.dart';
import 'package:moviego/models/movie_model.dart';

/// Hiện thực [MovieRepository] bằng bảng `movies` trên Supabase.
class SupabaseMovieRepository implements MovieRepository {
  SupabaseMovieRepository({SupabaseClient? client}) : _db = client ?? DatabaseConfig.client;

  static const int _pageSize = 20;
  final SupabaseClient _db;

  @override
  Future<List<MovieModel>> fetchNowPlaying() =>
      _byStatus('now_playing', orderBy: 'release_date');

  @override
  Future<List<MovieModel>> fetchUpcoming() => _byStatus('upcoming', orderBy: 'release_date');

  @override
  Future<List<MovieModel>> fetchPopular() => _query(orderBy: 'vote_count');

  @override
  Future<List<MovieModel>> fetchTopRated() => _query(orderBy: 'vote_average');

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final keyword = query.trim().replaceAll(RegExp(r'[%,()]'), ' ');
    if (keyword.isEmpty) return const [];
    final rows = await _db
        .from('movies')
        .select()
        .or('title.ilike.%$keyword%,original_title.ilike.%$keyword%')
        .limit(_pageSize);
    return _map(rows);
  }

  Future<List<MovieModel>> _byStatus(String status, {required String orderBy}) =>
      _query(status: status, orderBy: orderBy);

  Future<List<MovieModel>> _query({String? status, required String orderBy}) async {
    var filter = _db.from('movies').select();
    if (status != null) filter = filter.eq('status', status);
    final rows = await filter.order(orderBy, ascending: false).limit(_pageSize);
    return _map(rows);
  }

  List<MovieModel> _map(List<dynamic> rows) =>
      rows.map((r) => MovieModel.fromRow(r as Map<String, dynamic>)).toList();
}
