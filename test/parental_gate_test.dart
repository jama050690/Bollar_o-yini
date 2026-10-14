import 'dart:io';

import 'package:aqlli_dostlar/app.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/storage/hive_storage.dart';
import 'package:aqlli_dostlar/features/parent_panel/pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const _profileId = 'p1';

Future<void> _seedProfile({String? pin}) async {
  await HiveStorage.profiles.put(_profileId, {
    'id': _profileId,
    'name': 'Ali',
    'age': 11,
    'avatar': '🐱',
    'createdAt': 0,
  });
  await HiveStorage.settings.put('activeProfileId', _profileId);
  if (pin != null) await HiveStorage.settings.put('parentPin', pin);
}

Future<void> _openPin(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('🔒'));
  await tester.pumpAndSettle();
}

/// Savoldagi ikki sonni o'qiydi: "... 17 × 6 = ?".
(int, int) _question(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((s) => s.contains('×'));
  final match = RegExp(r'(\d+) × (\d+)').firstMatch(text)!;
  return (int.parse(match[1]!), int.parse(match[2]!));
}

Future<void> _answer(WidgetTester tester, String answer) async {
  await tester.enterText(find.byType(TextField), answer);
  await tester.tap(find.text(AppStrings.confirm));
  await tester.pumpAndSettle();
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('aqlli_dostlar_gate_test');
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

  testWidgets("PIN yo'q bo'lsa avval darvoza, klaviatura ko'rinmaydi", (tester) async {
    await _seedProfile();
    await _openPin(tester);

    expect(find.text(AppStrings.parentGateTitle), findsOneWidget);
    expect(find.text(AppStrings.pinCreate), findsNothing);
    expect(find.text('5'), findsNothing);
    final button = tester.getSize(find.widgetWithText(ElevatedButton, AppStrings.parentGateButton));
    expect(button.height, greaterThanOrEqualTo(64));
  });

  testWidgets("noto'g'ri javob yopiq qoldiradi, to'g'risi PIN yaratishni ochadi", (tester) async {
    await _seedProfile();
    await _openPin(tester);
    await tester.tap(find.text(AppStrings.parentGateButton));
    await tester.pumpAndSettle();

    final (a, b) = _question(tester);
    expect(a, inInclusiveRange(13, 19));
    expect(b, inInclusiveRange(3, 9));

    await _answer(tester, '${a * b + 1}');
    expect(find.text(AppStrings.adultWrong), findsOneWidget);
    expect(find.byType(ParentalGateDialog), findsOneWidget);

    await _answer(tester, '${a * b}');
    expect(find.byType(ParentalGateDialog), findsNothing);
    expect(find.text(AppStrings.parentGateTitle), findsNothing);
    expect(find.text(AppStrings.pinCreate), findsOneWidget);
  });

  testWidgets('bekor qilinsa darvoza yopiq qoladi', (tester) async {
    await _seedProfile();
    await _openPin(tester);
    await tester.tap(find.text(AppStrings.parentGateButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.parentGateTitle), findsOneWidget);
    expect(find.text(AppStrings.pinCreate), findsNothing);
  });

  testWidgets("PIN bor bo'lsa darvoza so'ralmaydi", (tester) async {
    await _seedProfile(pin: '1234');
    await _openPin(tester);

    expect(find.text(AppStrings.parentGateTitle), findsNothing);
    expect(find.text(AppStrings.pinEnter), findsOneWidget);
  });
}
