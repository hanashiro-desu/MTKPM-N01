import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/booking/seat_screen.dart';

class ShowtimeScreen extends StatefulWidget {
  const ShowtimeScreen({super.key});

  @override
  State<ShowtimeScreen> createState() => _ShowtimeScreenState();
}

class _ShowtimeScreenState extends State<ShowtimeScreen> {
  late final List<String> dates = [
    'Hôm nay',
    'Ngày mai',
    for (final offset in [2, 3])
      DateFormat('dd/MM').format(DateTime.now().add(Duration(days: offset))),
  ];
  final times = ['10:00', '12:30', '15:00', '18:30', '21:00'];
  int selectedDate = 0;

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn suất chiếu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.selectedCinema?.name ?? 'Rạp',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) => ChoiceChip(
                  label: Text(dates[index]),
                  selected: index == selectedDate,
                  onSelected: (_) => setState(() => selectedDate = index),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Suất chiếu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: times
                  .map((time) => ChoiceChip(
                        selected: booking.selectedTime == time,
                        label: Text(time),
                        onSelected: (_) {
                          booking.selectedTime = time;
                          booking.selectedDate = dates[selectedDate];
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SeatScreen()));
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
