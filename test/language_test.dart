import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/core/constants/app_language.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/home/home_screen.dart';
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

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_language_test');
    Hive.init(tempDir.path);
    await HiveStorage.openBoxes(inMemory: true);
  });

  setUp(() async {
    await HiveStorage.profiles.clear();
    await HiveStorage.progress.clear();
    await HiveStorage.settings.clear();
  });

  // Boshqa testlar o'zbekcha matnni kutadi.
  tearDown(() => AppStrings.current = AppLanguage.uz);

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('AppLanguage', () {
    test("avvaldan o'zbekcha, tanlangan til saqlanadi va qayta tiklanadi", () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(appLanguageProvider), AppLanguage.uz);

      container.read(appLanguageProvider.notifier).set(AppLanguage.ru);
      expect(HiveStorage.settings.get('language'), 'ru');
      expect(AppStrings.current, AppLanguage.ru);

      AppStrings.current = AppLanguage.uz;
      final reopened = ProviderContainer();
      addTearDown(reopened.dispose);
      expect(reopened.read(appLanguageProvider), AppLanguage.ru);
      expect(AppStrings.current, AppLanguage.ru);
    });

    test("noma'lum kod o'zbekchaga qaytadi", () {
      expect(AppLanguage.fromCode('de'), AppLanguage.uz);
      expect(AppLanguage.fromCode(null), AppLanguage.uz);
    });

    test('matnlar va enum nomlari joriy tilda olinadi', () {
      final uz = (AppStrings.languageTitle, AgeGroup.a.title, AppStrings.weekdaysShort.first);
      AppStrings.current = AppLanguage.ru;
      final ru = (AppStrings.languageTitle, AgeGroup.a.title, AppStrings.weekdaysShort.first);
      AppStrings.current = AppLanguage.en;
      final en = (AppStrings.languageTitle, AgeGroup.a.title, AppStrings.weekdaysShort.first);

      expect(ru.$1, '🌐 Язык');
      expect(en.$1, '🌐 Language');
      expect({uz.$2, ru.$2, en.$2}.length, 3);
      expect({uz.$3, ru.$3, en.$3}.length, 3);
    });
  });

  testWidgets("ota-ona panelida til almashtirilsa, interfeys darhol o'zgaradi", (tester) async {
    await _seedProfile();
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('🔒'));
    await tester.pumpAndSettle();
    for (final digit in '1234'.split('')) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    final english = find.text('${AppLanguage.en.flag} ${AppLanguage.en.nativeName}');
    await tester.scrollUntilVisible(english, 200);
    await tester.ensureVisible(english);
    await tester.pumpAndSettle();
    await tester.tap(english);
    await tester.pumpAndSettle();

    expect(HiveStorage.settings.get('language'), 'en');
    expect(find.text('Parent panel'), findsOneWidget);
    expect(find.text('🌐 Language'), findsOneWidget);
    expect(find.text('Ota-ona paneli'), findsNothing);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('en'));

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
