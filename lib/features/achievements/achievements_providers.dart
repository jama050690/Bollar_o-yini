import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import '../games/game_catalog.dart';
import '../profile/profile_providers.dart';
import '../progress/progress_providers.dart';
import '../rewards/rewards_providers.dart';
import '../streak/streak_providers.dart';
import 'achievements_catalog.dart';

/// Faol bolaning medal ko'rsatkichlari (progressdan hisoblanadi).
final medalStatsProvider = Provider<MedalStats>((ref) {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const MedalStats();

  final prefix = '${profile.id}|';
  final progress = {
    for (final entry in ref.watch(progressProvider).entries)
      if (entry.key.startsWith(prefix)) entry.key.substring(prefix.length): entry.value,
  };
  return MedalStats.from(
    progress,
    gamesFor(profile.ageGroup).map((g) => g.id),
    bestStreak: ref.watch(streakProvider).best,
  );
});

/// Faol bolaning ochilgan medallari.
final unlockedMedalsProvider = Provider<List<Medal>>((ref) {
  final stats = ref.watch(medalStatsProvider);
  return [for (final medal in kMedals) if (medal.isUnlocked(stats)) medal];
});

String _awardedKey(String profileId) => 'medals|$profileId';

/// Bonus tangasi berilgan medallar — har medal uchun bonus faqat bir marta.
class AwardedMedalsNotifier extends Notifier<Set<String>> {
  String? _profileId;

  @override
  Set<String> build() {
    final profileId = _profileId = ref.watch(activeProfileIdProvider);
    if (profileId == null) return const {};
    final saved = HiveStorage.settings.get(_awardedKey(profileId)) as List? ?? const [];
    return {...saved.cast<String>()};
  }

  /// Yangi ochilgan medallarni belgilaydi, bonus tanga beradi va ularni qaytaradi.
  List<Medal> claimNew() {
    final profileId = _profileId;
    if (profileId == null) return const [];

    final fresh = [
      for (final medal in ref.read(unlockedMedalsProvider))
        if (!state.contains(medal.id)) medal,
    ];
    if (fresh.isEmpty) return const [];

    state = {...state, for (final medal in fresh) medal.id};
    HiveStorage.settings.put(_awardedKey(profileId), state.toList());
    ref.read(walletProvider.notifier).earn(fresh.length * kMedalBonusCoins);
    return fresh;
  }
}

final awardedMedalsProvider =
    NotifierProvider<AwardedMedalsNotifier, Set<String>>(AwardedMedalsNotifier.new);
