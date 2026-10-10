import 'package:moviego/business/booking/booking_observer.dart';
import 'package:moviego/business/payment/checkout_service.dart';
import 'package:moviego/business/payment/payment_strategy.dart';
import 'package:moviego/core/config/app_config.dart';
import 'package:moviego/db/repositories/booking_repository.dart';
import 'package:moviego/models/booking_model.dart';
import 'package:moviego/models/cinema_model.dart';
import 'package:moviego/models/movie_model.dart';

/// Mọi thứ cần để đặt một vé. Provider gom dữ liệu rồi giao cho [BookingFacade].
class BookingRequest {
  const BookingRequest({
    required this.movie,
    required this.cinema,
    required this.room,
    required this.dateLabel,
    required this.time,
    required this.startsAt,
    required this.seats,
    required this.combos,
    required this.total,
    required this.payment,
  });

  final MovieModel movie;
  final CinemaModel? cinema;
  final RoomModel? room;
  final String dateLabel;
  final String time;
  final DateTime startsAt;
  final Set<String> seats;
  final Set<String> combos;
  final double total;
  final PaymentStrategy payment;
}

class BookingResult {
  const BookingResult.success(BookingModel this.booking) : error = null;
  const BookingResult.failure(String this.error) : booking = null;

  final BookingModel? booking;
  final String? error;

  bool get ok => booking != null;
}

/// Mẫu Facade: một cửa vào cho luồng đặt vé
/// kiểm tra ghế -> giữ ghế -> thanh toán (Strategy) -> lưu vé -> thông báo (Observer).
/// Màn hình/Provider không cần biết thứ tự các bước hay Repository nào đứng sau.
class BookingFacade {
  BookingFacade({
    required BookingRepository repository,
    required BookingSubject events,
    Duration? holdDuration,
  })  : _repo = repository,
        _events = events,
        _holdDuration = holdDuration ?? AppConfig().seatHoldDuration;

  final BookingRepository _repo;
  final BookingSubject _events;
  final Duration _holdDuration;

  Future<String> resolveShowtime({
    required MovieModel movie,
    required RoomModel? room,
    required DateTime startsAt,
  }) =>
      _repo.ensureShowtime(movieId: movie.id, roomId: room?.id ?? 'unknown', startsAt: startsAt);

  Stream<Set<String>> watchTakenSeats(String showtimeId) => _repo.watchTakenSeats(showtimeId);

  Future<bool> holdSeats(String showtimeId, Set<String> seats) =>
      _repo.holdSeats(showtimeId, seats, _holdDuration);

  Future<void> releaseSeats(String showtimeId, Set<String> seats) =>
      _repo.releaseSeats(showtimeId, seats);

  Future<List<BookingModel>> myBookings() => _repo.myBookings();

  Future<void> updateStatus(String bookingId, BookingStatus status) =>
      _repo.updateStatus(bookingId, status);

  Future<BookingResult> bookTicket(BookingRequest request) async {
    if (request.seats.isEmpty) {
      return const BookingResult.failure('Vui lòng chọn ít nhất một ghế');
    }

    String? showtimeId;
    try {
      showtimeId = await resolveShowtime(
        movie: request.movie,
        room: request.room,
        startsAt: request.startsAt,
      );

      final held = await holdSeats(showtimeId, request.seats);
      if (!held) {
        return const BookingResult.failure('Ghế vừa có người khác giữ, vui lòng chọn ghế khác');
      }

      final payment = await CheckoutService(request.payment).checkout(request.total);
      if (!payment.success) {
        await releaseSeats(showtimeId, request.seats);
        return BookingResult.failure(payment.message);
      }

      final booking = await _repo.confirm(BookingDraft(
        showtimeId: showtimeId,
        movie: request.movie,
        cinemaName: request.cinema?.name ?? 'Rạp',
        roomName: request.room?.name ?? 'Phòng',
        date: request.dateLabel,
        time: request.time,
        seats: request.seats,
        combos: request.combos,
        total: request.total,
        paymentMethod: request.payment.id,
        transactionId: payment.transactionId,
      ));
      _events.notifyObservers(booking);
      return BookingResult.success(booking);
    } on BookingException catch (e) {
      await _safeRelease(showtimeId, request.seats);
      return BookingResult.failure(e.message);
    } catch (_) {
      await _safeRelease(showtimeId, request.seats);
      return const BookingResult.failure('Không thể hoàn tất đặt vé, vui lòng thử lại');
    }
  }

  Future<void> _safeRelease(String? showtimeId, Set<String> seats) async {
    if (showtimeId == null) return;
    try {
      await releaseSeats(showtimeId, seats);
    } catch (_) {
      // Ghế sẽ tự hết hạn giữ; không để lỗi dọn dẹp che lỗi chính.
    }
  }
}
