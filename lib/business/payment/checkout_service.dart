import 'package:moviego/business/payment/payment_strategy.dart';

/// Context của mẫu Strategy: chỉ giữ tham chiếu tới [PaymentStrategy],
/// không biết chi tiết từng cách thanh toán. Strategy được tiêm qua constructor
/// (dependency injection thủ công) nên dễ kiểm thử bằng test double.
class CheckoutService {
  final PaymentStrategy _paymentStrategy;

  CheckoutService(this._paymentStrategy);

  Future<PaymentResult> checkout(double amount) async {
    if (amount <= 0) {
      return const PaymentResult.failure('Số tiền thanh toán không hợp lệ');
    }
    try {
      return await _paymentStrategy.pay(amount);
    } catch (_) {
      return const PaymentResult.failure('Thanh toán thất bại, vui lòng thử lại');
    }
  }
}
