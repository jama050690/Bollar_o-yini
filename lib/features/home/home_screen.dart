import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/age_group.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/choice_card.dart';
import '../../shared/widgets/stars_row.dart';
import '../games/game_catalog.dart';
import '../profile/profile.dart';
import '../profile/profile_providers.dart';
import '../progress/progress_providers.dart';

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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(profile: profile),
            const SizedBox(height: 16),
            for (final group in groups)
              _ModuleSection(group: group, unlocked: group == profile.ageGroup),
          ],
        ),
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
        Expanded(
          child: Text(
            AppStrings.hello(profile.name),
            style: Theme.of(context).textTheme.headlineLarge,
            overflow: TextOverflow.ellipsis,
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
