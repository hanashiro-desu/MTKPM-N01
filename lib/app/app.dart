import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/business/booking/booking_notifiers.dart';
import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/db/repositories/auth_repository.dart';
import 'package:moviego/db/repositories/booking_repository.dart';
import 'package:moviego/db/repositories/cinema_repository.dart';
import 'package:moviego/db/repositories/fallback_movie_repository.dart';
import 'package:moviego/db/repositories/in_memory_booking_repository.dart';
import 'package:moviego/db/repositories/movie_repository.dart';
import 'package:moviego/db/repositories/supabase_auth_repository.dart';
import 'package:moviego/db/repositories/supabase_booking_repository.dart';
import 'package:moviego/db/repositories/supabase_cinema_repository.dart';
import 'package:moviego/db/repositories/supabase_movie_repository.dart';
import 'package:moviego/db/repositories/tmdb_movie_repository.dart';
import 'package:moviego/db/supabase_client.dart';
import 'package:moviego/viewmodels/auth_provider.dart';
import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/viewmodels/movie_provider.dart';
import 'package:moviego/views/onboarding/splash_screen.dart';

/// Nơi duy nhất quyết định dùng Repository nào (Supabase hay dữ liệu cục bộ).
/// Phần còn lại của app chỉ biết các interface.
class MovieGoApp extends StatelessWidget {
  const MovieGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final online = DatabaseConfig.isReady;

    final MovieRepository movieRepo = online
        ? FallbackMovieRepository(
            primary: SupabaseMovieRepository(),
            fallback: TmdbMovieRepository(),
          )
        : TmdbMovieRepository();
    final CinemaRepository cinemaRepo =
        online ? SupabaseCinemaRepository() : const StaticCinemaRepository();
    final BookingRepository bookingRepo =
        online ? SupabaseBookingRepository() : InMemoryBookingRepository();
    final AuthRepository authRepo = online ? SupabaseAuthRepository() : LocalAuthRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(repository: authRepo, isDemo: !online)),
        ChangeNotifierProvider(create: (_) => MovieProvider(repository: movieRepo)),
        ChangeNotifierProvider(create: (_) => InAppNotifier()),
        // Đăng ký các observer: thêm kênh thông báo mới chỉ cần thêm 1 dòng ở đây.
        ChangeNotifierProvider(
          create: (context) => BookingProvider(
            cinemaRepository: cinemaRepo,
            bookingRepository: bookingRepo,
            observers: [context.read<InAppNotifier>(), EmailNotifier()],
          )..loadCinemas(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MOVIEGO',
        theme: MovieGoTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
