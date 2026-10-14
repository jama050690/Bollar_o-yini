import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import 'achievements_catalog.dart';
import 'achievements_providers.dart';

/// Yutuqlar javoni: ochilgan medallar rangli, qolganlari kulrang va sharti bilan.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedMedalsProvider).map((m) => m.id).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.achievementsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                AppStrings.medalsCount(unlocked.length, kMedals.length),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final medal in kMedals)
                  MedalCard(medal: medal, unlocked: unlocked.contains(medal.id)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Medal kartasi. Ochilmagan bo'lsa kulrang va ostida sharti yoziladi.
class MedalCard extends StatelessWidget {
  const MedalCard({super.key, required this.medal, required this.unlocked});

  final Medal medal;
  final bool unlocked;

  // Rangli emojini kulrangga aylantiruvchi matritsa.
  static const _greyscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 0.5, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final emoji = Text(medal.emoji, style: const TextStyle(fontSize: 56));

    return Container(
      width: 160,
      // Uzun nom/shart ikki qatorga tushsa, karta pastga cho'ziladi.
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(
          color: unlocked ? const Color(0xFFFFB300) : Colors.black12,
          width: unlocked ? 3 : 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          unlocked ? emoji : ColorFiltered(colorFilter: _greyscale, child: emoji),
          const SizedBox(height: 8),
          Text(
            medal.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: unlocked ? AppColors.text : Colors.black45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unlocked ? AppStrings.medalUnlocked : medal.hint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: unlocked ? AppColors.text : Colors.black45),
          ),
        ],
      ),
    );
  }
}
