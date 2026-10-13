import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/booking/combo_screen.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class SeatScreen extends StatefulWidget {
  const SeatScreen({super.key});

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  final rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  late final BookingProvider _booking;

  @override
  void initState() {
    super.initState();
    _booking = context.read<BookingProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _booking.openSeatMap());
  }

  @override
  void dispose() {
    _booking.closeSeatMap();
    super.dispose();
  }

  Future<void> _continue() async {
    final held = await _booking.holdSelectedSeats();
    if (!mounted) return;
    if (!held) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_booking.seatError ?? 'Không giữ được ghế')));
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ComboScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn ghế')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 260,
              height: 36,
              decoration: BoxDecoration(
                  color: MovieGoColors.surface,
                  borderRadius: BorderRadius.circular(18)),
              child: const Center(
                  child: Text('MÀN HÌNH',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: MovieGoColors.primary))),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (_, rowIndex) {
                  final row = rows[rowIndex];
                  return Row(
                    children: [
                      SizedBox(
                          width: 24,
                          child: Text(row,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800))),
                      ...List.generate(8, (index) {
                        final seat = '$row${index + 1}';
                        final selected = booking.selectedSeats.contains(seat);
                        final locked = booking.isSeatLocked(seat);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: InkWell(
                              onTap: locked
                                  ? null
                                  : () => booking.toggleSeat(seat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 30,
                                decoration: BoxDecoration(
                                  color: locked
                                      ? MovieGoColors.muted
                                          .withValues(alpha: 0.35)
                                      : (selected
                                          ? MovieGoColors.primary
                                          : Colors.white),
                                  border: Border.all(
                                      color: selected
                                          ? MovieGoColors.primary
                                          : MovieGoColors.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                    child: Text(seat.substring(1),
                                        style: TextStyle(
                                            color: selected
                                                ? Colors.white
                                                : MovieGoColors.text,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700))),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('Hàng A-D: 90.000đ · Hàng E-F (VIP): 120.000đ',
                style: TextStyle(color: MovieGoColors.muted, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${booking.selectedSeats.length} ghế đã chọn',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('${booking.seatPrice.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: 'Tiếp tục',
              onPressed: booking.selectedSeats.isEmpty ? null : _continue,
            ),
          ],
        ),
      ),
    );
  }
}
