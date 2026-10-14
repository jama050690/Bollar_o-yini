import '../../core/constants/app_strings.dart';
import '../progress/progress_providers.dart';

/// Har bir yangi medal uchun bonus tanga.
const kMedalBonusCoins = 20;

/// Medallarni hisoblash uchun bitta bolaning umumiy ko'rsatkichlari.
class MedalStats {
  const MedalStats({
    this.totalPlays = 0,
    this.distinctGames = 0,
    this.threeStarGames = 0,
    this.bestStarsSum = 0,
    this.moduleComplete = false,
    this.bestStreak = 0,
  });

  /// [progress] — o'yin id → progress (faqat shu bolaniki).
  /// [moduleGameIds] — bolaning yosh moduldagi barcha o'yinlar.
  /// [bestStreak] — eng uzun kunlik seriya.
  factory MedalStats.from(
    Map<String, GameProgress> progress,
    Iterable<String> moduleGameIds, {
    int bestStreak = 0,
  }) {
    final played = {
      for (final entry in progress.entries)
        if (entry.value.plays > 0) entry.key,
    };
    return MedalStats(
      totalPlays: progress.values.fold(0, (sum, p) => sum + p.plays),
      distinctGames: played.length,
      threeStarGames: progress.values.where((p) => p.bestStars >= 3).length,
      bestStarsSum: progress.values.fold(0, (sum, p) => sum + p.bestStars),
      moduleComplete: moduleGameIds.isNotEmpty && moduleGameIds.every(played.contains),
      bestStreak: bestStreak,
    );
  }

  final int totalPlays;
  final int distinctGames;
  final int threeStarGames;

  /// Har o'yindagi eng yaxshi yulduzlar yig'indisi (modulda ko'pi bilan 10 × 3 = 30).
  final int bestStarsSum;
  final bool moduleComplete;

  /// Eng uzun "ketma-ket kunlar" seriyasi.
  final int bestStreak;
}

class Medal {
  const Medal({
    required this.id,
    required this.emoji,
    required this.title,
    required this.hint,
    required this.isUnlocked,
  });

  final String id;
  final String emoji;
  final String title;

  /// Ochilish sharti (javonda ko'rsatiladi).
  final String hint;
  final bool Function(MedalStats stats) isUnlocked;
}

final List<Medal> kMedals = [
  Medal(
    id: 'first_win',
    emoji: '🥇',
    title: AppStrings.medalFirstWin,
    hint: AppStrings.medalFirstWinHint,
    isUnlocked: (s) => s.totalPlays >= 1,
  ),
  Medal(
    id: 'player',
    emoji: '🎮',
    title: AppStrings.medalPlayer,
    hint: AppStrings.medalPlayerHint,
    isUnlocked: (s) => s.totalPlays >= 10,
  ),
  Medal(
    id: 'champion',
    emoji: '🏃',
    title: AppStrings.medalChampion,
    hint: AppStrings.medalChampionHint,
    isUnlocked: (s) => s.totalPlays >= 50,
  ),
  Medal(
    id: 'master',
    emoji: '⭐',
    title: AppStrings.medalMaster,
    hint: AppStrings.medalMasterHint,
    isUnlocked: (s) => s.threeStarGames >= 1,
  ),
  Medal(
    id: 'star5',
    emoji: '🌟',
    title: AppStrings.medalStar5,
    hint: AppStrings.medalStar5Hint,
    isUnlocked: (s) => s.threeStarGames >= 5,
  ),
  Medal(
    id: 'explorer',
    emoji: '🧭',
    title: AppStrings.medalExplorer,
    hint: AppStrings.medalExplorerHint,
    isUnlocked: (s) => s.distinctGames >= 5,
  ),
  Medal(
    id: 'traveler',
    emoji: '🗺️',
    title: AppStrings.medalTraveler,
    hint: AppStrings.medalTravelerHint,
    isUnlocked: (s) => s.moduleComplete,
  ),
  Medal(
    id: 'collector',
    emoji: '💯',
    title: AppStrings.medalCollector,
    hint: AppStrings.medalCollectorHint,
    isUnlocked: (s) => s.bestStarsSum >= 25,
  ),
  Medal(
    id: 'streak3',
    emoji: '🔥',
    title: AppStrings.medalStreak3,
    hint: AppStrings.medalStreak3Hint,
    isUnlocked: (s) => s.bestStreak >= 3,
  ),
  Medal(
    id: 'streak7',
    emoji: '☄️',
    title: AppStrings.medalStreak7,
    hint: AppStrings.medalStreak7Hint,
    isUnlocked: (s) => s.bestStreak >= 7,
  ),
];

Medal? medalById(String id) {
  for (final medal in kMedals) {
    if (medal.id == id) return medal;
  }
  return null;
}
