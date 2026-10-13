import 'package:flutter/material.dart';

import 'package:moviego/views/auth/otp_verify_screen.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhập email để nhận mã OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            const TextField(
                decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 24),
            PrimaryButton(
                text: 'Gửi mã',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OtpVerifyScreen()))),
          ],
        ),
      ),
    );
  }
}
