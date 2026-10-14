import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/core/router/app_router.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/games/game_catalog.dart';
import 'package:aqlli_dostlar/features/games/game_result.dart';
import 'package:aqlli_dostlar/features/parent_panel/parent_settings.dart';
import 'package:aqlli_dostlar/features/parent_panel/screen_time_providers.dart';
import 'package:aqlli_dostlar/shared/widgets/choice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

/// App Store / Play Market skrinshotlari (faqat simulyatorda ishga tushiriladi):
///
/// `flutter drive --driver=test_driver/integration_test.dart`
/// `--target=integration_test/screenshots_test.dart -d SIMULATOR_ID`
///
/// Diqqat: qurilmadagi ilova ma'lumotlarini o'chirib, demo ma'lumot yozadi.
const _profileId = 'demo';

Future<void> _seedDemo() async {
  await HiveStorage.profiles.clear();
  await HiveStorage.progress.clear();
  await HiveStorage.settings.clear();

  await HiveStorage.profiles.put(_profileId, {
    'id': _profileId,
    'name': 'Laylo',
    'age': 6,
    'avatar': '🦊',
    'createdAt': 0,
  });
  final settings = HiveStorage.settings;
  await settings.put('onboardingDone', true);
  await settings.put('activeProfileId', _profileId);
  await settings.put('coins|$_profileId', 240);

  // Barcha A-modul o'yinlari o'ynalgan — sertifikat ochiq.
  final games = gamesFor(AgeGroup.a);
  for (var i = 0; i < games.length; i++) {
    await HiveStorage.progress.put('$_profileId|${games[i].id}', {
      'bestStars': i % 4 == 1 ? 2 : 3,
      'plays': 2 + i % 3,
      'totalSeconds': 180 + 40 * i,
    });
  }

  // Haftalik grafik va seriya uchun oxirgi 7 kun.
  final now = DateTime.now();
  const minutes = [12, 18, 9, 22, 15, 20, 14];
  for (var i = 0; i < 7; i++) {
    final day = DateTime(now.year, now.month, now.day - 6 + i);
    await settings.put('screenTime|$_profileId|${dayKey(day)}', minutes[i] * 60);
  }
  await settings.put('streak|$_profileId', {'count': 7, 'lastDay': dayKey(now), 'best': 7});
}

/// Cheksiz animatsiyalar bor, shuning uchun pumpAndSettle o'rniga real vaqt kutiladi.
Future<void> _wait(WidgetTester tester, [int ms = 1500]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('do\'kon skrinshotlari', (tester) async {
    await Hive.initFlutter();
    await HiveStorage.openBoxes();
    await _seedDemo();

    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await binding.convertFlutterSurfaceToImage();
    await _wait(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    final router = container.read(appRouterProvider);

    Future<void> shot(String name) async {
      await _wait(tester);
      await binding.takeScreenshot(name);
    }

    await shot('01_bosh_menyu');

    router.go(AppRoutes.game('memory_match'));
    await _wait(tester);
    final levels = find.byType(ChoiceCard);
    if (levels.evaluate().isNotEmpty) {
      await tester.tap(levels.first);
    }
    await shot('02_oyin');

    router.go(
      AppRoutes.result,
      extra: const GameResult(
        gameId: 'memory_match',
        stars: 3,
        duration: Duration(seconds: 75),
        streakDays: 7,
      ),
    );
    await shot('03_natija');

    router.go(AppRoutes.achievements);
    await shot('04_yutuqlar');

    router.go(AppRoutes.certificate);
    await shot('05_sertifikat');

    container.read(parentUnlockedProvider.notifier).unlock();
    router.go(AppRoutes.parentPanel);
    await shot('06_ota_ona_hisoboti');
  });
}
