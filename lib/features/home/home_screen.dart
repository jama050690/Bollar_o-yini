import 'package:flutter/material.dart';

/// Vaqtinchalik bosh ekran — ilova ishga tushishini tekshirish uchun.
/// Haqiqiy bosh menyu (modullar, profil) keyingi qadamlarda yoziladi.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🤖', style: TextStyle(fontSize: 96)),
              const SizedBox(height: 16),
              Text("Aqlli Do'stlar", style: textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Xush kelibsiz!', style: textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
