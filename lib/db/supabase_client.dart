import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviego/core/config/app_config.dart';

/// Điểm truy cập Supabase duy nhất của ứng dụng.
/// `Supabase.instance` vốn là singleton của thư viện nên ta chỉ bọc lại.
/// Chỉ các Repository (tầng Data) được dùng [client]; màn hình không gọi trực tiếp.
class DatabaseConfig {
  DatabaseConfig._();

  static bool _ready = false;
  static bool get isReady => _ready;

  static SupabaseClient get client => Supabase.instance.client;

  /// Trả về true nếu kết nối được; false thì app tự chạy bằng dữ liệu mẫu cục bộ.
  static Future<bool> init() async {
    final config = AppConfig();
    if (!config.hasSupabase) return false;
    try {
      await Supabase.initialize(url: config.supabaseUrl, anonKey: config.supabaseAnonKey);
      _ready = true;
    } catch (e) {
      debugPrint('[Supabase] Khởi tạo thất bại, chạy chế độ offline: $e');
    }
    return _ready;
  }
}
