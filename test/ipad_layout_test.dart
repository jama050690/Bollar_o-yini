import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/core/router/app_router.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/games/game_catalog.dart';
import 'package:aqlli_dostlar/features/games/game_result.dart';
import 'package:aqlli_dostlar/features/parent_panel/parent_settings.dart';
import 'package:aqlli_dostlar/features/parent_panel/screen_time_providers.dart';
import 'package:aqlli_dostlar/features/profile/profile_providers.dart';
import 'package:aqlli_dostlar/shared/widgets/choice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// App Store'da iPad ham qo'llanadi: har bir ekran iPad o'lchamlarida
/// overflow va boshqa xatolarsiz chizilishi kerak (Apple 2.1, 4.0).
const _sizes = {
  'iPad mini': Size(744, 1133),
  'iPad Pro 13 tik': Size(1032, 1376),
  'iPad Pro 13 yotiq': Size(1376, 1032),
};

const _profileId = 'p1';

int _ageFor(AgeGroup group) => switch (group) {
      AgeGroup.a => 6,
      AgeGroup.b => 8,
      AgeGroup.c => 11,
    };

Future<void> _seedProfile({int age = 6, bool active = true}) async {
  await HiveStorage.profiles.put(_profileId, {
    'id': _profileId,
    'name': 'Muhammadali',
    'age': age,
    'avatar': '🐱',
    'createdAt': 0,
  });
  if (active) await HiveStorage.settings.put('activeProfileId', _profileId);
}

/// Cheksiz animatsiyalar (maskot, taymerlar) bo'lgani uchun pumpAndSettle o'rniga.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<ProviderContainer> _openApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
}

Future<void> _go(WidgetTester tester, ProviderContainer container, String location,
    {Object? extra}) async {
  container.read(appRouterProvider).go(location, extra: extra);
  await _settle(tester);
}

/// Ekranni yopib, qolgan taymerlarni tugatadi.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

void _expectClean(WidgetTester tester, String where) {
  final error = tester.takeException();
  expect(error, isNull, reason: '$where: $error');
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_ipad_test');
    Hive.init(tempDir.path);
    await HiveStorage.openBoxes(inMemory: true);
  });

  setUp(() async {
    await HiveStorage.profiles.clear();
    await HiveStorage.progress.clear();
    await HiveStorage.settings.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  for (final MapEntry(key: device, value: size) in _sizes.entries) {
    group(device, () {
      testWidgets('onboarding', (tester) async {
        await _openApp(tester, size);
        _expectClean(tester, '$device onboarding');
        await _close(tester);
      });

      testWidgets('profil yaratish va tanlash', (tester) async {
        await HiveStorage.settings.put('onboardingDone', true);
        final container = await _openApp(tester, size);
        _expectClean(tester, '$device profil yaratish');

        await _seedProfile(active: false);
        container.invalidate(profilesProvider);
        await _go(tester, container, AppRoutes.profiles);
        _expectClean(tester, '$device profil tanlash');
        await _close(tester);
      });

      for (final group in AgeGroup.values) {
        testWidgets('bosh menyu ${group.name}', (tester) async {
          await _seedProfile(age: _ageFor(group));
          await _openApp(tester, size);
          _expectClean(tester, '$device bosh menyu ${group.name}');
          await _close(tester);
        });
      }

      testWidgets('yutuqlar, sertifikat, mukofotlar, natija', (tester) async {
        await _seedProfile();
        for (final game in gamesFor(AgeGroup.a)) {
          await HiveStorage.progress.put(
            '$_profileId|${game.id}',
            {'bestStars': 3, 'plays': 2, 'totalSeconds': 60},
          );
        }
        final container = await _openApp(tester, size);

        for (final route in [AppRoutes.achievements, AppRoutes.certificate, AppRoutes.rewards]) {
          await _go(tester, container, route);
          _expectClean(tester, '$device $route');
        }
        await _go(
          tester,
          container,
          AppRoutes.result,
          extra: const GameResult(
            gameId: 'memory_match',
            stars: 3,
            duration: Duration(seconds: 75),
            streakDays: 3,
          ),
        );
        _expectClean(tester, '$device natija');
        await _close(tester);
      });

      testWidgets("ota-ona bo'limi", (tester) async {
        await _seedProfile();
        final container = await _openApp(tester, size);

        await _go(tester, container, AppRoutes.parentPin);
        _expectClean(tester, '$device darvoza');

        container.read(parentUnlockedProvider.notifier).unlock();
        for (final route in [
          AppRoutes.parentPanel,
          AppRoutes.parentPrivacy,
          AppRoutes.parentAbout,
        ]) {
          await _go(tester, container, route);
          _expectClean(tester, '$device $route');
        }
        await _close(tester);
      });

      testWidgets('vaqt tugadi', (tester) async {
        await _seedProfile();
        await HiveStorage.settings.put('dailyLimitMinutes', 15);
        await HiveStorage.settings
            .put('screenTime|$_profileId|${dayKey(DateTime.now())}', 15 * 60);
        await _openApp(tester, size);
        _expectClean(tester, '$device vaqt tugadi');
        await _close(tester);
      });

      for (final game in gameCatalog) {
        testWidgets("o'yin ${game.id}", (tester) async {
          await _seedProfile(age: _ageFor(game.group));
          final container = await _openApp(tester, size);
          await _go(tester, container, AppRoutes.game(game.id));
          _expectClean(tester, '$device ${game.id} (boshlanish)');

          // Daraja tanlash bo'lsa — birinchi darajaga kirib, o'yin maydonini ham tekshiradi.
          final levels = find.byType(ChoiceCard);
          if (levels.evaluate().isNotEmpty) {
            await tester.ensureVisible(levels.first);
            await tester.tap(levels.first);
            await _settle(tester);
            _expectClean(tester, "$device ${game.id} (o'yin maydoni)");
          }
          await _close(tester);
        });
      }
    });
  }
}
