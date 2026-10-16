import 'package:flutter_test/flutter_test.dart';

import 'package:moviego/business/booking/show_slot.dart';

void main() {
  final now = DateTime(2026, 10, 21, 9, 0);

  test('Hôm nay và Ngày mai', () {
    expect(resolveStartsAt('Hôm nay', '18:30', now: now), DateTime(2026, 10, 21, 18, 30));
    expect(resolveStartsAt('Ngày mai', '10:00', now: now), DateTime(2026, 10, 22, 10, 0));
  });

  test('nhãn dd/MM', () {
    expect(resolveStartsAt('24/10', '21:00', now: now), DateTime(2026, 10, 24, 21, 0));
  });

  test('ngày đã qua được hiểu là năm sau', () {
    expect(resolveStartsAt('05/01', '12:30', now: now), DateTime(2027, 1, 5, 12, 30));
  });
}
