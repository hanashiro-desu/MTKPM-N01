import 'package:flutter/material.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/models/booking_model.dart';
import 'package:moviego/views/shell/app_shell.dart';
import 'package:moviego/views/ticket/ticket_detail_screen.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final BookingModel booking;

  const PaymentSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      color: MovieGoColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle,
                      size: 70, color: MovieGoColors.primary)),
              const SizedBox(height: 22),
              const Text('Đặt vé thành công!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Phim đã được xác nhận và vé điện tử đã được tạo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MovieGoColors.muted)),
              const SizedBox(height: 24),
              PrimaryButton(
                  text: 'Xem vé',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TicketDetailScreen(booking: booking)))),
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const AppShell())),
                  child: const Text('Về trang chủ')),
            ],
          ),
        ),
      ),
    );
  }
}
