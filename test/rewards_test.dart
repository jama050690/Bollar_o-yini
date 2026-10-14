import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/profile/profile_providers.dart';
import 'package:aqlli_dostlar/features/rewards/rewards_catalog.dart';
import 'package:aqlli_dostlar/features/rewards/rewards_providers.dart';
import 'package:aqlli_dostlar/features/rewards/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

Future<void> _seedProfile(String id, {int coins = 0, bool active = true}) async {
  await HiveStorage.profiles.put(id, {
    'id': id,
    'name': 'Ali',
    'age': 6,
    'avatar': '🐱',
    'createdAt': 0,
  });
  if (active) await HiveStorage.settings.put('activeProfileId', id);
  if (coins > 0) await HiveStorage.settings.put('coins|$id', coins);
}

/// Do'kondagi balans (yuqori panelda) — narxlar bilan adashmasligi uchun.
Finder _balance(int coins) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(AppStrings.coins(coins)));

AvatarReward _avatar(String emoji) => kShopAvatars.firstWhere((a) => a.emoji == emoji);

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_rewards_test');
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

  group('Tangalar', () {
    test('yulduz × 5 tanga beriladi', () {
      expect(coinsForStars(1), 5);
      expect(coinsForStars(2), 10);
      expect(coinsForStars(3), 15);
    });

    test("tangalar saqlanadi va ilova qayta ochilganda tiklanadi", () async {
      await _seedProfile('p1');
      final first = ProviderContainer();
      first.read(walletProvider.notifier).earn(15);
      first.read(walletProvider.notifier).earn(10);
      expect(first.read(walletProvider).coins, 25);
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      expect(second.read(walletProvider).coins, 25);
    });

    test('har bir bolaning hamyoni alohida', () async {
      await _seedProfile('p1', coins: 40);
      await _seedProfile('p2', active: false);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(walletProvider).coins, 40);
      container.read(activeProfileIdProvider.notifier).select('p2');
      expect(container.read(walletProvider).coins, 0);
      container.read(activeProfileIdProvider.notifier).select('p1');
      expect(container.read(walletProvider).coins, 40);
    });
  });

  group("Sovg'alar", () {
    test("tanga yetmasa sotib olinmaydi va pul yechilmaydi", () async {
      await _seedProfile('p1', coins: 20);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(walletProvider.notifier).buy(_avatar('🐲')), isFalse);
      final wallet = container.read(walletProvider);
      expect(wallet.coins, 20);
      expect(wallet.owns(_avatar('🐲')), isFalse);
    });

    test("sotib olinadi, qayta bosilganda ikkinchi marta pul yechilmaydi", () async {
      await _seedProfile('p1', coins: 50);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(walletProvider.notifier);

      expect(notifier.buy(_avatar('🦄')), isTrue);
      expect(container.read(walletProvider).coins, 20);
      expect(notifier.buy(_avatar('🦄')), isTrue);
      expect(container.read(walletProvider).coins, 20);
      expect(container.read(walletProvider).owns(_avatar('🦄')), isTrue);
    });

    test("fon: sotib olinmagan fon tanlanmaydi, sotib olingani tanlanadi", () async {
      await _seedProfile('p1', coins: 30);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(walletProvider.notifier);
      final sky = kBackgrounds.firstWhere((b) => b.id == 'bg:sky');

      expect(container.read(walletProvider).backgroundId, kDefaultBackgroundId);
      notifier.selectBackground(sky);
      expect(container.read(walletProvider).backgroundId, kDefaultBackgroundId);

      notifier.buy(sky);
      notifier.selectBackground(sky);
      expect(container.read(walletProvider).backgroundId, 'bg:sky');
      expect(backgroundById('bg:sky'), sky);
      expect(backgroundById("yo'q"), kDefaultBackground);
    });

    test('avatar almashtiriladi va saqlanadi', () async {
      await _seedProfile('p1');
      final first = ProviderContainer();
      first.read(profilesProvider.notifier).updateAvatar('p1', '🦄');
      expect(first.read(activeProfileProvider)!.avatar, '🦄');
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      expect(second.read(activeProfileProvider)!.avatar, '🦄');
    });
  });

  group("Sovg'alar do'koni ekrani", () {
    Future<void> openShop(WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(AppStrings.rewardsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(RewardsScreen), findsOneWidget);
    }

    testWidgets('avatar sotib olinadi va bosh ekranda ko\'rinadi', (tester) async {
      await _seedProfile('p1', coins: 50);
      await openShop(tester);

      expect(_balance(50), findsOneWidget);
      await tester.tap(find.text('🦄'));
      await tester.pumpAndSettle();

      expect(_balance(20), findsOneWidget);
      expect(find.text(AppStrings.rewardsBought), findsOneWidget);
      expect(find.text(AppStrings.rewardsSelected), findsWidgets);

      // pageBack() inglizcha "Back" tooltip'ini qidiradi, ilova esa o'zbekcha.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('🦄'), findsOneWidget);
      expect(find.text(AppStrings.coins(20)), findsOneWidget);
    });

    testWidgets("tanga yetmasa rag'batlantiruvchi xabar chiqadi", (tester) async {
      await _seedProfile('p1', coins: 10);
      await openShop(tester);

      await tester.tap(find.text('🐲'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.rewardsNotEnough), findsOneWidget);
      expect(_balance(10), findsOneWidget);
    });
  });
}
