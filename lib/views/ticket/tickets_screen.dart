import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/ticket/ticket_detail_screen.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Vé của tôi')),
      body: bookingProvider.bookings.isEmpty
          ? const Center(child: Text('Chưa có vé nào'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookingProvider.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final booking = bookingProvider.bookings[index];
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailScreen(booking: booking))),
                    leading: const CircleAvatar(
                        child: Icon(Icons.confirmation_number_rounded)),
                    title: Text(booking.movie.title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                        '${booking.date} • ${booking.time} • ${booking.seats.join(', ')}'),
                    trailing: Text(booking.status.label.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11, color: MovieGoColors.primary)),
                  ),
                );
              },
            ),
    );
  }
}
