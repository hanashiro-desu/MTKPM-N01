import 'package:moviego/business/payment/payment_strategy.dart';

/// Ví điện tử (Momo). Hiện là bản mô phỏng, chưa gọi API cổng thanh toán thật.
class EWalletPayment implements PaymentStrategy {
  const EWalletPayment();

  @override
  String get id => 'ewallet';

  @override
  String get label => 'Momo';

  @override
  Future<PaymentResult> pay(double amount) async {
    // TODO(nhom): gọi API ví điện tử thật khi có backend thanh toán.
    return PaymentResult.success(transactionId: 'EW${DateTime.now().microsecondsSinceEpoch}');
  }
}
