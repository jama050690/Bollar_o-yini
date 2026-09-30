import 'dart:ui';

import '../theme/app_theme.dart';
import 'app_strings.dart';

/// Yosh guruhlari va ularga mos modullar (TZ 2-bo'lim, FR-2).
enum AgeGroup {
  a(minAge: 5, maxAge: 7, title: AppStrings.moduleATitle, emoji: '🧸', color: AppColors.moduleA),
  b(minAge: 8, maxAge: 9, title: AppStrings.moduleBTitle, emoji: '🧮', color: AppColors.moduleB),
  c(minAge: 10, maxAge: 12, title: AppStrings.moduleCTitle, emoji: '🌱', color: AppColors.moduleC);

  const AgeGroup({
    required this.minAge,
    required this.maxAge,
    required this.title,
    required this.emoji,
    required this.color,
  });

  final int minAge;
  final int maxAge;
  final String title;
  final String emoji;
  final Color color;

  static const minSupportedAge = 5;
  static const maxSupportedAge = 12;

  /// Yoshga qarab modulni avtomatik tanlaydi: 5-7 → A, 8-9 → B, 10-12 → C.
  static AgeGroup fromAge(int age) {
    if (age <= a.maxAge) return a;
    if (age <= b.maxAge) return b;
    return c;
  }
}
