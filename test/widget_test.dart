import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_test');
    Hive.init(tempDir.path);
    // Xotiradagi baza: testWidgets soxta vaqtida disk IO osilib qolmasligi uchun.
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

  Future<void> createProfile(WidgetTester tester, {required String name, required int age}) async {
    await tester.enterText(find.byType(TextField), name);
    await tester.tap(find.text('$age'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.saveProfile));
    await tester.pumpAndSettle();
  }

  testWidgets("FR-1: birinchi ochilishda profil yaratish ekrani chiqadi", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.createProfileTitle), findsOneWidget);
  });

  testWidgets("FR-2: 6 yoshli bolaga Modul A o'yinlari ochiladi", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();
    await createProfile(tester, name: 'Ali', age: 6);

    expect(find.text(AppStrings.hello('Ali')), findsOneWidget);
    expect(find.text(AppStrings.memoryTitle), findsOneWidget);
    expect(find.text(AppStrings.letterNumberTitle), findsOneWidget);
    expect(find.text(AppStrings.shapeSorterTitle), findsOneWidget);
    // Qo'shimcha o'yinlar ro'yxatda pastroqda — scroll qilib tekshiramiz.
    for (final title in [
      AppStrings.timesTableTitle,
      AppStrings.alphabetsTitle,
      AppStrings.countingTitle,
      AppStrings.shapeBuilderTitle,
      AppStrings.coloringTitle,
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget);
    }
    // Boshqa modullar ko'rinadi, lekin qulflangan.
    await tester.scrollUntilVisible(find.text(AppStrings.lockedFor(8, 9)), 200);
    expect(find.text(AppStrings.lockedFor(8, 9)), findsOneWidget);
    await tester.scrollUntilVisible(find.text(AppStrings.lockedFor(10, 12)), 200);
    expect(find.text(AppStrings.lockedFor(10, 12)), findsOneWidget);
  });

  testWidgets("FR-2: 10 yoshli bola uchun Modul A qulflangan", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();
    await createProfile(tester, name: 'Vali', age: 10);

    expect(find.text(AppStrings.lockedFor(5, 7)), findsOneWidget);
    expect(find.text(AppStrings.memoryTitle), findsNothing);
  });

  testWidgets("FR-2: 8 yoshli bolaga Modul B o'yinlari ochiladi", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();
    await createProfile(tester, name: 'Sardor', age: 8);

    expect(find.text(AppStrings.mathTitle), findsOneWidget);
    expect(find.text(AppStrings.wordBuilderTitle), findsOneWidget);
    expect(find.text(AppStrings.mazeQuizTitle), findsOneWidget);
    expect(find.text(AppStrings.sudokuTitle), findsOneWidget);
    for (final title in [
      AppStrings.crosswordTitle,
      AppStrings.arithmeticTitle,
      AppStrings.translateTitle,
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text(AppStrings.lockedFor(5, 7)), -200);
    expect(find.text(AppStrings.lockedFor(5, 7)), findsOneWidget);
    expect(find.text(AppStrings.memoryTitle), findsNothing);
  });

  testWidgets("FR-5: profil qayta ochilganda tiklanadi", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();
    await createProfile(tester, name: 'Zuhra', age: 5);

    // Ilovani "qayta ochish": yangi ProviderScope — ma'lumot faqat Hive'dan o'qiladi.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(ProviderScope(key: UniqueKey(), child: const AqlliDostlarApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.hello('Zuhra')), findsOneWidget);
  });
}
