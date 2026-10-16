import 'package:flutter_test/flutter_test.dart';

import 'package:moviego/business/booking/booking_notifiers.dart';
import 'package:moviego/business/booking/booking_observer.dart';
import 'package:moviego/business/payment/payment_strategy.dart';
import 'package:moviego/db/mock/mock_data.dart';
import 'package:moviego/models/booking_model.dart';
import 'package:moviego/viewmodels/booking_provider.dart';

class RecordingObserver implements BookingObserver {
  final List<BookingModel> received = [];

  @override
  void update(BookingModel booking) => received.add(booking);
}

class FailingPayment implements PaymentStrategy {
  @override
  String get id => 'fail';

  @override
  String get label => 'Luôn lỗi';

  @override
  Future<PaymentResult> pay(double amount) async => const PaymentResult.failure('Ví không đủ số dư');
}

BookingProvider buildProvider({BookingObserver? observer, List<PaymentStrategy>? methods}) {
  final provider = BookingProvider(
    paymentMethods: methods,
    observers: observer == null ? const [] : [observer],
  );
  provider.selectMovie(demoMovies.first);
  provider.selectCinema(provider.cinemas.first);
  return provider;
}

void main() {
  group('Observer: thông báo khi vé đổi trạng thái', () {
    test('thanh toán thành công tạo vé và báo cho observer đúng 1 lần', () async {
      final observer = RecordingObserver();
      final provider = buildProvider(observer: observer)..toggleSeat('A1')..toggleSeat('A2');

      final booking = await provider.confirmPayment();

      expect(booking, isNotNull);
      expect(booking!.status, BookingStatus.upcoming);
      expect(booking.total, 180000);
      expect(observer.received, [booking]);
      expect(provider.bookings.first, booking);
      expect(provider.heldSeats, containsAll(['A1', 'A2']));
      expect(provider.selectedSeats, isEmpty);
    });

    test('updateStatus(cancelled) nhả ghế và báo cho observer', () async {
      final observer = RecordingObserver();
      final provider = buildProvider(observer: observer)..toggleSeat('B3');
      final booking = (await provider.confirmPayment())!;

      provider.updateStatus(booking.id, BookingStatus.cancelled);

      expect(provider.bookings.first.status, BookingStatus.cancelled);
      expect(provider.heldSeats, isNot(contains('B3')));
      expect(observer.received.map((b) => b.status), [BookingStatus.upcoming, BookingStatus.cancelled]);
    });

    test('observer đã gỡ thì không nhận thông báo nữa', () async {
      final observer = RecordingObserver();
      final provider = buildProvider(observer: observer)..removeObserver(observer)..toggleSeat('C1');

      await provider.confirmPayment();

      expect(observer.received, isEmpty);
    });

    test('InAppNotifier lưu thông báo mới nhất lên đầu', () async {
      final notifier = InAppNotifier();
      final provider = buildProvider(observer: notifier)..toggleSeat('D1');
      final booking = (await provider.confirmPayment())!;

      provider.updateStatus(booking.id, BookingStatus.used);

      expect(notifier.items, hasLength(2));
      expect(notifier.items.first.message, contains('đã được sử dụng'));
    });
  });

  group('Strategy: chọn phương thức thanh toán', () {
    test('thanh toán thất bại thì không tạo vé và không báo observer', () async {
      final observer = RecordingObserver();
      final provider = buildProvider(observer: observer, methods: [FailingPayment()])..toggleSeat('A1');

      final booking = await provider.confirmPayment();

      expect(booking, isNull);
      expect(provider.paymentError, 'Ví không đủ số dư');
      expect(provider.bookings, isEmpty);
      expect(provider.selectedSeats, {'A1'});
      expect(observer.received, isEmpty);
    });

    test('chưa chọn ghế thì không thanh toán được', () async {
      final provider = buildProvider();

      expect(await provider.confirmPayment(), isNull);
      expect(provider.paymentError, isNotNull);
    });

    test('selectPayment đổi strategy đang dùng', () {
      final provider = buildProvider();
      final cod = provider.paymentMethods.last;

      provider.selectPayment(cod);

      expect(provider.selectedPayment, same(cod));
    });
  });

  group('Mã giảm giá', () {
    test('MOVIE10 giảm 10% khi tạm tính từ 100.000đ', () {
      final provider = buildProvider()..toggleSeat('A1')..toggleSeat('A2');

      provider.applyPromo(' movie10 ');

      expect(provider.discount, closeTo(18000, 0.001));
      expect(provider.total, closeTo(162000, 0.001));
    });

    test('mã sai hoặc chưa đủ điều kiện thì không giảm', () {
      final provider = buildProvider()..toggleSeat('A1');

      provider.applyPromo('MOVIE10'); // 90.000đ < 100.000đ
      expect(provider.discount, 0);

      provider.applyPromo('SAI');
      expect(provider.promoApplied, isFalse);
    });
  });
}
