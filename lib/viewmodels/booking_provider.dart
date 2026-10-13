import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:moviego/business/booking/booking_facade.dart';
import 'package:moviego/business/booking/booking_observer.dart';
import 'package:moviego/business/booking/promo_rule.dart';
import 'package:moviego/business/booking/show_slot.dart';
import 'package:moviego/business/payment/payment_methods.dart';
import 'package:moviego/business/payment/payment_strategy.dart';
import 'package:moviego/business/pricing/seat_pricing.dart';
import 'package:moviego/db/mock/mock_cinemas.dart';
import 'package:moviego/db/repositories/booking_repository.dart';
import 'package:moviego/db/repositories/cinema_repository.dart';
import 'package:moviego/db/repositories/in_memory_booking_repository.dart';
import 'package:moviego/models/booking_model.dart';
import 'package:moviego/models/cinema_model.dart';
import 'package:moviego/models/movie_model.dart';

/// ViewModel của luồng đặt vé. Chỉ giữ trạng thái màn hình; nghiệp vụ nằm ở
/// [BookingFacade] và [PricingService], dữ liệu nằm ở các Repository.
class BookingProvider extends ChangeNotifier {
  BookingProvider({
    List<CinemaModel>? cinemas,
    CinemaRepository? cinemaRepository,
    BookingRepository? bookingRepository,
    PricingService? pricing,
    List<PaymentStrategy>? paymentMethods,
    List<PromoRule>? promoRules,
    List<BookingObserver> observers = const [],
  })  : cinemas = cinemas ?? demoCinemas,
        _cinemaRepository = cinemaRepository,
        _pricing = pricing ?? const PricingService(),
        paymentMethods = paymentMethods ?? defaultPaymentMethods,
        _promoRules = promoRules ?? defaultPromoRules {
    _facade = BookingFacade(
      repository: bookingRepository ?? InMemoryBookingRepository(),
      events: _events,
    );
    _selectedPayment = this.paymentMethods.first;
    observers.forEach(_events.addObserver);
  }

  List<CinemaModel> cinemas;
  final CinemaRepository? _cinemaRepository;
  final PricingService _pricing;
  final List<PaymentStrategy> paymentMethods;
  final List<PromoRule> _promoRules;
  final BookingSubject _events = BookingSubject();
  late final BookingFacade _facade;
  late PaymentStrategy _selectedPayment;

  MovieModel? selectedMovie;
  CinemaModel? selectedCinema;
  RoomModel? selectedRoom;
  String selectedDate = 'Hôm nay';
  String selectedTime = '18:30';
  final Set<String> selectedSeats = <String>{};

  /// Ghế đã đặt trong phiên này (cập nhật ngay, không chờ mạng).
  final Set<String> heldSeats = <String>{};

  /// Ghế người khác đã đặt/đang giữ, nhận từ luồng thời gian thực.
  Set<String> remoteTakenSeats = <String>{};
  final Set<String> selectedCombos = <String>{};
  String promoCode = '';
  PromoRule? _appliedPromo;
  bool isPaying = false;
  String? paymentError;
  String? seatError;
  final List<BookingModel> bookings = <BookingModel>[];

  String? _showtimeId;
  StreamSubscription<Set<String>>? _seatSubscription;

  final Map<String, double> comboPrices = {
    'popcorn': 65000,
    'combo2': 95000,
    'drink': 35000,
  };

  PaymentStrategy get selectedPayment => _selectedPayment;

  DateTime get selectedStartsAt => resolveStartsAt(selectedDate, selectedTime);

  double get seatPrice => _pricing.seatTotal(selectedSeats, selectedStartsAt);

  double get comboTotal =>
      selectedCombos.fold<double>(0, (sum, id) => sum + (comboPrices[id] ?? 0));

  double get subtotal => seatPrice + comboTotal;

  /// Giảm giá được tính lại theo giỏ hàng hiện tại nên không bị lệch khi đổi ghế/combo.
  double get discount {
    final promo = _appliedPromo;
    if (promo == null || !promo.isApplicable(subtotal)) return 0;
    return promo.discountFor(subtotal);
  }

  bool get promoApplied => discount > 0;

  double get total => subtotal - discount;

  bool isSeatLocked(String seat) =>
      heldSeats.contains(seat) || remoteTakenSeats.contains(seat);

  void addObserver(BookingObserver observer) => _events.addObserver(observer);

  void removeObserver(BookingObserver observer) => _events.removeObserver(observer);

  Future<void> loadCinemas() async {
    final repo = _cinemaRepository;
    if (repo == null) return;
    try {
      final loaded = await repo.fetchCinemas();
      if (loaded.isEmpty) return;
      cinemas = loaded;
      notifyListeners();
    } catch (_) {
      // Giữ danh sách rạp mẫu khi chưa có dữ liệu hoặc mất mạng.
    }
  }

