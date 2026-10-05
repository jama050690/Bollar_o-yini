import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import '../profile/profile_providers.dart';
import 'parent_settings.dart';

/// Hisoblagich qadami: har shuncha vaqtda faol profilga vaqt qo'shiladi.
const kScreenTimeTick = Duration(seconds: 5);

/// Kun kaliti: "2026-10-05". Har kuni hisob 0 dan boshlanadi.
String dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

const _prefix = 'screenTime|';

/// Joriy kun. Hisoblagich har qadamda yangilaydi — yarim tunda o'zgaradi.
class CurrentDayNotifier extends Notifier<String> {
  @override
  String build() => dayKey(DateTime.now());

  void refresh(DateTime now) {
    final key = dayKey(now);
    if (key != state) state = key;
  }
}

final currentDayProvider = NotifierProvider<CurrentDayNotifier, String>(CurrentDayNotifier.new);

/// Ekran vaqti (soniya). Kalit: "profilId|kun".
/// Hive settings qutisida "screenTime|profilId|kun" ko'rinishida saqlanadi.
class ScreenTimeNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    final box = HiveStorage.settings;
    return {
      for (final key in box.keys.whereType<String>().where((k) => k.startsWith(_prefix)))
        key.substring(_prefix.length): box.get(key) as int,
    };
  }

  void add(String profileId, String day, int seconds) {
    final key = '$profileId|$day';
    final total = (state[key] ?? 0) + seconds;
    HiveStorage.settings.put('$_prefix$key', total);
    state = {...state, key: total};
  }
}

final screenTimeProvider =
    NotifierProvider<ScreenTimeNotifier, Map<String, int>>(ScreenTimeNotifier.new);

/// Profilning bugungi o'yin vaqti (soniya).
final todaySecondsProvider = Provider.family<int, String>((ref, profileId) {
  final day = ref.watch(currentDayProvider);
  return ref.watch(screenTimeProvider)['$profileId|$day'] ?? 0;
});

/// Faol profilning bugungi vaqti tugadimi (FR-7).
final timeUpProvider = Provider<bool>((ref) {
  final settings = ref.watch(parentSettingsProvider);
  final profile = ref.watch(activeProfileProvider);
  if (!settings.hasLimit || profile == null) return false;
  return ref.watch(todaySecondsProvider(profile.id)) >= settings.dailyLimitMinutes * 60;
});

/// Ilova ekranda ochiq turgan paytda faol profilga vaqt qo'shib boradi.
/// Ilova fonda bo'lsa yoki vaqt tugagan bo'lsa, hisoblanmaydi.
final screenTimeTickerProvider = Provider<void>((ref) {
  final timer = Timer.periodic(kScreenTimeTick, (_) {
    final now = DateTime.now();
    ref.read(currentDayProvider.notifier).refresh(now);

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;
    final profile = ref.read(activeProfileProvider);
    if (profile == null || ref.read(timeUpProvider)) return;

    ref.read(screenTimeProvider.notifier).add(profile.id, dayKey(now), kScreenTimeTick.inSeconds);
  });
  ref.onDispose(timer.cancel);
});
