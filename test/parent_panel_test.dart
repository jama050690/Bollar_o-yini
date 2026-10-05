import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/router/app_router.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/home/home_screen.dart';
import 'package:aqlli_dostlar/features/parent_panel/parent_panel_screen.dart';
import 'package:aqlli_dostlar/features/parent_panel/parent_settings.dart';
import 'package:aqlli_dostlar/features/parent_panel/screen_time_providers.dart';
import 'package:aqlli_dostlar/features/progress/progress_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const _profileId = 'p1';

/// Profil yaratish ekranini chetlab o'tish uchun profilni to'g'ridan-to'g'ri bazaga yozadi.
Future<void> _seedProfile({String? pin, int limit = 0, int todaySeconds = 0}) async {
  await HiveStorage.profiles.put(_profileId, {
    'id': _profileId,
    'name': 'Ali',
    'age': 6,
    'avatar': '🐱',
    'createdAt': 0,
  });
  await HiveStorage.settings.put('activeProfileId', _profileId);
  if (pin != null) await HiveStorage.settings.put('parentPin', pin);
  if (limit > 0) await HiveStorage.settings.put('dailyLimitMinutes', limit);
  if (todaySeconds > 0) {
    await HiveStorage.settings
        .put('screenTime|$_profileId|${dayKey(DateTime.now())}', todaySeconds);
  }
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_parent_test');
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

  group('ParentSettings (FR-6)', () {
    test("PIN o'rnatiladi, tekshiriladi va qayta ochilganda tiklanadi", () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(parentSettingsProvider.notifier);

      expect(container.read(parentSettingsProvider).hasPin, isFalse);
      notifier.setPin('1234');
      expect(notifier.checkPin('1234'), isTrue);
      expect(notifier.checkPin('0000'), isFalse);

      final reopened = ProviderContainer();
      addTearDown(reopened.dispose);
      expect(reopened.read(parentSettingsProvider).pin, '1234');
    });

    test("PIN ni unutdim: PIN o'chadi, chegara saqlanib qoladi", () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(parentSettingsProvider.notifier)
        ..setPin('1234')
        ..setDailyLimit(30);

      notifier.resetPin();
      final settings = container.read(parentSettingsProvider);
      expect(settings.hasPin, isFalse);
      expect(settings.dailyLimitMinutes, 30);
    });
  });

  group('Ekran vaqti (FR-7)', () {
    test('kun kaliti', () {
      expect(dayKey(DateTime(2026, 3, 7)), '2026-03-07');
    });

    test('chegaraga yetganda vaqt tugaydi, yangi kunda 0 dan boshlanadi', () async {
      await _seedProfile(limit: 15);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final today = container.read(currentDayProvider);
      final time = container.read(screenTimeProvider.notifier);

      time.add(_profileId, today, 15 * 60 - 1);
      expect(container.read(timeUpProvider), isFalse);
      time.add(_profileId, today, 1);
      expect(container.read(todaySecondsProvider(_profileId)), 15 * 60);
      expect(container.read(timeUpProvider), isTrue);

      // Ertasi kun.
      container
          .read(currentDayProvider.notifier)
          .refresh(DateTime.now().add(const Duration(days: 1)));
      expect(container.read(todaySecondsProvider(_profileId)), 0);
      expect(container.read(timeUpProvider), isFalse);
    });

    test("chegara o'chiq bo'lsa vaqt hech qachon tugamaydi", () async {
      await _seedProfile(todaySeconds: 10 * 3600);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(timeUpProvider), isFalse);
    });
  });

  group('ProfileReport', () {
    test("faqat shu profil hisoblanadi, sevimlilar o'ynalish soni bo'yicha", () {
      final report = ProfileReport.from(_profileId, {
        '$_profileId|memory_match': const GameProgress(bestStars: 3, plays: 2, totalSeconds: 60),
        '$_profileId|counting': const GameProgress(bestStars: 2, plays: 5, totalSeconds: 120),
        '$_profileId|patterns': const GameProgress(bestStars: 1, plays: 1, totalSeconds: 30),
        '$_profileId|clock': const GameProgress(bestStars: 1, plays: 1, totalSeconds: 30),
        'p2|memory_match': const GameProgress(bestStars: 3, plays: 9, totalSeconds: 999),
      });

      expect(report.plays, 9);
      expect(report.stars, 7);
      expect(report.totalSeconds, 240);
      expect(report.favoriteGameIds.length, 3);
      expect(report.favoriteGameIds.take(2), ['counting', 'memory_match']);
    });
  });

  group('Ekranlar', () {
    Future<void> openApp(WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
      await tester.pumpAndSettle();
    }

    Future<void> typePin(WidgetTester tester, String pin) async {
      for (final digit in pin.split('')) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

    testWidgets("birinchi kirishda PIN o'rnatiladi va panel ochiladi", (tester) async {
      await _seedProfile();
      await openApp(tester);

      await tester.tap(find.text('🔒'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.pinCreate), findsOneWidget);

      await typePin(tester, '1234');
      expect(find.text(AppStrings.pinConfirm), findsOneWidget);
      await typePin(tester, '1234');

      expect(find.text(AppStrings.dailyLimitTitle), findsOneWidget);
      expect(find.text(AppStrings.todayTime(0)), findsOneWidget);
      expect(containerOf(tester).read(parentSettingsProvider).pin, '1234');

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('tasdiqlash mos kelmasa, boshidan kiritiladi', (tester) async {
      await _seedProfile();
      await openApp(tester);
      await tester.tap(find.text('🔒'));
      await tester.pumpAndSettle();

      await typePin(tester, '1234');
      await typePin(tester, '4321');

      expect(find.text(AppStrings.pinMismatch), findsOneWidget);
      expect(find.text(AppStrings.pinCreate), findsOneWidget);
      expect(containerOf(tester).read(parentSettingsProvider).hasPin, isFalse);
    });

    testWidgets("noto'g'ri PIN bilan panel ochilmaydi", (tester) async {
      await _seedProfile(pin: '1234');
      await openApp(tester);
      await tester.tap(find.text('🔒'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.pinEnter), findsOneWidget);

      await typePin(tester, '9999');
      expect(find.text(AppStrings.pinWrong), findsOneWidget);
      expect(find.text(AppStrings.dailyLimitTitle), findsNothing);

      await typePin(tester, '1234');
      expect(find.text(AppStrings.dailyLimitTitle), findsOneWidget);
    });

    testWidgets("panelga PIN siz to'g'ridan-to'g'ri kirib bo'lmaydi", (tester) async {
      await _seedProfile(pin: '1234');
      await openApp(tester);

      containerOf(tester).read(appRouterProvider).go('/parent');
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.pinEnter), findsOneWidget);
    });

    testWidgets('PIN ni unutdim: kattalar savoli → yangi PIN', (tester) async {
      await _seedProfile(pin: '1234');
      await openApp(tester);
      await tester.tap(find.text('🔒'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.pinForgot));
      await tester.pumpAndSettle();
      final question = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .firstWhere((s) => s.contains('×'));
      final match = RegExp(r'(\d+) × (\d+)').firstMatch(question)!;
      final answer = int.parse(match[1]!) * int.parse(match[2]!);

      await tester.enterText(find.byType(TextField), '1');
      await tester.tap(find.text(AppStrings.confirm));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.adultWrong), findsOneWidget);

      await tester.enterText(find.byType(TextField), '$answer');
      await tester.tap(find.text(AppStrings.confirm));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pinCreate), findsOneWidget);
      expect(containerOf(tester).read(parentSettingsProvider).hasPin, isFalse);
    });

    testWidgets('vaqt tugagan bo\'lsa "vaqt tugadi" ekrani chiqadi', (tester) async {
      await _seedProfile(limit: 15, todaySeconds: 15 * 60);
      await openApp(tester);

      expect(find.text(AppStrings.timeUpTitle), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets("vaqt o'yin paytida tugasa ham yo'naltiriladi", (tester) async {
      await _seedProfile(limit: 15, todaySeconds: 15 * 60 - 1);
      await openApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      final container = containerOf(tester);
      container
          .read(screenTimeProvider.notifier)
          .add(_profileId, container.read(currentDayProvider), 1);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.timeUpTitle), findsOneWidget);
    });

    testWidgets("ota-ona chegarani o'chirsa, bola yana o'ynay oladi", (tester) async {
      await _seedProfile(pin: '1234', limit: 15, todaySeconds: 15 * 60);
      await openApp(tester);

      await tester.tap(find.text(AppStrings.parentEntry));
      await tester.pumpAndSettle();
      await typePin(tester, '1234');
      expect(find.text(AppStrings.dailyLimitTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.limitOff));
      await tester.pumpAndSettle();
      // Chegara o'zgarganda panel yopilib qolmaydi.
      expect(find.text(AppStrings.dailyLimitTitle), findsOneWidget);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('chegara paneldan qisqartirilsa, chiqishda vaqt tugadi ekrani', (tester) async {
      await _seedProfile(pin: '1234', todaySeconds: 20 * 60);
      await openApp(tester);
      await tester.tap(find.text('🔒'));
      await tester.pumpAndSettle();
      await typePin(tester, '1234');

      await tester.tap(find.text(AppStrings.minutesShort(15)));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.dailyLimitTitle), findsOneWidget);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.timeUpTitle), findsOneWidget);
    });

    testWidgets("hisoblagich ilova ochiq paytda vaqt qo'shadi", (tester) async {
      await _seedProfile();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await openApp(tester);
      final container = containerOf(tester);
      expect(container.read(todaySecondsProvider(_profileId)), 0);

      await tester.pump(kScreenTimeTick);
      expect(container.read(todaySecondsProvider(_profileId)), kScreenTimeTick.inSeconds);

      // Ilova fonda — vaqt hisoblanmaydi.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(kScreenTimeTick);
      expect(container.read(todaySecondsProvider(_profileId)), kScreenTimeTick.inSeconds);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  });
}
