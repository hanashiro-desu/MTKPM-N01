import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviego/db/mock/mock_cinemas.dart';
import 'package:moviego/db/mock/mock_data.dart';
import 'package:moviego/db/supabase_client.dart';

/// CHỈ DÙNG KHI PHÁT TRIỂN. Ứng dụng dùng khóa công khai (anon) nên KHÔNG thể tạo bảng;
/// bảng phải tạo bằng `supabase/schema.sql`. Seeder này chỉ nạp dữ liệu mẫu vào các bảng
/// còn trống, và cần chạy `supabase/dev_seed_policies.sql` trước (xóa file policy đó khi xong).
class DatabaseSeeder {
  DatabaseSeeder({SupabaseClient? client}) : _db = client ?? DatabaseConfig.client;

  final SupabaseClient _db;

  Future<void> seedIfEmpty() async {
    try {
      await _seedMovies();
      await _seedCinemas();
      debugPrint('[Seeder] Kiểm tra/nạp dữ liệu mẫu xong');
    } on PostgrestException catch (e) {
      debugPrint('[Seeder] Bỏ qua: ${e.message} (đã chạy schema.sql và dev_seed_policies.sql chưa?)');
    }
  }

  Future<bool> _isEmpty(String table) async =>
      (await _db.from(table).select('id').limit(1)).isEmpty;

  Future<void> _seedMovies() async {
    if (!await _isEmpty('movies')) return;
    final byId = {for (final m in demoMovies) m.id: m};
    final rows = byId.values
        .map((m) => m.toRow(status: m.releaseDate.compareTo('2026-10-21') > 0 ? 'upcoming' : 'now_playing'))
        .toList();
    await _db.from('movies').insert(rows);
  }

  Future<void> _seedCinemas() async {
    if (!await _isEmpty('cinemas')) return;
    await _db.from('cinemas').insert(demoCinemas.map((c) => c.toRow()).toList());
    await _db.from('rooms').insert([
      for (final cinema in demoCinemas) ...cinema.rooms.map((r) => r.toRow(cinema.id)),
    ]);
  }
}
