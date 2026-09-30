import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import '../games/game_result.dart';
import '../profile/profile_providers.dart';

/// Bitta profilning bitta o'yindagi progressi.
class GameProgress {
  const GameProgress({this.bestStars = 0, this.plays = 0, this.totalSeconds = 0});

  final int bestStars;
  final int plays;
  final int totalSeconds;

  Map<String, int> toMap() =>
      {'bestStars': bestStars, 'plays': plays, 'totalSeconds': totalSeconds};

  factory GameProgress.fromMap(Map<dynamic, dynamic> map) => GameProgress(
        bestStars: map['bestStars'] as int? ?? 0,
        plays: map['plays'] as int? ?? 0,
        totalSeconds: map['totalSeconds'] as int? ?? 0,
      );
}

String _key(String profileId, String gameId) => '$profileId|$gameId';

/// Barcha profillarning progressi. Kalit: "profilId|oyinId".
class ProgressNotifier extends Notifier<Map<String, GameProgress>> {
  @override
  Map<String, GameProgress> build() {
    final box = HiveStorage.progress;
    return {
      for (final key in box.keys) key as String: GameProgress.fromMap(box.get(key)!),
    };
  }

  void record(String profileId, GameResult result) {
    final key = _key(profileId, result.gameId);
    final old = state[key] ?? const GameProgress();
    final updated = GameProgress(
      bestStars: result.stars > old.bestStars ? result.stars : old.bestStars,
      plays: old.plays + 1,
      totalSeconds: old.totalSeconds + result.duration.inSeconds,
    );
    HiveStorage.progress.put(key, updated.toMap());
    state = {...state, key: updated};
  }
}

final progressProvider =
    NotifierProvider<ProgressNotifier, Map<String, GameProgress>>(ProgressNotifier.new);

/// Faol profilning berilgan o'yindagi progressi.
final gameProgressProvider = Provider.family<GameProgress, String>((ref, gameId) {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const GameProgress();
  return ref.watch(progressProvider)[_key(profile.id, gameId)] ?? const GameProgress();
});
