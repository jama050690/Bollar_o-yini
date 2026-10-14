import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import '../parent_panel/screen_time_providers.dart';
import '../profile/profile_providers.dart';
import '../rewards/rewards_providers.dart';

/// Kunning birinchi o'yini uchun bonus tanga.
const kDailyBonusCoins = 10;

/// Bitta bolaning kunlik seriyasi: necha kun ketma-ket o'ynagan.
class Streak {
  const Streak({this.count = 0, this.lastDay, this.best = 0});

  /// Oxirgi o'ynagan kungacha ketma-ket kunlar soni.
  final int count;

  /// Oxirgi o'yin tugatilgan kun ("yyyy-MM-dd"), hali o'ynamagan bo'lsa null.
  final String? lastDay;

  /// Eng uzun seriya — medallar shunga qarab ochiladi (seriya uzilsa ham saqlanadi).
  final int best;

  /// Bugun ko'rsatiladigan seriya: bugun yoki kecha o'ynagan bo'lsa davom etadi,
  /// aks holda uzilgan (0).
  int currentAt(DateTime now) =>
      lastDay == dayKey(now) || lastDay == dayKey(_yesterday(now)) ? count : 0;
}

DateTime _yesterday(DateTime now) => DateTime(now.year, now.month, now.day - 1);

String _streakKey(String profileId) => 'streak|$profileId';

class StreakNotifier extends Notifier<Streak> {
  String? _profileId;

  @override
  Streak build() {
    final profileId = _profileId = ref.watch(activeProfileIdProvider);
    if (profileId == null) return const Streak();

    final saved = HiveStorage.settings.get(_streakKey(profileId)) as Map?;
    if (saved == null) return const Streak();
    return Streak(
      count: saved['count'] as int? ?? 0,
      lastDay: saved['lastDay'] as String?,
      best: saved['best'] as int? ?? 0,
    );
  }

  /// O'yin tugaganda chaqiriladi. Kunning birinchi o'yini bo'lsa seriyani
  /// yangilaydi, bonus tanga beradi va yangi seriyani qaytaradi; aks holda null.
  int? recordPlay([DateTime? now]) {
    final profileId = _profileId;
    if (profileId == null) return null;

    now ??= DateTime.now();
    final today = dayKey(now);
    if (state.lastDay == today) return null;

    final count = state.lastDay == dayKey(_yesterday(now)) ? state.count + 1 : 1;
    final best = count > state.best ? count : state.best;
    HiveStorage.settings.put(_streakKey(profileId), {
      'count': count,
      'lastDay': today,
      'best': best,
    });
    state = Streak(count: count, lastDay: today, best: best);
    ref.read(walletProvider.notifier).earn(kDailyBonusCoins);
    return count;
  }
}

final streakProvider = NotifierProvider<StreakNotifier, Streak>(StreakNotifier.new);

/// Faol bolaning bugungi seriyasi (bosh ekranda ko'rsatiladi).
final currentStreakProvider = Provider<int>((ref) {
  ref.watch(currentDayProvider); // Yarim tunda qayta hisoblanadi.
  return ref.watch(streakProvider).currentAt(DateTime.now());
});
