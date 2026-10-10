import 'package:moviego/business/payment/checkout_service.dart';

/// Kết quả của một lần thanh toán.
class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;

  const PaymentResult.success({required this.transactionId, this.message = 'Thanh toán thành công'})
      : success = true;

  const PaymentResult.failure(this.message)
      : success = false,
        transactionId = null;
}

/// Mẫu Strategy: mỗi phương thức thanh toán là một lớp hiện thực interface này.
/// Thêm phương thức mới = thêm 1 lớp, không phải sửa [CheckoutService] hay màn hình.
abstract interface class PaymentStrategy {
  String get id;
  String get label;
  Future<PaymentResult> pay(double amount);
}
