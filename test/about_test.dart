import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_info.dart';
import 'package:aqlli_dostlar/core/constants/app_language.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/router/app_router.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/parent_panel/about_screen.dart';
import 'package:aqlli_dostlar/features/parent_panel/pin_screen.dart';
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
  await HiveStorage.settings.put('parentPin', '1234');
}

Future<void> _openPanel(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('🔒'));
  await tester.pumpAndSettle();
  for (final digit in '1234'.split('')) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> _tapScrolled(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_about_test');
    Hive.init(tempDir.path);
    await HiveStorage.openBoxes(inMemory: true);
  });

  setUp(() async {
    await HiveStorage.profiles.clear();
    await HiveStorage.progress.clear();
    await HiveStorage.settings.clear();
  });

  tearDown(() => AppStrings.current = AppLanguage.uz);

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('AppInfo', () {
    test('versiya pubspec.yaml bilan bir xil', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final version = RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec)!.group(1);
      expect(AppInfo.version, version);
      expect(AppInfo.displayVersion, contains('('));
    });

    test('maxfiylik sanasi docs/privacy-policy.html bilan bir xil', () {
      final html = File('docs/privacy-policy.html').readAsStringSync();
      expect(html, contains(AppInfo.privacyEffectiveDate));
      expect(html, contains(AppInfo.email));
    });

    test("maxfiylik siyosati 3 tilda bir xil bo'limlar soniga ega", () {
      final counts = <int>{};
      for (final language in AppLanguage.values) {
        AppStrings.current = language;
        final sections = AppStrings.privacySections(AppInfo.author, AppInfo.email);
        counts.add(sections.length);
        expect(sections.last.$2, contains(AppInfo.email));
      }
      expect(counts, {9});
    });
  });

  testWidgets("paneldan maxfiylik siyosati va ilova haqida ochiladi", (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _seedProfile();
    await _openPanel(tester);

    await _tapScrolled(tester, find.text(AppStrings.privacyButton));
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.text(AppStrings.privacyTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    // pageBack() inglizcha "Back" tooltip'ini qidiradi, ilova esa o'zbekcha.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await _tapScrolled(tester, find.text(AppStrings.aboutButton));
    expect(find.byType(AboutScreen), findsOneWidget);
    expect(find.text(AppStrings.aboutVersion(AppInfo.displayVersion)), findsOneWidget);
    expect(find.text(AppInfo.email), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("PIN kiritilmasa maxfiylik sahifasi ochilmaydi", (tester) async {
    await _seedProfile();
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    container.read(appRouterProvider).go(AppRoutes.parentAbout);
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsNothing);
    expect(find.byType(PinScreen), findsOneWidget);
  });
}