  Future<void> loadMyBookings() async {
    try {
      final loaded = await _facade.myBookings();
      bookings
        ..clear()
        ..addAll(loaded);
      notifyListeners();
    } catch (_) {
      // Giữ danh sách vé hiện có.
    }
  }

  void selectMovie(MovieModel movie) {
    selectedMovie = movie;
    notifyListeners();
  }

  void selectCinema(CinemaModel cinema) {
    selectedCinema = cinema;
    selectedRoom = cinema.rooms.first;
    notifyListeners();
  }

  void selectPayment(PaymentStrategy method) {
    _selectedPayment = method;
    notifyListeners();
  }

  /// Mở sơ đồ ghế: theo dõi ghế của suất chiếu theo thời gian thực (Observer qua Stream).
  Future<void> openSeatMap() async {
    await closeSeatMap();
    seatError = null;
    try {
      final showtimeId = await _currentShowtimeId();
      _seatSubscription = _facade.watchTakenSeats(showtimeId).listen((taken) {
        remoteTakenSeats = taken;
        selectedSeats.removeAll(taken);
        notifyListeners();
      });
    } on BookingException catch (e) {
      seatError = e.message;
      notifyListeners();
    } catch (_) {
      // Không có kết nối: vẫn chọn ghế được, kiểm tra lại khi giữ ghế.
    }
  }

  Future<void> closeSeatMap() async {
    await _seatSubscription?.cancel();
    _seatSubscription = null;
  }

  /// Giữ tạm các ghế đã chọn (mặc định 10 phút) trước khi sang bước combo/thanh toán.
  Future<bool> holdSelectedSeats() async {
    seatError = null;
    try {
      final showtimeId = await _currentShowtimeId();
      final held = await _facade.holdSeats(showtimeId, selectedSeats);
      if (!held) seatError = 'Có ghế vừa bị người khác chọn, vui lòng chọn lại';
      notifyListeners();
      return held;
    } on BookingException catch (e) {
      seatError = e.message;
    } catch (_) {
      seatError = 'Không giữ được ghế, vui lòng thử lại';
    }
    notifyListeners();
    return false;
  }

  void toggleSeat(String seat) {
    if (isSeatLocked(seat) && !selectedSeats.contains(seat)) return;
    if (selectedSeats.contains(seat)) {
      selectedSeats.remove(seat);
    } else {
      selectedSeats.add(seat);
    }
    notifyListeners();
  }

  void toggleCombo(String id) {
    if (selectedCombos.contains(id)) {
      selectedCombos.remove(id);
    } else {
      selectedCombos.add(id);
    }
    notifyListeners();
  }

  void applyPromo(String code) {
    promoCode = code.trim();
    final rule = _findPromoRule(promoCode);
    _appliedPromo = (rule != null && rule.isApplicable(subtotal)) ? rule : null;
    notifyListeners();
  }

  void resetBooking() {
    selectedSeats.clear();
    selectedCombos.clear();
    promoCode = '';
    _appliedPromo = null;
    _showtimeId = null;
    notifyListeners();
  }

  /// Giao toàn bộ luồng cho [BookingFacade]; ở đây chỉ cập nhật trạng thái màn hình.
  Future<BookingModel?> confirmPayment() async {
    if (isPaying) return null;
    isPaying = true;
    paymentError = null;
    notifyListeners();

    final result = await _facade.bookTicket(BookingRequest(
      movie: selectedMovie ?? MovieModel.empty(),
      cinema: selectedCinema,
      room: selectedRoom,
      dateLabel: selectedDate,
      time: selectedTime,
      startsAt: selectedStartsAt,
      seats: {...selectedSeats},
      combos: {...selectedCombos},
      total: total,
      payment: _selectedPayment,
    ));

    isPaying = false;
    final booking = result.booking;
    if (booking == null) {
      paymentError = result.error;
      notifyListeners();
      return null;
    }

    bookings.insert(0, booking);
    heldSeats.addAll(booking.seats);
    resetBooking();
    return booking;
  }

  /// Đổi trạng thái vé (đã dùng / đã hủy). Giao diện đổi ngay, lưu DB chạy nền.
  void updateStatus(String bookingId, BookingStatus status) {
    final index = bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) return;

    final updated = bookings[index].copyWith(status: status);
    bookings[index] = updated;
    if (status == BookingStatus.cancelled) heldSeats.removeAll(updated.seats);
    notifyListeners();
    _events.notifyObservers(updated);
    unawaited(_facade.updateStatus(bookingId, status).catchError((_) {}));
  }

  Future<String> _currentShowtimeId() async =>
      _showtimeId ??= await _facade.resolveShowtime(
        movie: selectedMovie ?? MovieModel.empty(),
        room: selectedRoom,
        startsAt: selectedStartsAt,
      );

  PromoRule? _findPromoRule(String code) {
    final normalized = code.toUpperCase();
    for (final rule in _promoRules) {
      if (rule.code == normalized) return rule;
    }
    return null;
  }

  @override
  void dispose() {
    _seatSubscription?.cancel();
    super.dispose();
  }
}
