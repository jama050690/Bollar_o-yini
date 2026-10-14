import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/age_group.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/choice_card.dart';
import '../../shared/widgets/stars_row.dart';
import '../achievements/achievements_catalog.dart';
import '../achievements/achievements_providers.dart';
import '../games/game_catalog.dart';
import '../profile/profile.dart';
import '../profile/profile_providers.dart';
import '../progress/progress_providers.dart';
import '../rewards/rewards_catalog.dart';
import '../rewards/rewards_providers.dart';
import '../streak/streak_providers.dart';

/// Bosh menyu: bolaning yoshiga mos modul ochiq, qolganlari
/// "qulflangan, lekin ko'rinadi" holatda (TZ 3-bo'lim, FR-2).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return const Scaffold();

    // Bolaning o'z moduli birinchi ko'rsatiladi.
    final groups = [
      profile.ageGroup,
      ...AgeGroup.values.where((g) => g != profile.ageGroup),
    ];

    final wallet = ref.watch(walletProvider);
    final background = backgroundById(wallet.backgroundId);
    final streak = ref.watch(currentStreakProvider);

    return Scaffold(
      body: DecoratedBox(
        // Sovg'alar do'konida tanlangan fon.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: background.colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(profile: profile),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _CoinsButton(coins: wallet.coins)),
                  const SizedBox(width: 12),
                  if (streak > 0) ...[
                    _StreakBadge(days: streak),
                    const SizedBox(width: 12),
                  ],
                  _MedalsButton(unlocked: ref.watch(unlockedMedalsProvider).length),
                ],
              ),
              const SizedBox(height: 16),
              for (final group in groups)
                _ModuleSection(group: group, unlocked: group == profile.ageGroup),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tangalar balansi va sovg'alar do'koniga kirish.
class _CoinsButton extends StatelessWidget {
  const _CoinsButton({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.push(AppRoutes.rewards),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFE082),
        foregroundColor: AppColors.text,
        minimumSize: const Size.fromHeight(AppSizes.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: Row(
        children: [
          Text(AppStrings.coins(coins)),
          const Spacer(),
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('${AppStrings.rewardsTitle} 🎁'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatarni bosib profilni almashtirish mumkin.
        GestureDetector(
          onTap: () => context.push(AppRoutes.profiles),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: profile.ageGroup.color,
            child: Text(profile.avatar, style: const TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(width: 16),
        // Ism uzun bo'lsa kesilmaydi — matn sig'adigan qilib kichrayadi.
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.hello(profile.name),
              style: Theme.of(context).textTheme.headlineLarge,
              maxLines: 1,
            ),
          ),
        ),
        // FR-6: ota-ona paneli (PIN bilan himoyalangan).
        IconButton(
          tooltip: AppStrings.parentPanelTitle,
          constraints: BoxConstraints.tight(const Size.square(AppSizes.minTapTarget)),
          onPressed: () => context.push(AppRoutes.parentPin),
          icon: const Text('🔒', style: TextStyle(fontSize: 32)),
        ),
      ],
    );
  }
}

/// Necha kun ketma-ket o'ynagani.
class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Text(
        AppStrings.streakDays(days),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Ochilgan medallar soni va yutuqlar javoniga kirish.
class _MedalsButton extends StatelessWidget {
  const _MedalsButton({required this.unlocked});

  final int unlocked;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.push(AppRoutes.achievements),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFF8E1),
        foregroundColor: AppColors.text,
        minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(AppStrings.medalsCount(unlocked, kMedals.length)),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({required this.group, required this.unlocked});

  final AgeGroup group;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final games = gamesFor(group);

    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: group.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.title, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        unlocked
                            ? AppStrings.ageRange(group.minAge, group.maxAge)
                            : AppStrings.lockedFor(group.minAge, group.maxAge),
                        style: const TextStyle(fontSize: 16, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (unlocked) ...[
              const SizedBox(height: 16),
              if (games.isEmpty)
                const Text(AppStrings.comingSoon, style: TextStyle(fontSize: 20))
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [for (final game in games) _GameCard(game: game)],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GameCard extends ConsumerWidget {
  const _GameCard({required this.game});

  final GameInfo game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(gameProgressProvider(game.id));

    return ChoiceCard(
      emoji: game.emoji,
      label: game.title,
      color: Colors.white,
      size: 140,
      footer: StarsRow(stars: progress.bestStars),
      onTap: () => context.push(AppRoutes.game(game.id)),
    );
  }
}
