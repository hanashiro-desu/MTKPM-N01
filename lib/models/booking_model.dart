import 'package:intl/intl.dart';

import 'package:moviego/models/movie_model.dart';

enum BookingStatus {
  upcoming('Sắp chiếu'),
  used('Đã sử dụng'),
  cancelled('Đã hủy');

  const BookingStatus(this.label);

  final String label;
}

class BookingModel {
  final String id;
  final String userId;
  final MovieModel movie;
  final String cinemaName;
  final String roomName;
  final String date;
  final String time;
  final List<String> seats;
  final List<String> combos;
  final double total;
  final BookingStatus status;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.movie,
    required this.cinemaName,
    required this.roomName,
    required this.date,
    required this.time,
    required this.seats,
    required this.combos,
    required this.total,
    required this.status,
  });

  /// Dòng `bookings` kèm select lồng:
  /// `*, showtimes(starts_at, movies(*), rooms(name, cinemas(name))), booking_seats(seat_code), booking_combos(combo_id)`
  factory BookingModel.fromRow(Map<String, dynamic> row) {
    final showtime = row['showtimes'] as Map<String, dynamic>;
    final room = showtime['rooms'] as Map<String, dynamic>;
    final cinema = room['cinemas'] as Map<String, dynamic>;
    final startsAt = DateTime.parse(showtime['starts_at'] as String).toLocal();
    return BookingModel(
      id: row['id'].toString(),
      userId: row['user_id'].toString(),
      movie: MovieModel.fromRow(showtime['movies'] as Map<String, dynamic>),
      cinemaName: (cinema['name'] ?? '').toString(),
      roomName: (room['name'] ?? '').toString(),
      date: DateFormat('dd/MM/yyyy').format(startsAt),
      time: DateFormat('HH:mm').format(startsAt),
      seats: (row['booking_seats'] as List<dynamic>? ?? const [])
          .map((e) => (e as Map<String, dynamic>)['seat_code'].toString())
          .toList()
        ..sort(),
      combos: (row['booking_combos'] as List<dynamic>? ?? const [])
          .map((e) => (e as Map<String, dynamic>)['combo_id'].toString())
          .toList(),
      total: ((row['total'] as num?) ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => BookingStatus.upcoming,
      ),
    );
  }

  BookingModel copyWith({BookingStatus? status}) => BookingModel(
        id: id,
        userId: userId,
        movie: movie,
        cinemaName: cinemaName,
        roomName: roomName,
        date: date,
        time: time,
        seats: seats,
        combos: combos,
        total: total,
        status: status ?? this.status,
      );
}
