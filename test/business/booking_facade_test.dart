import 'package:flutter_test/flutter_test.dart';

import 'package:moviego/business/booking/booking_facade.dart';
import 'package:moviego/business/booking/booking_observer.dart';
import 'package:moviego/business/payment/ewallet_payment.dart';
import 'package:moviego/business/payment/payment_strategy.dart';
import 'package:moviego/db/mock/mock_cinemas.dart';
import 'package:moviego/db/mock/mock_data.dart';
import 'package:moviego/db/repositories/in_memory_booking_repository.dart';
import 'package:moviego/models/booking_model.dart';

class _Recorder implements BookingObserver {
  final List<BookingModel> received = [];

  @override
  void update(BookingModel booking) => received.add(booking);
}

class _Declined implements PaymentStrategy {
  @override
  String get id => 'declined';

  @override
  String get label => 'Từ chối';

  @override
  Future<PaymentResult> pay(double amount) async => const PaymentResult.failure('Thẻ bị từ chối');
}

BookingRequest request(Set<String> seats, {PaymentStrategy? payment}) => BookingRequest(
      movie: demoMovies.first,
      cinema: demoCinemas.first,
      room: demoCinemas.first.rooms.first,
      dateLabel: 'Hôm nay',
      time: '18:30',
      startsAt: DateTime(2026, 10, 22, 18, 30),
      seats: seats,
      combos: const {},
      total: 90000.0 * seats.length,
      payment: payment ?? const EWalletPayment(),
    );

void main() {
  late InMemoryBookingRepository repo;
  late _Recorder observer;
  late BookingFacade facade;

  setUp(() {
    repo = InMemoryBookingRepository();
    observer = _Recorder();
    final events = BookingSubject()..addObserver(observer);
    facade = BookingFacade(repository: repo, events: events);
  });

  test('đặt vé thành công: lưu vé, đánh dấu ghế đã đặt, báo observer 1 lần', () async {
    final result = await facade.bookTicket(request({'A1', 'A2'}));

    expect(result.ok, isTrue);
    expect(observer.received, [result.booking]);
    final showtime = await facade.resolveShowtime(
      movie: demoMovies.first,
      room: demoCinemas.first.rooms.first,
      startsAt: DateTime(2026, 10, 22, 18, 30),
    );
    expect(await repo.takenSeats(showtime), {'A1', 'A2'});
  });

  test('thanh toán thất bại: nhả ghế, không lưu vé, không báo observer', () async {
    final result = await facade.bookTicket(request({'B1'}, payment: _Declined()));

    expect(result.ok, isFalse);
    expect(result.error, 'Thẻ bị từ chối');
    expect(await repo.myBookings(), isEmpty);
    expect(observer.received, isEmpty);
  });

  test('ghế đã đặt thì lần đặt thứ hai bị từ chối', () async {
    await facade.bookTicket(request({'C1'}));

    final second = await facade.bookTicket(request({'C1', 'C2'}));

    expect(second.ok, isFalse);
    expect(observer.received, hasLength(1));
  });

  test('chưa chọn ghế thì không đặt được', () async {
    final result = await facade.bookTicket(request({}));

    expect(result.ok, isFalse);
  });

  test('hủy vé trả ghế về trạng thái trống', () async {
    final booked = (await facade.bookTicket(request({'D1'}))).booking!;

    await facade.updateStatus(booked.id, BookingStatus.cancelled);

    final again = await facade.bookTicket(request({'D1'}));
    expect(again.ok, isTrue);
  });
}
