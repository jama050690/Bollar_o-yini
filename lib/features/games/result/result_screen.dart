import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/confetti_overlay.dart';
import '../../../shared/widgets/mascot.dart';
import '../../../shared/widgets/stars_row.dart';
import '../../achievements/achievements_catalog.dart';
import '../../rewards/rewards_catalog.dart';
import '../../streak/streak_providers.dart';
import '../game_catalog.dart';
import '../game_result.dart';

/// Natija ekrani (FR-4): yulduzchalar va sarflangan vaqt.
/// Faqat rag'batlantiruvchi xabarlar — jazolash yo'q.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final GameResult result;

  String get _message => switch (result.stars) {
        3 => AppStrings.result3,
        2 => AppStrings.result2,
        _ => AppStrings.result1,
      };

  List<String> get _praise => switch (result.stars) {
        3 => AppStrings.mascotPraise3,
        2 => AppStrings.mascotPraise2,
        _ => AppStrings.mascotPraise1,
      };

  @override
  Widget build(BuildContext context) {
    final game = gameById(result.gameId);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(game?.emoji ?? '🤖', style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 16),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.3, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: StarsRow(stars: result.stars, size: 72),
                    ),
                    const SizedBox(height: 12),
                    // Topilgan tangalar (sovg'alar do'koni uchun).
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutBack,
                      builder: (context, t, child) => Opacity(
                        opacity: t.clamp(0, 1),
                        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
                      ),
                      child: Text(
                        AppStrings.coinsEarned(coinsForStars(result.stars)),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ),
                    if (result.streakDays case final days?) ...[
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.streakBonus(days, kDailyBonusCoins),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                    if (result.newMedals.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _NewMedals(medals: result.newMedals),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.duration(result.duration),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Mascot(messages: _praise, size: 56),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.pushReplacement(AppRoutes.game(result.gameId)),
                      icon: const Icon(Icons.replay_rounded, size: 32),
                      label: const Text(AppStrings.playAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(260, 72),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.home_rounded, size: 32),
                      label: const Text(AppStrings.toHome, style: TextStyle(fontSize: 24)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(260, 72),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // G'alaba konfettisi: yulduz qancha ko'p bo'lsa, shuncha ko'p.
          Positioned.fill(child: ConfettiOverlay(count: kConfettiPerStar * result.stars)),
        ],
      ),
    );
  }
}

/// Har bir yulduz uchun konfetti bo'lakchalari soni.
const kConfettiPerStar = 25;

/// Yangi ochilgan medallar va ular uchun bonus tangalar.
class _NewMedals extends StatelessWidget {
  const _NewMedals({required this.medals});

  final List<Medal> medals;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: const Color(0xFFFFB300), width: 3),
        ),
        child: Column(
          children: [
            Text(AppStrings.newMedal, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final medal in medals)
              Text(
                '${medal.emoji} ${medal.title}  ${AppStrings.coinsEarned(kMedalBonusCoins)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
