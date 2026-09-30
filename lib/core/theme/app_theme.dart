import 'package:flutter/material.dart';

/// Ranglar TZ 5-bo'lim bo'yicha: yorqin, lekin ko'zni charchatmaydigan.
abstract final class AppColors {
  static const primary = Color(0xFF4FC3F7);
  static const background = Color(0xFFFFFBF2);
  static const text = Color(0xFF37474F);

  // Modul palitralari: A — pastel, B — yorqin, C — energiya beruvchi
  static const moduleA = Color(0xFFFFB5C2);
  static const moduleB = Color(0xFFFFCA28);
  static const moduleC = Color(0xFF66BB6A);
}

/// Bolalar uchun o'lchamlar (NFR-1): tugmalar katta bo'lishi kerak.
abstract final class AppSizes {
  static const minTapTarget = 64.0;
  static const radius = 24.0;
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // TODO(1-bosqich): "Baloo 2" shriftini assets/fonts ga qo'shish (offline uchun).
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
        titleLarge: TextStyle(fontSize: 24, color: AppColors.text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
        ),
      ),
    );
  }
}
