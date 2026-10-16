import 'package:flutter_test/flutter_test.dart';

import 'package:moviego/business/payment/card_payment.dart';
import 'package:moviego/business/payment/checkout_service.dart';
import 'package:moviego/business/payment/cod_payment.dart';
import 'package:moviego/business/payment/ewallet_payment.dart';
import 'package:moviego/business/payment/payment_strategy.dart';

/// Test double: ghi lại số tiền được gọi và trả về kết quả định sẵn.
class FakePayment implements PaymentStrategy {
  FakePayment({this.result, this.error});

  final PaymentResult? result;
  final Object? error;
  final List<double> calls = [];

  @override
  String get id => 'fake';

  @override
  String get label => 'Fake';

  @override
  Future<PaymentResult> pay(double amount) async {
    calls.add(amount);
    if (error != null) throw error!;
    return result ?? const PaymentResult.success(transactionId: 'FAKE1');
  }
}

void main() {
  group('CheckoutService (Context của Strategy)', () {
    test('chuyển số tiền cho strategy được tiêm vào', () async {
      final fake = FakePayment();

      final result = await CheckoutService(fake).checkout(180000);

      expect(result.success, isTrue);
      expect(fake.calls, [180000]);
    });

    test('từ chối số tiền <= 0 và không gọi strategy', () async {
      final fake = FakePayment();

      final result = await CheckoutService(fake).checkout(0);

      expect(result.success, isFalse);
      expect(fake.calls, isEmpty);
    });

    test('strategy ném lỗi thì trả về failure thay vì làm app lỗi', () async {
      final result = await CheckoutService(FakePayment(error: StateError('mạng lỗi'))).checkout(90000);

      expect(result.success, isFalse);
    });
  });

  group('Các strategy cụ thể', () {
    test('mỗi phương thức hiện thực cùng một interface và có mã giao dịch riêng', () async {
      final methods = <PaymentStrategy, String>{
        const EWalletPayment(): 'EW',
        const CardPayment(): 'CARD',
        const CodPayment(): 'COD',
      };

      for (final entry in methods.entries) {
        final result = await CheckoutService(entry.key).checkout(90000);
        expect(result.success, isTrue, reason: entry.key.label);
        expect(result.transactionId, startsWith(entry.value));
      }
    });
  });
}
