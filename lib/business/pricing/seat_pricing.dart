import 'package:moviego/core/constants/app_constants.dart';

/// Mẫu Strategy cho giá vé: mỗi loại ghế là một lớp. Thêm loại ghế mới = thêm 1 lớp,
/// không sửa [PricingService] hay màn hình.
abstract interface class SeatPriceStrategy {
  bool supports(String seatCode);
  double priceFor(String seatCode, DateTime startsAt);
}

class StandardSeatPrice implements SeatPriceStrategy {
  const StandardSeatPrice();

  @override
  bool supports(String seatCode) => true;

  @override
  double priceFor(String seatCode, DateTime startsAt) => AppConstants.seatPrice;
}

/// Ghế VIP: hàng E và F.
class VipSeatPrice implements SeatPriceStrategy {
  const VipSeatPrice();

  static const double price = 120000;
  static const Set<String> rows = {'E', 'F'};

  @override
  bool supports(String seatCode) => seatCode.isNotEmpty && rows.contains(seatCode[0]);

  @override
  double priceFor(String seatCode, DateTime startsAt) => price;
}

/// Chọn strategy đầu tiên hỗ trợ ghế đó (đặt ghế đặc biệt trước, ghế thường cuối).
class PricingService {
  const PricingService([
    this._strategies = const [VipSeatPrice(), StandardSeatPrice()],
  ]);

  final List<SeatPriceStrategy> _strategies;

  double priceOf(String seatCode, DateTime startsAt) => _strategies
      .firstWhere((s) => s.supports(seatCode), orElse: () => const StandardSeatPrice())
      .priceFor(seatCode, startsAt);

  double seatTotal(Iterable<String> seats, DateTime startsAt) =>
      seats.fold<double>(0, (sum, seat) => sum + priceOf(seat, startsAt));
}
