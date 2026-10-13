import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/booking/payment_screen.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class ComboScreen extends StatelessWidget {
  const ComboScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final combos = [
      {
        'id': 'popcorn',
        'name': 'Combo Bắp lớn',
        'subtitle': 'Bắp + Nước',
        'price': 65000
      },
      {
        'id': 'combo2',
        'name': 'Combo Double',
        'subtitle': '2 Bắp + 2 Nước',
        'price': 95000
      },
      {'id': 'drink', 'name': 'Nước ngọt', 'subtitle': 'Coca', 'price': 35000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Combo')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: combos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final item = combos[index];
                final selected = booking.selectedCombos.contains(item['id']);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Icon(
                            selected ? Icons.check : Icons.fastfood_rounded,
                            color: MovieGoColors.primary)),
                    title: Text(item['name'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${item['subtitle']} • ${item['price']}đ'),
                    trailing: Switch(
                        value: selected,
                        onChanged: (_) =>
                            booking.toggleCombo(item['id'].toString())),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
                text: 'Tiếp tục • ${booking.total.toStringAsFixed(0)}đ',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaymentScreen()))),
          ),
        ],
      ),
    );
  }
}
