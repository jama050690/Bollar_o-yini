import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
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
/// Boshqa til uchun: `SHOTS_DIR=ipad_ru` va `--dart-define=SHOTS_LANG=ru` qo'shiladi.
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
  // Interfeys tili: `--dart-define=SHOTS_LANG=ru` (yoki en). Standart — o'zbekcha.
  await settings.put('language', const String.fromEnvironment('SHOTS_LANG', defaultValue: 'uz'));
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

/// Xotira o'yinida [pairs] ta juftni topadi va yana bitta kartani ochiq qoldiradi —
/// skrinshotda o'yin jarayoni ko'rinadi.
Future<void> _playMemory(WidgetTester tester, {int pairs = 3}) async {
  final cards = find.byWidgetPredicate((w) => w.runtimeType.toString() == '_FlipCard');
  final count = cards.evaluate().length;
  final known = <int, String>{};
  final matched = <int>{};

  Future<String> flip(int i) async {
    await tester.tap(cards.at(i));
    await _wait(tester, 450);
    return tester
        .widgetList<Text>(find.descendant(of: cards.at(i), matching: find.byType(Text)))
        .first
        .data!;
  }

  int? pairOf(int i) => known.entries
      .where((e) => e.key != i && e.value == known[i] && !matched.contains(e.key))
      .map((e) => e.key)
      .firstOrNull;

  var found = 0;
  for (var i = 0; i < count && found < pairs; i++) {
    if (matched.contains(i) || known.containsKey(i)) continue;
    known[i] = await flip(i);
    var j = pairOf(i);
    if (j == null) {
      // Juftini hali bilmaymiz — keyingi noma'lum kartani ochamiz.
      j = List.generate(count, (k) => k)
          .firstWhere((k) => k != i && !known.containsKey(k) && !matched.contains(k));
      known[j] = await flip(j);
      if (known[j] != known[i]) {
        await _wait(tester, 1100); // Mos kelmagan kartalar yopiladi.
        final pairForJ = pairOf(j);
        if (pairForJ != null) {
          await flip(pairForJ);
          await flip(j);
          matched.addAll([pairForJ, j]);
          found++;
        }
        continue;
      }
    } else {
      await flip(j);
    }
    matched.addAll([i, j]);
    found++;
  }

  final open = List.generate(count, (k) => k).firstWhere((k) => !matched.contains(k));
  await flip(open);
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
      await _wait(tester, 800);
    }
    await _playMemory(tester);
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
    await _wait(tester);
    // Hisobot bo'limini ekran tepasiga olib chiqamiz.
    await Scrollable.ensureVisible(
      tester.element(find.text(AppStrings.reportTitle)),
      alignment: 0,
    );
    await shot('06_ota_ona_hisoboti');
  });
}
