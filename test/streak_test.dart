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

  group('Kunlik seriya', () {
    test("kunning faqat birinchi o'yini hisoblanadi va bonus beradi", () async {
      await _seedProfile();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final streak = container.read(streakProvider.notifier);

      expect(streak.recordPlay(_day(1)), 1);
      expect(streak.recordPlay(_day(1)), isNull);
      expect(container.read(walletProvider).coins, kDailyBonusCoins);
    });

    test("ketma-ket kunlarda o'sadi, kun o'tkazib yuborilsa 1 dan boshlanadi", () async {
      await _seedProfile();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final streak = container.read(streakProvider.notifier);

      expect(streak.recordPlay(_day(1)), 1);
      expect(streak.recordPlay(_day(2)), 2);
      expect(streak.recordPlay(_day(3)), 3);
      expect(streak.recordPlay(_day(5)), 1);

      final state = container.read(streakProvider);
      expect(state.count, 1);
      expect(state.best, 3);
    });

    test("oy almashganda ham ketma-ketlik saqlanadi", () async {
      await _seedProfile();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final streak = container.read(streakProvider.notifier);

      expect(streak.recordPlay(DateTime(2026, 2, 28, 20)), 1);
      expect(streak.recordPlay(DateTime(2026, 3, 1, 8)), 2);
    });

    test("bugungi seriya: kecha o'ynagan bo'lsa davom etadi, undan oldin bo'lsa 0", () {
      final streak = Streak(count: 4, lastDay: dayKey(_day(10)), best: 4);
      expect(streak.currentAt(_day(10)), 4);
      expect(streak.currentAt(_day(11)), 4);
      expect(streak.currentAt(_day(12)), 0);
    });

    test("seriya qayta ochilganda eslab qolinadi va medal ochadi", () async {
      await _seedProfile();
      final first = ProviderContainer();
      first.read(streakProvider.notifier)
        ..recordPlay(_day(1))
        ..recordPlay(_day(2))
        ..recordPlay(_day(3));
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      expect(second.read(streakProvider).best, 3);
      final medals = second.read(unlockedMedalsProvider).map((m) => m.id);
      expect(medals, contains('streak3'));
      expect(medals, isNot(contains('streak7')));
    });
  });

  group('Ekranlar', () {
    testWidgets("bosh ekranda seriya ko'rinadi", (tester) async {
      await _seedProfile();
      await HiveStorage.settings.put('streak|$_profileId', {
        'count': 3,
        'lastDay': dayKey(DateTime.now()),
        'best': 3,
      });
      await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.streakDays(3)), findsOneWidget);
    });

    testWidgets("seriya uzilgan bo'lsa bosh ekranda ko'rinmaydi", (tester) async {
      await _seedProfile();
      await HiveStorage.settings.put('streak|$_profileId', {
        'count': 3,
        'lastDay': '2020-01-01',
        'best': 3,
      });
      await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
      await tester.pumpAndSettle();

      expect(find.textContaining('🔥'), findsNothing);
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

      expect(find.textContaining('🔥'), findsNothing);
    });
  });
}
