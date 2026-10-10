import 'package:moviego/business/payment/payment_strategy.dart';

/// Thẻ ngân hàng. Hiện là bản mô phỏng, chưa gọi cổng thanh toán thật.
class CardPayment implements PaymentStrategy {
  const CardPayment();

  @override
  String get id => 'card';

  @override
  String get label => 'Thẻ ngân hàng';

  @override
  Future<PaymentResult> pay(double amount) async {
    // TODO(nhom): tích hợp cổng thanh toán thẻ thật.
    return PaymentResult.success(transactionId: 'CARD${DateTime.now().microsecondsSinceEpoch}');
  }
}
