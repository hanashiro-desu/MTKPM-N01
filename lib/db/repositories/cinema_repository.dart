import 'package:moviego/db/mock/mock_cinemas.dart';
import 'package:moviego/models/cinema_model.dart';

abstract interface class CinemaRepository {
  Future<List<CinemaModel>> fetchCinemas();
}

/// Dữ liệu rạp cục bộ, dùng khi chạy offline hoặc trong test.
class StaticCinemaRepository implements CinemaRepository {
  const StaticCinemaRepository([this._cinemas = demoCinemas]);

  final List<CinemaModel> _cinemas;

  @override
  Future<List<CinemaModel>> fetchCinemas() async => _cinemas;
}
