import 'package:moviego/business/payment/payment_strategy.dart';

/// Tiền mặt: thanh toán tại quầy khi nhận vé.
class CodPayment implements PaymentStrategy {
  const CodPayment();

  @override
  String get id => 'cod';

  @override
  String get label => 'Tiền mặt';

  @override
  Future<PaymentResult> pay(double amount) async {
    return PaymentResult.success(
      transactionId: 'COD${DateTime.now().microsecondsSinceEpoch}',
      message: 'Vui lòng thanh toán tại quầy khi nhận vé',
    );
  }
}
