import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:moviego/app/app.dart';
import 'package:moviego/core/config/app_config.dart';
import 'package:moviego/db/database_seeder.dart';
import 'package:moviego/db/supabase_client.dart';

export 'package:moviego/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Không có .env: app dùng dữ liệu mẫu cục bộ.
  }

  final connected = await DatabaseConfig.init();
  if (connected && AppConfig().seedDemoData) {
    await DatabaseSeeder().seedIfEmpty();
  }
  runApp(const MovieGoApp());
}
