import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../profile/profile.dart';
import '../profile/profile_providers.dart';
import '../progress/progress_providers.dart';
import 'parent_settings.dart';
import 'screen_time_providers.dart';

/// Bitta profil bo'yicha jamlangan hisobot.
class ProfileReport {
  const ProfileReport({
    required this.plays,
    required this.stars,
    required this.totalSeconds,
    required this.favoriteGameIds,
  });

  /// [progress] kalitlari: "profilId|oyinId".
  factory ProfileReport.from(String profileId, Map<String, GameProgress> progress) {
    final prefix = '$profileId|';
    final games = [
      for (final entry in progress.entries)
        if (entry.key.startsWith(prefix)) (id: entry.key.substring(prefix.length), p: entry.value),
    ]..sort((a, b) => b.p.plays.compareTo(a.p.plays));

    return ProfileReport(
      plays: games.fold(0, (sum, g) => sum + g.p.plays),
      stars: games.fold(0, (sum, g) => sum + g.p.bestStars),
      totalSeconds: games.fold(0, (sum, g) => sum + g.p.totalSeconds),
      favoriteGameIds: [
        for (final g in games.take(3))
          if (g.p.plays > 0) g.id,
      ],
    );
  }

  final int plays;

  /// Har bir o'yindagi eng yaxshi natija yulduzlari yig'indisi.
  final int stars;
  final int totalSeconds;

  /// Eng ko'p o'ynalgan (ko'pi bilan 3 ta) o'yinlar.
  final List<String> favoriteGameIds;
}

/// Ota-ona paneli (FR-6, FR-7). Faqat PIN orqali ochiladi (router tekshiradi).
class ParentPanelScreen extends ConsumerWidget {
  const ParentPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(parentSettingsProvider);
    final profiles = ref.watch(profilesProvider);

    // Paneldan har doim bosh menyu orqali chiqiladi: vaqt tugagan bo'lsa,
    // router bolani "vaqt tugadi" ekraniga yo'naltiradi.
    void close() => context.go(AppRoutes.home);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.parentPanelTitle),
          leading: CloseButton(onPressed: close),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: AppStrings.dailyLimitTitle,
                children: [
                  const Text(AppStrings.dailyLimitHint, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final minutes in kDailyLimitOptions)
                        ChoiceChip(
                          label: Text(
                            minutes == 0
                                ? AppStrings.limitOff
                                : AppStrings.minutesShort(minutes),
                          ),
                          labelStyle: const TextStyle(fontSize: 20, color: AppColors.text),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          selected: settings.dailyLimitMinutes == minutes,
                          onSelected: (_) => ref
                              .read(parentSettingsProvider.notifier)
                              .setDailyLimit(minutes),
                        ),
                    ],
                  ),
                ],
              ),
              _Section(
                title: AppStrings.reportTitle,
                children: [
                  if (profiles.isEmpty)
                    const Text(AppStrings.reportEmpty, style: TextStyle(fontSize: 18))
                  else
                    for (final profile in profiles) _ProfileReportCard(profile: profile),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () => context.push(AppRoutes.parentPinChange),
                  icon: const Icon(Icons.lock_reset),
                  label: const Text(AppStrings.pinChange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileReportCard extends ConsumerWidget {
  const _ProfileReportCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySeconds = ref.watch(todaySecondsProvider(profile.id));
    final report = ProfileReport.from(profile.id, ref.watch(progressProvider));
    const style = TextStyle(fontSize: 16, color: AppColors.text);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: profile.ageGroup.color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppSizes.radius / 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profile.avatar, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(AppStrings.todayTime(todaySeconds ~/ 60), style: style),
                Text(AppStrings.totalPlays(report.plays), style: style),
                Text(AppStrings.totalStars(report.stars), style: style),
                Text(AppStrings.totalTime(report.totalSeconds ~/ 60), style: style),
                if (report.favoriteGameIds.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(AppStrings.favoriteGames, style: style),
                  for (final id in report.favoriteGameIds)
                    if (gameById(id) case final game?)
                      Text('${game.emoji} ${game.title}', style: style),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
