import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import '../parent_panel/screen_time_providers.dart';
import '../profile/profile_providers.dart';
import '../rewards/rewards_providers.dart';

/// Kunning birinchi o'yini uchun bonus tanga.
const kDailyBonusCoins = 10;

/// Bitta bolaning o'ynagan kunlari.
///
/// Manipulyatsiyasiz: "ketma-ket kunlar" emas, jami kunlar sanaladi. Kun o'tkazib
/// yuborilsa hech narsa yo'qolmaydi — bola ilovaga qaytishga majburlanmaydi.
class Streak {
  const Streak({this.days = 0, this.lastDay});

  /// Jami o'ynagan kunlar soni (faqat oshadi).
  final int days;

  /// Oxirgi o'yin tugatilgan kun ("yyyy-MM-dd"), hali o'ynamagan bo'lsa null.
  final String? lastDay;
}

String _streakKey(String profileId) => 'streak|$profileId';

class StreakNotifier extends Notifier<Streak> {
  String? _profileId;

  @override
  Streak build() {
    final profileId = _profileId = ref.watch(activeProfileIdProvider);
    if (profileId == null) return const Streak();

    final saved = HiveStorage.settings.get(_streakKey(profileId)) as Map?;
    if (saved == null) return const Streak();
    // Eski formatda (`count`/`best` — ketma-ket seriya) `days` yo'q: eng uzun seriya
    // olinadi, shunda avval ochilgan medallar yopilib qolmaydi.
    final oldBest = saved['best'] as int? ?? 0;
    final oldCount = saved['count'] as int? ?? 0;
    return Streak(
      days: saved['days'] as int? ?? (oldBest > oldCount ? oldBest : oldCount),
      lastDay: saved['lastDay'] as String?,
    );
  }

  /// O'yin tugaganda chaqiriladi. Kunning birinchi o'yini bo'lsa kunlar sonini
  /// oshiradi, bonus tanga beradi va yangi sonni qaytaradi; aks holda null.
  int? recordPlay([DateTime? now]) {
    final profileId = _profileId;
    if (profileId == null) return null;

    final today = dayKey(now ?? DateTime.now());
    if (state.lastDay == today) return null;

    final days = state.days + 1;
    HiveStorage.settings.put(_streakKey(profileId), {'days': days, 'lastDay': today});
    state = Streak(days: days, lastDay: today);
    ref.read(walletProvider.notifier).earn(kDailyBonusCoins);
    return days;
  }
}

final streakProvider = NotifierProvider<StreakNotifier, Streak>(StreakNotifier.new);

/// Faol bolaning jami o'ynagan kunlari (bosh ekranda ko'rsatiladi).
final currentStreakProvider = Provider<int>((ref) => ref.watch(streakProvider).days);
