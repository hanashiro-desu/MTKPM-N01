import 'package:flutter/material.dart';

import 'package:moviego/views/shell/app_shell.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class OtpVerifyScreen extends StatelessWidget {
  const OtpVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhập mã OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            const Row(children: [
              Expanded(
                  child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(labelText: '123456')))
            ]),
            const SizedBox(height: 24),
            PrimaryButton(
                text: 'Xác nhận',
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const AppShell()))),
          ],
        ),
      ),
    );
  }
}
