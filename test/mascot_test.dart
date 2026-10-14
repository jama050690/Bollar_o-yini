import 'dart:io';
import 'dart:math';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/games/game_result.dart';
import 'package:aqlli_dostlar/features/games/result/result_screen.dart';
import 'package:aqlli_dostlar/features/parent_panel/time_up_screen.dart';
import 'package:aqlli_dostlar/shared/widgets/mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Ekranda [messages] dan aynan bittasi ko'rinadi.
void _expectOneOf(List<String> messages) {
  final shown = messages.where((m) => find.text(m).evaluate().isNotEmpty);
  expect(shown.length, 1, reason: 'Ko\'rinishi kerak: $messages');
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_mascot_test');
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

  testWidgets("tanlangan gap qayta chizilganda o'zgarmaydi", (tester) async {
    const messages = ['bir', 'ikki', 'uch'];
    Widget build(Color color) => MaterialApp(
          home: Scaffold(
            backgroundColor: color,
            body: Mascot(messages: messages, random: Random(1)),
          ),
        );

    await tester.pumpWidget(build(Colors.white));
    await tester.pumpAndSettle();
    final first = messages.firstWhere((m) => find.text(m).evaluate().isNotEmpty);

    await tester.pumpWidget(build(Colors.yellow));
    await tester.pumpAndSettle();
    expect(find.text(first), findsOneWidget);
    expect(find.text(Mascot.emoji), findsOneWidget);
  });

  testWidgets("bosh ekranda Donish bolani ismi bilan kutib oladi", (tester) async {
    // Kichik telefon o'lchami — matn sig'ishi tekshiriladi.
    tester.view.physicalSize = const Size(360 * 3, 780 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await HiveStorage.profiles.put('p1', {
      'id': 'p1',
      'name': 'Muhammadali',
      'age': 6,
      'avatar': '🐱',
      'createdAt': 0,
    });
    await HiveStorage.settings.put('activeProfileId', 'p1');
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();

    expect(find.byType(Mascot), findsOneWidget);
    _expectOneOf(AppStrings.mascotGreetings('Muhammadali'));
  });

  for (final (stars, praise) in [
    (3, AppStrings.mascotPraise3),
    (2, AppStrings.mascotPraise2),
    (1, AppStrings.mascotPraise1),
  ]) {
    testWidgets('natija ekranida $stars yulduzga mos maqtov', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: GameResult(
            gameId: 'memory_match',
            stars: stars,
            duration: const Duration(seconds: 30),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      _expectOneOf(praise);
    });
  }

  testWidgets('vaqt tugadi ekranida Donish xayrlashadi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TimeUpScreen()));
    await tester.pumpAndSettle();
    _expectOneOf(AppStrings.mascotTimeUp);
  });
}
