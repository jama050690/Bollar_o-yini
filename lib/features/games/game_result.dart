import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../achievements/achievements_catalog.dart';
import '../achievements/achievements_providers.dart';
import '../profile/profile_providers.dart';
import '../progress/progress_providers.dart';
import '../rewards/rewards_catalog.dart';
import '../rewards/rewards_providers.dart';
import '../streak/streak_providers.dart';

/// O'yin tugagandagi natija (FR-4): yulduzcha soni va sarflangan vaqt.
class GameResult {
  const GameResult({
    required this.gameId,
    required this.stars,
    required this.duration,
    this.newMedals = const [],
    this.streakDays,
  });

  final String gameId;

  /// 1..3. Ijobiy mustahkamlash tamoyili: kamida 1 yulduz har doim beriladi.
  final int stars;
  final Duration duration;

  /// Shu o'yin natijasida ochilgan yangi medallar (natija ekranida ko'rsatiladi).
  final List<Medal> newMedals;

  /// Kunning birinchi o'yini bo'lsa — ketma-ket kunlar soni (bonus tanga berildi).
  /// Bugun allaqachon o'ynagan bo'lsa null.
  final int? streakDays;
}

/// Xatolar soniga qarab yulduzcha: 0-1 xato → 3, 2-4 → 2, ko'proq → 1.
int starsForMistakes(int mistakes) {
  if (mistakes <= 1) return 3;
  if (mistakes <= 4) return 2;
  return 1;
}

/// Natijani saqlaydi (FR-5), tanga, kunlik bonus va yangi medallarni beradi, natija ekraniga o'tadi.
void finishGame(BuildContext context, WidgetRef ref, GameResult result) {
  var shown = result;
  final profile = ref.read(activeProfileProvider);
  if (profile != null) {
    ref.read(progressProvider.notifier).record(profile.id, result);
    ref.read(walletProvider.notifier).earn(coinsForStars(result.stars));
    // Seriya medallardan oldin yangilanadi — "3 kun ketma-ket" shu o'yinda ochilishi uchun.
    final streakDays = ref.read(streakProvider.notifier).recordPlay();
    final medals = ref.read(awardedMedalsProvider.notifier).claimNew();
    shown = GameResult(
      gameId: result.gameId,
      stars: result.stars,
      duration: result.duration,
      newMedals: medals,
      streakDays: streakDays,
    );
  }
  context.pushReplacement(AppRoutes.result, extra: shown);
}
