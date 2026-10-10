import 'package:moviego/models/booking_model.dart';

/// Mẫu Observer: bên nhận thông báo khi vé đổi trạng thái.
abstract interface class BookingObserver {
  void update(BookingModel booking);
}

/// Subject giữ danh sách observer. Không cần biết có bao nhiêu / loại observer nào
/// (loose coupling): thêm kênh thông báo mới không phải sửa lớp này.
class BookingSubject {
  final List<BookingObserver> _observers = [];

  void addObserver(BookingObserver observer) {
    if (!_observers.contains(observer)) _observers.add(observer);
  }

  void removeObserver(BookingObserver observer) => _observers.remove(observer);

  void notifyObservers(BookingModel booking) {
    // Sao chép danh sách để observer có thể tự gỡ mình trong lúc được gọi.
    for (final observer in List<BookingObserver>.of(_observers)) {
      observer.update(booking);
    }
  }
}
