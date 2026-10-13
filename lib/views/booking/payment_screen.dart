import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/business/payment/payment_strategy.dart';
import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/booking/payment_success_screen.dart';
import 'package:moviego/views/widgets/primary_button.dart';
import 'package:moviego/views/widgets/summary_row.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final promotionController = TextEditingController();

  @override
  void dispose() {
    promotionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Phương thức thanh toán',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...booking.paymentMethods.map((method) {
              return RadioListTile<PaymentStrategy>(
                value: method,
                groupValue: booking.selectedPayment,
                onChanged: (value) {
                  if (value != null) booking.selectPayment(value);
                },
                title: Text(method.label,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              );
            }),
            const SizedBox(height: 18),
            const Text('Mã giảm giá',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: promotionController,
                        decoration: const InputDecoration(
                            hintText: 'Nhập mã giảm giá'))),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: () =>
                        booking.applyPromo(promotionController.text),
                    child: const Text('Áp dụng')),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Tóm tắt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            SummaryRow(
                label: 'Vé', value: '${booking.seatPrice.toStringAsFixed(0)}đ'),
            SummaryRow(
                label: 'Combo',
                value: '${booking.comboTotal.toStringAsFixed(0)}đ'),
            SummaryRow(
                label: 'Giảm giá',
                value: '-${booking.discount.toStringAsFixed(0)}đ'),
            const Divider(),
            SummaryRow(
                label: 'Tổng cộng',
                value: '${booking.total.toStringAsFixed(0)}đ',
                bold: true),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Xác nhận thanh toán',
              onPressed: booking.isPaying
                  ? null
                  : () async {
                      final bookingModel = await booking.confirmPayment();
                      if (!context.mounted) return;
                      if (bookingModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(booking.paymentError ??
                                'Thanh toán thất bại')));
                        return;
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PaymentSuccessScreen(booking: bookingModel)),
                        (route) => false,
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
