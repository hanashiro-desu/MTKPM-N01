import 'package:flutter/foundation.dart';

import 'package:moviego/business/booking/booking_observer.dart';
import 'package:moviego/models/booking_model.dart';

String describeBookingEvent(BookingModel booking) => switch (booking.status) {
      BookingStatus.upcoming =>
        'Đặt vé thành công: ${booking.movie.title} • ${booking.date} ${booking.time} • Ghế ${booking.seats.join(', ')}',
      BookingStatus.used => 'Vé ${booking.id} đã được sử dụng.',
      BookingStatus.cancelled => 'Vé ${booking.id} đã được hủy.',
    };

class AppNotification {
  final String bookingId;
  final String message;
  final DateTime createdAt;

  const AppNotification({
    required this.bookingId,
    required this.message,
    required this.createdAt,
  });
}

/// Observer: lưu thông báo trong ứng dụng (màn hình Thông báo sẽ đọc danh sách này).
class InAppNotifier extends ChangeNotifier implements BookingObserver {
  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);

  @override
  void update(BookingModel booking) {
    _items.insert(
      0,
      AppNotification(
        bookingId: booking.id,
        message: describeBookingEvent(booking),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}

/// Observer: gửi email xác nhận. Hiện chỉ mô phỏng bằng log, chưa gửi email thật.
class EmailNotifier implements BookingObserver {
  final void Function(String message) _send;

  EmailNotifier({void Function(String message)? sender})
      : _send = sender ?? ((String message) => debugPrint('[EMAIL] $message'));

  @override
  void update(BookingModel booking) => _send(describeBookingEvent(booking));
}
