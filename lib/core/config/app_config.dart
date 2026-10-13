import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Mẫu Singleton: một bộ cấu hình dùng chung cho cả ứng dụng
/// (khóa Supabase, thời gian giữ ghế, bật/tắt nạp dữ liệu mẫu).
/// Các lớp nghiệp vụ không đọc singleton này trực tiếp mà nhận giá trị qua constructor.
class AppConfig {
  AppConfig._internal();
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;

  final Duration seatHoldDuration = const Duration(minutes: 10);

  String get supabaseUrl => _env('SUPABASE_URL');
  String get supabaseAnonKey => _env('SUPABASE_ANON_KEY');
  bool get seedDemoData => _env('SEED_DEMO_DATA').toLowerCase() == 'true';

  bool get hasSupabase =>
      supabaseUrl.startsWith('https://') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR_PROJECT_REF');

  String _env(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }
}
