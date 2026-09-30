import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../profile/profile_providers.dart';
import '../progress/progress_providers.dart';

/// O'yin tugagandagi natija (FR-4): yulduzcha soni va sarflangan vaqt.
class GameResult {
  const GameResult({required this.gameId, required this.stars, required this.duration});

  final String gameId;

  /// 1..3. Ijobiy mustahkamlash tamoyili: kamida 1 yulduz har doim beriladi.
  final int stars;
  final Duration duration;
}

/// Xatolar soniga qarab yulduzcha: 0-1 xato → 3, 2-4 → 2, ko'proq → 1.
int starsForMistakes(int mistakes) {
  if (mistakes <= 1) return 3;
  if (mistakes <= 4) return 2;
  return 1;
}

/// Natijani saqlaydi (FR-5) va natija ekraniga o'tadi.
void finishGame(BuildContext context, WidgetRef ref, GameResult result) {
  final profile = ref.read(activeProfileProvider);
  if (profile != null) {
    ref.read(progressProvider.notifier).record(profile.id, result);
  }
  context.pushReplacement(AppRoutes.result, extra: result);
}
