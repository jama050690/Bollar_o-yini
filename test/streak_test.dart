import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/achievements/achievements_providers.dart';
import 'package:aqlli_dostlar/features/games/game_result.dart';
import 'package:aqlli_dostlar/features/games/result/result_screen.dart';
import 'package:aqlli_dostlar/features/parent_panel/screen_time_providers.dart';
import 'package:aqlli_dostlar/features/rewards/rewards_providers.dart';
import 'package:aqlli_dostlar/features/streak/streak_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const _profileId = 'p1';

Future<void> _seedProfile() async {
  await HiveStorage.profiles.put(_profileId, {
    'id': _profileId,
    'name': 'Ali',
    'age': 6,
    'avatar': '🐱',
    'createdAt': 0,
  });
  await HiveStorage.settings.put('activeProfileId', _profileId);
}

DateTime _day(int d) => DateTime(2026, 3, d, 10);

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_streak_test');
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

  group("O'ynagan kunlar", () {
    test("kunning faqat birinchi o'yini hisoblanadi va bonus beradi", () async {
      await _seedProfile();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final streak = container.read(streakProvider.notifier);

      expect(streak.recordPlay(_day(1)), 1);
      expect(streak.recordPlay(_day(1)), isNull);
      expect(container.read(walletProvider).coins, kDailyBonusCoins);
    });

    test("kun o'tkazib yuborilsa ham hisob yo'qolmaydi", () async {
      await _seedProfile();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final streak = container.read(streakProvider.notifier);

      expect(streak.recordPlay(_day(1)), 1);
      expect(streak.recordPlay(_day(2)), 2);
      expect(streak.recordPlay(_day(3)), 3);
      expect(streak.recordPlay(_day(20)), 4);

      expect(container.read(streakProvider).days, 4);
      expect(container.read(currentStreakProvider), 4);
      // Bonus har kuni bir xil — oshib boradigan mukofot yo'q.
      expect(container.read(walletProvider).coins, 4 * kDailyBonusCoins);
    });

    test("eski formatdagi seriya eng uzun qiymat bilan ko'chiriladi", () async {
      await _seedProfile();
      await HiveStorage.settings.put('streak|$_profileId', {
        'count': 1,
        'lastDay': '2020-01-01',
        'best': 5,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(streakProvider).days, 5);
      expect(container.read(streakProvider.notifier).recordPlay(_day(1)), 6);
      final medals = container.read(unlockedMedalsProvider).map((m) => m.id);
      expect(medals, contains('streak3'));
    });

    test("kunlar qayta ochilganda eslab qolinadi va medal ochadi", () async {
      await _seedProfile();
      final first = ProviderContainer();
      first.read(streakProvider.notifier)
        ..recordPlay(_day(1))
        ..recordPlay(_day(5))
        ..recordPlay(_day(9));
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      expect(second.read(streakProvider).days, 3);
      final medals = second.read(unlockedMedalsProvider).map((m) => m.id);
      expect(medals, contains('streak3'));
      expect(medals, isNot(contains('streak7')));
    });
  });

  group('Ekranlar', () {
    testWidgets("bosh ekranda o'ynagan kunlar ko'rinadi", (tester) async {
      await _seedProfile();
      await HiveStorage.settings.put('streak|$_profileId', {
        'days': 3,
        'lastDay': dayKey(DateTime.now()),
      });
      await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.streakDays(3)), findsOneWidget);
    });

    testWidgets("uzoq vaqt o'ynamagan bo'lsa ham kunlar saqlanadi", (tester) async {
      await _seedProfile();
      await HiveStorage.settings.put('streak|$_profileId', {
        'days': 3,
        'lastDay': '2020-01-01',
      });
      await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.streakDays(3)), findsOneWidget);
    });

    testWidgets("natija ekranida kunlik bonus ko'rsatiladi", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(
          result: GameResult(
            gameId: 'memory_match',
            stars: 2,
            duration: Duration(seconds: 30),
            streakDays: 3,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.streakBonus(3, kDailyBonusCoins)), findsOneWidget);
    });

    testWidgets("bugun allaqachon o'ynagan bo'lsa bonus ko'rsatilmaydi", (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(
          result: GameResult(
            gameId: 'memory_match',
            stars: 2,
            duration: Duration(seconds: 30),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('📅'), findsNothing);
    });
  });
}
