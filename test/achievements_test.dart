import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/achievements/achievements_catalog.dart';
import 'package:aqlli_dostlar/features/achievements/achievements_providers.dart';
import 'package:aqlli_dostlar/features/achievements/achievements_screen.dart';
import 'package:aqlli_dostlar/features/games/game_catalog.dart';
import 'package:aqlli_dostlar/features/games/game_result.dart';
import 'package:aqlli_dostlar/features/games/result/result_screen.dart';
import 'package:aqlli_dostlar/features/progress/progress_providers.dart';
import 'package:aqlli_dostlar/features/rewards/rewards_providers.dart';
import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/shared/widgets/confetti_overlay.dart';
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

Future<void> _seedGame(String gameId, {int stars = 3, int plays = 1}) => HiveStorage.progress
    .put('$_profileId|$gameId', {'bestStars': stars, 'plays': plays, 'totalSeconds': 30});

Set<String> _unlockedIds(MedalStats stats) =>
    {for (final m in kMedals) if (m.isUnlocked(stats)) m.id};

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_achievements_test');
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

  group('MedalStats', () {
    test("progressdan to'g'ri hisoblanadi", () {
      final stats = MedalStats.from({
        'a': const GameProgress(bestStars: 3, plays: 4),
        'b': const GameProgress(bestStars: 2, plays: 1),
        'c': const GameProgress(),
      }, ['a', 'b']);

      expect(stats.totalPlays, 5);
      expect(stats.distinctGames, 2);
      expect(stats.threeStarGames, 1);
      expect(stats.bestStarsSum, 5);
      expect(stats.moduleComplete, isTrue);
    });

    test("modulda o'ynalmagan o'yin bo'lsa, modul tugallanmagan", () {
      final stats = MedalStats.from({'a': const GameProgress(plays: 1)}, ['a', 'b']);
      expect(stats.moduleComplete, isFalse);
    });

    test("hech narsa o'ynalmagan bo'lsa, medal yo'q", () {
      expect(_unlockedIds(const MedalStats()), isEmpty);
    });

    test('chegaralar', () {
      expect(_unlockedIds(const MedalStats(totalPlays: 1)), {'first_win'});
      expect(_unlockedIds(const MedalStats(totalPlays: 10)), {'first_win', 'player'});
      expect(_unlockedIds(const MedalStats(totalPlays: 50)),
          {'first_win', 'player', 'champion'});
      expect(_unlockedIds(const MedalStats(threeStarGames: 5)), {'master', 'star5'});
      expect(_unlockedIds(const MedalStats(distinctGames: 5)), {'explorer'});
      expect(_unlockedIds(const MedalStats(moduleComplete: true)), {'traveler'});
      expect(_unlockedIds(const MedalStats(bestStarsSum: 24)), isEmpty);
      expect(_unlockedIds(const MedalStats(bestStarsSum: 25)), {'collector'});
      expect(_unlockedIds(const MedalStats(playDays: 2)), isEmpty);
      expect(_unlockedIds(const MedalStats(playDays: 3)), {'streak3'});
      expect(_unlockedIds(const MedalStats(playDays: 7)), {'streak3', 'streak7'});
    });

    test("jami 10 ta medal, id'lar takrorlanmaydi", () {
      expect(kMedals.length, 10);
      expect(kMedals.map((m) => m.id).toSet().length, kMedals.length);
    });

    test("har bir modulda 25 yulduz yig'ish mumkin", () {
      for (final group in AgeGroup.values) {
        expect(gamesFor(group).length * 3, greaterThanOrEqualTo(25));
      }
    });
  });

  group('Bonus tangalar', () {
    test("yangi medal uchun bonus faqat bir marta beriladi", () async {
      await _seedProfile();
      await _seedGame('memory_match');
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final fresh = container.read(awardedMedalsProvider.notifier).claimNew();
      expect(fresh.map((m) => m.id).toSet(), {'first_win', 'master'});
      expect(container.read(walletProvider).coins, 2 * kMedalBonusCoins);

      expect(container.read(awardedMedalsProvider.notifier).claimNew(), isEmpty);
      expect(container.read(walletProvider).coins, 2 * kMedalBonusCoins);
    });

    test("berilgan medallar ilova qayta ochilganda eslab qolinadi", () async {
      await _seedProfile();
      await _seedGame('memory_match', stars: 1);
      final first = ProviderContainer();
      first.read(awardedMedalsProvider.notifier).claimNew();
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      expect(second.read(awardedMedalsProvider), {'first_win'});
      expect(second.read(awardedMedalsProvider.notifier).claimNew(), isEmpty);
    });
  });

  group('Ekranlar', () {
    testWidgets("bosh ekrandan yutuqlar javoni ochiladi", (tester) async {
      await _seedProfile();
      await _seedGame('memory_match');
      await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
      await tester.pumpAndSettle();

      final count = AppStrings.medalsCount(2, kMedals.length);
      await tester.tap(find.text(count));
      await tester.pumpAndSettle();

      expect(find.byType(AchievementsScreen), findsOneWidget);
      expect(find.byType(MedalCard), findsNWidgets(kMedals.length));
      expect(find.text(AppStrings.medalUnlocked), findsNWidgets(2));
    });

    testWidgets("natija ekranida yangi medal ko'rsatiladi", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: GameResult(
            gameId: 'memory_match',
            stars: 3,
            duration: const Duration(seconds: 30),
            newMedals: [medalById('first_win')!],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.newMedal), findsOneWidget);
      expect(find.textContaining(AppStrings.medalFirstWin), findsOneWidget);
    });

    testWidgets("natija ekranida konfetti yog'iladi va tugmalarni to'smaydi", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: GameResult(
            gameId: 'memory_match',
            stars: 3,
            duration: const Duration(seconds: 30),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      final confetti = tester.widget<ConfettiOverlay>(find.byType(ConfettiOverlay));
      expect(confetti.count, 3 * kConfettiPerStar);
      expect(
        find.ancestor(of: find.byType(ConfettiOverlay), matching: find.byType(IgnorePointer)),
        findsWidgets,
      );

      // Animatsiya bir marta o'ynab, to'xtaydi.
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.playAgain), findsOneWidget);
    });
  });
}
