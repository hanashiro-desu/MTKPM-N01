import 'package:flutter_test/flutter_test.dart';

import 'package:moviego/business/pricing/seat_pricing.dart';

void main() {
  final startsAt = DateTime(2026, 10, 22, 18, 30);
  const pricing = PricingService();

  test('ghế thường hàng A-D giá 90.000đ', () {
    expect(pricing.priceOf('A1', startsAt), 90000);
    expect(pricing.priceOf('D8', startsAt), 90000);
  });

  test('ghế VIP hàng E-F giá 120.000đ', () {
    expect(pricing.priceOf('E3', startsAt), 120000);
    expect(pricing.priceOf('F8', startsAt), 120000);
  });

  test('seatTotal cộng đúng theo từng loại ghế', () {
    expect(pricing.seatTotal({'A1', 'E1'}, startsAt), 210000);
  });

  test('thêm loại ghế mới chỉ cần thêm một strategy', () {
    final custom = PricingService([_CoupleSeat(), const StandardSeatPrice()]);
    expect(custom.priceOf('Z1', startsAt), 200000);
    expect(custom.priceOf('A1', startsAt), 90000);
  });
}

class _CoupleSeat implements SeatPriceStrategy {
  @override
  bool supports(String seatCode) => seatCode.startsWith('Z');

  @override
  double priceFor(String seatCode, DateTime startsAt) => 200000;
}
