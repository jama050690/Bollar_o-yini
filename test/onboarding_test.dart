import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/home/home_screen.dart';
import 'package:aqlli_dostlar/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_onboarding_test');
    Hive.init(tempDir.path);
    await HiveStorage.openBoxes(inMemory: true);
  });

  setUp(() async {
    await HiveStorage.profiles.clear();
    await HiveStorage.settings.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();
  }

  testWidgets("birinchi ochilishda ko'rsatma chiqadi, 3 sahifadan keyin profil yaratiladi",
      (tester) async {
    await openApp(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text(AppStrings.onboarding1), findsOneWidget);

    await tester.tap(find.text(AppStrings.onboardingNext));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.onboarding2), findsOneWidget);

    await tester.tap(find.text(AppStrings.onboardingNext));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.onboarding3), findsOneWidget);
    expect(find.text(AppStrings.onboardingStart), findsOneWidget);

    await tester.tap(find.text(AppStrings.onboardingStart));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.createProfileTitle), findsOneWidget);
    expect(HiveStorage.settings.get('onboardingDone'), isTrue);
  });

  testWidgets("sahifalarni surib ham almashtirsa bo'ladi", (tester) async {
    await openApp(tester);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.onboarding2), findsOneWidget);
  });

  testWidgets("o'tkazib yuborilsa, darhol profil yaratish ochiladi", (tester) async {
    await openApp(tester);
    await tester.tap(find.text(AppStrings.onboardingSkip));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.createProfileTitle), findsOneWidget);
  });

  testWidgets("ko'rilgan bo'lsa, qayta chiqmaydi", (tester) async {
    await HiveStorage.settings.put('onboardingDone', true);
    await openApp(tester);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text(AppStrings.createProfileTitle), findsOneWidget);
  });

  testWidgets("profili bor eski foydalanuvchiga ko'rsatma chiqmaydi", (tester) async {
    await HiveStorage.profiles.put('p1', {
      'id': 'p1',
      'name': 'Ali',
      'age': 6,
      'avatar': '🐱',
      'createdAt': 0,
    });
    await HiveStorage.settings.put('activeProfileId', 'p1');
    await openApp(tester);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
