import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/models/booking_model.dart';
import 'package:moviego/views/widgets/summary_row.dart';

class TicketDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const TicketDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết vé')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: MovieGoColors.surface,
                  borderRadius: BorderRadius.circular(22)),
              child: Column(
                children: [
                  Text(booking.movie.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('${booking.cinemaName} • ${booking.roomName}',
                      style: TextStyle(color: MovieGoColors.muted)),
                  const SizedBox(height: 18),
                  QrImageView(
                      data:
                          '${booking.id}|${booking.movie.id}|${booking.seats.join(',')}',
                      size: 180),
                  const SizedBox(height: 16),
                  Text('Ghế: ${booking.seats.join(', ')}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('${booking.date} • ${booking.time}',
                      style: TextStyle(color: MovieGoColors.muted)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SummaryRow(label: 'Mã vé', value: booking.id),
            SummaryRow(
                label: 'Tổng tiền',
                value: '${booking.total.toStringAsFixed(0)}đ'),
          ],
        ),
      ),
    );
  }
}
