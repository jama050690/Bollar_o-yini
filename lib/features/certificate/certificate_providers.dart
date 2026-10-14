import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import '../games/game_catalog.dart';
import '../parent_panel/screen_time_providers.dart';
import '../profile/profile_providers.dart';
import '../progress/progress_providers.dart';

/// Faol bolaning sertifikat holati.
class CertificateStatus {
  const CertificateStatus({required this.gamesLeft, required this.totalStars});

  /// Kamida 1 ⭐ olinmagan o'yinlar soni (o'z yosh guruhida).
  final int gamesLeft;

  /// Guruhdagi o'yinlardagi eng yaxshi yulduzlar yig'indisi.
  final int totalStars;

  bool get unlocked => gamesLeft == 0;
}

/// Sertifikat: bolaning guruhidagi har bir o'yinda kamida 1 yulduz.
final certificateProvider = Provider<CertificateStatus>((ref) {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const CertificateStatus(gamesLeft: 1, totalStars: 0);

  final progress = ref.watch(progressProvider);
  var left = 0;
  var stars = 0;
  for (final game in gamesFor(profile.ageGroup)) {
    final best = progress['${profile.id}|${game.id}']?.bestStars ?? 0;
    if (best < 1) left++;
    stars += best;
  }
  return CertificateStatus(gamesLeft: left, totalStars: stars);
});

/// Sertifikat birinchi ochilgan sana ("yyyy-MM-dd"). Keyingi ochilishlarda o'zgarmaydi.
String certificateDay(String profileId, DateTime now) {
  final key = 'certificate|$profileId';
  final saved = HiveStorage.settings.get(key) as String?;
  if (saved != null) return saved;
  final day = dayKey(now);
  HiveStorage.settings.put(key, day);
  return day;
}
