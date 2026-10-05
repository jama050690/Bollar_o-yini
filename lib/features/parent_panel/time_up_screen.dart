import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';

/// Kunlik vaqt tugaganda chiqadigan muloyim ekran (FR-7, TZ 4.4).
/// Jazolovchi so'zlar yo'q. Ota-ona PIN orqali panelga kirib vaqtni o'zgartirishi mumkin.
class TimeUpScreen extends StatelessWidget {
  const TimeUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 120)),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.timeUpTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.timeUpBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => context.push(AppRoutes.parentPin),
                child: const Text(AppStrings.parentEntry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
