import 'package:moviego/models/booking_model.dart';
import 'package:moviego/models/movie_model.dart';

/// Lỗi nghiệp vụ đã được dịch sang tiếng Việt để hiển thị thẳng cho người dùng.
class BookingException implements Exception {
  const BookingException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Dữ liệu cần để ghi một vé sau khi thanh toán thành công.
class BookingDraft {
  const BookingDraft({
    required this.showtimeId,
    required this.movie,
    required this.cinemaName,
    required this.roomName,
    required this.date,
    required this.time,
    required this.seats,
    required this.combos,
    required this.total,
    required this.paymentMethod,
    required this.transactionId,
  });

  final String showtimeId;
  final MovieModel movie;
  final String cinemaName;
  final String roomName;
  final String date;
  final String time;
  final Set<String> seats;
  final Set<String> combos;
  final double total;
  final String paymentMethod;
  final String? transactionId;

  BookingModel toBooking({required String id, required String userId}) => BookingModel(
        id: id,
        userId: userId,
        movie: movie,
        cinemaName: cinemaName,
        roomName: roomName,
        date: date,
        time: time,
        seats: seats.toList()..sort(),
        combos: combos.toList(),
        total: total,
        status: BookingStatus.upcoming,
      );
}

/// Tầng Data cho suất chiếu, ghế và vé. Tầng nghiệp vụ chỉ phụ thuộc interface này
/// nên có thể thay Supabase bằng bản trong bộ nhớ (offline, test) mà không sửa nghiệp vụ.
abstract interface class BookingRepository {
  /// Tìm hoặc tạo suất chiếu theo (phim, phòng, giờ), trả về id suất chiếu.
  Future<String> ensureShowtime({
    required int movieId,
    required String roomId,
    required DateTime startsAt,
  });

  /// Ghế không còn chọn được: đã đặt, hoặc đang được người KHÁC giữ.
  Future<Set<String>> takenSeats(String showtimeId);

  /// Luồng cập nhật ghế theo thời gian thực (Observer qua Stream).
  Stream<Set<String>> watchTakenSeats(String showtimeId);

  /// Giữ ghế tạm thời. Trả về false nếu có ít nhất một ghế đã bị người khác lấy.
  Future<bool> holdSeats(String showtimeId, Set<String> seats, Duration holdFor);

  Future<void> releaseSeats(String showtimeId, Set<String> seats);

  /// Ghi vé, chuyển ghế từ "đang giữ" sang "đã đặt". Trả về vé đã lưu.
  Future<BookingModel> confirm(BookingDraft draft);

  Future<List<BookingModel>> myBookings();

  Future<void> updateStatus(String bookingId, BookingStatus status);
}
