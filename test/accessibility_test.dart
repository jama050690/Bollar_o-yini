import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/router/app_router.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Ekran o'quvchi (TalkBack / VoiceOver) va katta shrift bilan ham
/// ilovadan foydalanish mumkinligini tekshiradi.
const _profileId = 'p1';

Future<void> _seed() async {
  await HiveStorage.profiles.put(_profileId, {
    'id': _profileId,
    'name': 'Laylo',
    'age': 6,
    'avatar': '🦊',
    'createdAt': 0,
  });
  await HiveStorage.settings.put('activeProfileId', _profileId);
  await HiveStorage.progress
      .put('$_profileId|memory_match', {'bestStars': 2, 'plays': 1, 'totalSeconds': 60});
}

/// Cheksiz animatsiyalar (maskot, taymerlar) bo'lgani uchun pumpAndSettle o'rniga.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<ProviderContainer> _openApp(WidgetTester tester, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
}

/// Ekranni yopib, qolgan taymerlarni tugatadi.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_a11y_test');
    Hive.init(tempDir.path);
    await HiveStorage.openBoxes(inMemory: true);
  });

  setUp(() async {
    await HiveStorage.profiles.clear();
    await HiveStorage.progress.clear();
    await HiveStorage.settings.clear();
    await _seed();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets("Bosh menyu: ekran o'quvchi yozuvlari", (tester) async {
    final handle = tester.ensureSemantics();
    await _openApp(tester);

    expect(find.bySemanticsLabel(AppStrings.switchProfileLabel), findsOneWidget);
    // O'yin kartasi bitta tugma: nomi va yulduzlari birga o'qiladi.
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(AppStrings.starsLabel(2)))),
      findsWidgets,
    );

    await _expectGuidelines(tester);
    await _close(tester);
    handle.dispose();
  });

  testWidgets("O'yin ekrani: 🏠 tugmasi yozuvli", (tester) async {
    final handle = tester.ensureSemantics();
    final container = await _openApp(tester);
    container.read(appRouterProvider).go(AppRoutes.game('memory_match'));
    await _settle(tester);

    expect(find.byTooltip(AppStrings.homeButtonLabel), findsOneWidget);
    await _expectGuidelines(tester);
    await _close(tester);
    handle.dispose();
  });

  testWidgets('Katta shrift (1.5x): bosh menyu va o\'yin sig\'adi', (tester) async {
    final container = await _openApp(tester, textScale: 1.5);
    expect(tester.takeException(), isNull);

    container.read(appRouterProvider).go(AppRoutes.game('memory_match'));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    await _close(tester);
  });
}
