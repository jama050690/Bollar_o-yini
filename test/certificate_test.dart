import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/certificate/certificate_providers.dart';
import 'package:aqlli_dostlar/features/certificate/certificate_screen.dart';
import 'package:aqlli_dostlar/features/games/game_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const _profileId = 'p1';

Future<void> _seedProfile({String name = 'Ali'}) async {
  await HiveStorage.profiles.put(_profileId, {
    'id': _profileId,
    'name': name,
    'age': 6,
    'avatar': '🐱',
    'createdAt': 0,
  });
  await HiveStorage.settings.put('activeProfileId', _profileId);
}

Future<void> _seedGame(String gameId, {int stars = 2}) => HiveStorage.progress
    .put('$_profileId|$gameId', {'bestStars': stars, 'plays': 1, 'totalSeconds': 30});

Future<void> _seedAllModuleGames({int stars = 2}) async {
  for (final game in gamesFor(AgeGroup.a)) {
    await _seedGame(game.id, stars: stars);
  }
}

Future<void> _openAchievements(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('🏆 '));
  await tester.pumpAndSettle();
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_certificate_test');
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

  group('certificateProvider', () {
    test("0 yulduzli o'yin hisoblanmaydi, hammasi o'tilsa ochiladi", () async {
      await _seedProfile();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final total = gamesFor(AgeGroup.a).length;

      expect(container.read(certificateProvider).gamesLeft, total);
      expect(container.read(certificateProvider).unlocked, isFalse);

      await _seedAllModuleGames(stars: 0);
      container.invalidate(certificateProvider);
      expect(container.read(certificateProvider).gamesLeft, total);
    });

    test("sertifikat sanasi birinchi ochilishda saqlanadi va o'zgarmaydi", () {
      expect(certificateDay('p9', DateTime(2026, 10, 14)), '2026-10-14');
      expect(certificateDay('p9', DateTime(2026, 12, 1)), '2026-10-14');
    });
  });

  testWidgets("yopiq sertifikat nechta o'yin qolganini ko'rsatadi", (tester) async {
    await _seedProfile();
    await _seedGame('memory_match');
    await _openAchievements(tester);

    final left = gamesFor(AgeGroup.a).length - 1;
    expect(find.text(AppStrings.certificateLocked(left)), findsOneWidget);
    expect(find.text(AppStrings.certificateButton), findsNothing);
  });

  testWidgets("hamma o'yin o'tilsa sertifikat ochiladi va ism, yulduzlar ko'rinadi",
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _seedProfile(name: 'Muhammadali');
    await _seedAllModuleGames();
    await _openAchievements(tester);

    await tester.tap(find.text(AppStrings.certificateButton));
    await tester.pumpAndSettle();

    expect(find.byType(CertificateScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Muhammadali'), findsOneWidget);
    expect(find.text(AppStrings.certificateTitle), findsOneWidget);
    final stars = gamesFor(AgeGroup.a).length * 2;
    expect(find.text(AppStrings.certificateStars(stars)), findsOneWidget);
    expect(find.textContaining(AgeGroup.a.title), findsOneWidget);
    expect(HiveStorage.settings.get('certificate|$_profileId'), isA<String>());

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(CertificateScreen), findsNothing);
    expect(find.text(AppStrings.certificateButton), findsOneWidget);
  });
}
