import 'package:moviego/business/payment/card_payment.dart';
import 'package:moviego/business/payment/cod_payment.dart';
import 'package:moviego/business/payment/ewallet_payment.dart';
import 'package:moviego/business/payment/payment_strategy.dart';

/// Danh sách phương thức thanh toán mặc định của ứng dụng.
const List<PaymentStrategy> defaultPaymentMethods = [
  EWalletPayment(),
  CardPayment(),
  CodPayment(),
];
