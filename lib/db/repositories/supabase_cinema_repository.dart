import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviego/db/repositories/cinema_repository.dart';
import 'package:moviego/db/supabase_client.dart';
import 'package:moviego/models/cinema_model.dart';

class SupabaseCinemaRepository implements CinemaRepository {
  SupabaseCinemaRepository({SupabaseClient? client}) : _db = client ?? DatabaseConfig.client;

  final SupabaseClient _db;

  @override
  Future<List<CinemaModel>> fetchCinemas() async {
    final rows = await _db.from('cinemas').select('*, rooms(*)').order('name');
    return rows.map((r) => CinemaModel.fromRow(r as Map<String, dynamic>)).toList();
  }
}
