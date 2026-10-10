import 'dart:async';

import 'package:moviego/db/repositories/booking_repository.dart';
import 'package:moviego/models/booking_model.dart';

/// Bản trong bộ nhớ của [BookingRepository]: dùng khi chưa cấu hình Supabase và trong test.
class InMemoryBookingRepository implements BookingRepository {
  InMemoryBookingRepository({String userId = 'demo-user'}) : _userId = userId;

  final String _userId;
  final Map<String, Set<String>> _booked = {};
  final Map<String, Set<String>> _held = {};
  final List<BookingModel> _bookings = [];
  final Map<String, Map<String, Set<String>>> _bookingSeats = {};
  final _changes = StreamController<String>.broadcast();

  @override
  Future<String> ensureShowtime({
    required int movieId,
    required String roomId,
    required DateTime startsAt,
  }) async =>
      '$movieId|$roomId|${startsAt.toIso8601String()}';

  @override
  Future<Set<String>> takenSeats(String showtimeId) async => {...?_booked[showtimeId]};

  @override
  Stream<Set<String>> watchTakenSeats(String showtimeId) async* {
    yield await takenSeats(showtimeId);
    await for (final changed in _changes.stream) {
      if (changed == showtimeId) yield await takenSeats(showtimeId);
    }
  }

  @override
  Future<bool> holdSeats(String showtimeId, Set<String> seats, Duration holdFor) async {
    if ((_booked[showtimeId] ?? const <String>{}).any(seats.contains)) return false;
    _held.putIfAbsent(showtimeId, () => <String>{}).addAll(seats);
    return true;
  }

  @override
  Future<void> releaseSeats(String showtimeId, Set<String> seats) async {
    _held[showtimeId]?.removeAll(seats);
  }

  @override
  Future<BookingModel> confirm(BookingDraft draft) async {
    final booking = draft.toBooking(
      id: 'BK${DateTime.now().microsecondsSinceEpoch}',
      userId: _userId,
    );
    _booked.putIfAbsent(draft.showtimeId, () => <String>{}).addAll(draft.seats);
    _held[draft.showtimeId]?.removeAll(draft.seats);
    _bookings.insert(0, booking);
    _bookingSeats[booking.id] = {draft.showtimeId: {...draft.seats}};
    _changes.add(draft.showtimeId);
    return booking;
  }

  @override
  Future<List<BookingModel>> myBookings() async => List.unmodifiable(_bookings);

  @override
  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;
    _bookings[index] = _bookings[index].copyWith(status: status);
    if (status != BookingStatus.cancelled) return;
    _bookingSeats[bookingId]?.forEach((showtimeId, seats) {
      _booked[showtimeId]?.removeAll(seats);
      _changes.add(showtimeId);
    });
  }
}
