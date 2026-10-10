import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviego/db/repositories/booking_repository.dart';
import 'package:moviego/db/supabase_client.dart';
import 'package:moviego/models/booking_model.dart';

/// Hiện thực [BookingRepository] bằng Supabase. Các thao tác cần tính nguyên tử
/// (giữ ghế, xác nhận vé) chạy bằng hàm SQL (RPC) trong `supabase/schema.sql`.
class SupabaseBookingRepository implements BookingRepository {
  SupabaseBookingRepository({SupabaseClient? client}) : _db = client ?? DatabaseConfig.client;

  static const String _bookingSelect =
      '*, showtimes(starts_at, movies(*), rooms(name, cinemas(name))), '
      'booking_seats(seat_code), booking_combos(combo_id)';

  final SupabaseClient _db;

  String? get _userId => _db.auth.currentUser?.id;

  @override
  Future<String> ensureShowtime({
    required int movieId,
    required String roomId,
    required DateTime startsAt,
  }) =>
      _guard(() async {
        final id = await _db.rpc('ensure_showtime', params: {
          'p_movie': movieId,
          'p_room': roomId,
          'p_starts': startsAt.toUtc().toIso8601String(),
        });
        return id as String;
      });

  @override
  Future<Set<String>> takenSeats(String showtimeId) => _guard(() async {
        final rows = await _db
            .from('booking_seats')
            .select('seat_code, state, held_until, user_id')
            .eq('showtime_id', showtimeId);
        return _blocking(rows);
      });

  @override
  Stream<Set<String>> watchTakenSeats(String showtimeId) => _db
      .from('booking_seats')
      .stream(primaryKey: ['id'])
      .eq('showtime_id', showtimeId)
      .map(_blocking);

  @override
  Future<bool> holdSeats(String showtimeId, Set<String> seats, Duration holdFor) =>
      _guard(() async {
        final ok = await _db.rpc('hold_seats', params: {
          'p_showtime': showtimeId,
          'p_seats': seats.toList(),
          'p_minutes': holdFor.inMinutes,
        });
        return ok == true;
      });

  @override
  Future<void> releaseSeats(String showtimeId, Set<String> seats) => _guard(() async {
        await _db.rpc('release_seats', params: {
          'p_showtime': showtimeId,
          'p_seats': seats.toList(),
        });
      });

  @override
  Future<BookingModel> confirm(BookingDraft draft) => _guard(() async {
        final id = await _db.rpc('confirm_booking', params: {
          'p_showtime': draft.showtimeId,
          'p_seats': draft.seats.toList(),
          'p_combos': {for (final combo in draft.combos) combo: 1},
          'p_total': draft.total,
          'p_method': draft.paymentMethod,
          'p_txn': draft.transactionId,
        });
        return draft.toBooking(id: id as String, userId: _userId ?? '');
      });

  @override
  Future<List<BookingModel>> myBookings() => _guard(() async {
        if (_userId == null) return <BookingModel>[];
        final rows = await _db
            .from('bookings')
            .select(_bookingSelect)
            .eq('user_id', _userId!)
            .order('created_at', ascending: false);
        return rows.map((r) => BookingModel.fromRow(r as Map<String, dynamic>)).toList();
      });

  @override
  Future<void> updateStatus(String bookingId, BookingStatus status) => _guard(() async {
        await _db.rpc('set_booking_status', params: {
          'p_id': bookingId,
          'p_status': status.name,
        });
      });

  /// Ghế đã đặt, hoặc đang bị người khác giữ và chưa hết hạn.
  Set<String> _blocking(List<dynamic> rows) {
    final now = DateTime.now().toUtc();
    final me = _userId;
    final taken = <String>{};
    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final blocks = row['state'] == 'booked' ||
          (row['user_id'] != me && _stillHeld(row['held_until'], now));
      if (blocks) taken.add(row['seat_code'].toString());
    }
    return taken;
  }

  bool _stillHeld(dynamic heldUntil, DateTime now) {
    final until = DateTime.tryParse('$heldUntil');
    return until != null && until.isAfter(now);
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw BookingException(_friendly(e.message));
    }
  }

  String _friendly(String message) {
    if (message.contains('not authenticated')) return 'Vui lòng đăng nhập để đặt vé';
    if (message.contains('seats not held')) return 'Ghế đã hết thời gian giữ, vui lòng chọn lại';
    if (message.contains('permission')) return 'Bạn không có quyền thực hiện thao tác này';
    return 'Không thể kết nối cơ sở dữ liệu, vui lòng thử lại';
  }
}
