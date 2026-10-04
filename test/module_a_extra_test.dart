import 'dart:math';

import 'package:aqlli_dostlar/features/games/alphabets/alphabets_game.dart';
import 'package:aqlli_dostlar/features/games/counting/counting_game.dart';
import 'package:aqlli_dostlar/features/games/shape_builder/shape_builder_game.dart';
import 'package:aqlli_dostlar/features/games/times_table/times_table_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Karra jadvali', () {
    test("misollar darajaga mos, 3 xil variant, to'g'risi ichida", () {
      for (final level in TimesLevel.values) {
        final game = TimesTableGame(level, random: Random(level.index));
        for (final q in game.questions) {
          expect(q.a, inInclusiveRange(1, level.max));
          expect(q.options.toSet().length, 3);
          expect(q.options, contains(q.answer));
          expect(q.options.every((o) => o > 0), isTrue);
        }
      }
    });

    test("noto'g'ri javob — o'sha misol qoladi; 10 ta to'g'ri — tugaydi", () {
      final game = TimesTableGame(TimesLevel.upTo5, random: Random(2));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.answer)), TimesOutcome.wrong);
      expect(game.current, same(q));
      TimesOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.answer);
      }
      expect(last, TimesOutcome.finished);
      expect(game.stars, 3);
    });
  });

  group('Alifbolar', () {
    test("harflar soni: o'zbek 29, rus 33, ingliz 26 — takrorsiz", () {
      expect(Alphabet.uzbek.letters.length, 29);
      expect(Alphabet.russian.letters.length, 33);
      expect(Alphabet.english.letters.length, 26);
      for (final a in Alphabet.values) {
        expect(a.letters.map((l) => l.upper).toSet().length, a.letters.length);
      }
    });

    test("har savolda 4 xil variant, to'g'ri harf ichida; 10 savol takrorlanmaydi", () {
      for (final a in Alphabet.values) {
        final game = AlphabetsGame(a, random: Random(a.index));
        expect(game.questions.length, AlphabetsGame.questionCount);
        expect(game.questions.map((q) => q.target).toSet().length, AlphabetsGame.questionCount);
        for (final q in game.questions) {
          expect(q.options.toSet().length, 4);
          expect(q.options, contains(q.target));
        }
      }
    });

    test("noto'g'ri harf xato hisoblanadi, to'g'rilari bilan tugaydi", () {
      final game = AlphabetsGame(Alphabet.english, random: Random(9));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((l) => l != q.target)), LetterAnswer.wrong);
      LetterAnswer? last;
      while (!game.isFinished) {
        last = game.answer(game.current.target);
      }
      expect(last, LetterAnswer.finished);
      expect(game.mistakes, 1);
    });
  });

  group('Sanash', () {
    test("o'zbekcha sonlar", () {
      expect(uzbekNumber(1), 'bir');
      expect(uzbekNumber(10), 'oʻn');
      expect(uzbekNumber(14), 'oʻn toʻrt');
      expect(uzbekNumber(45), 'qirq besh');
      expect(uzbekNumber(99), 'toʻqson toʻqqiz');
      expect(uzbekNumber(100), 'yuz');
    });

    test('ruscha sonlar', () {
      expect(russianNumber(1), 'один');
      expect(russianNumber(12), 'двенадцать');
      expect(russianNumber(20), 'двадцать');
      expect(russianNumber(45), 'сорок пять');
      expect(russianNumber(99), 'девяносто девять');
      expect(russianNumber(100), 'сто');
    });

    test("1–100 hamma son uchun so'z bor", () {
      for (var n = 1; n <= 100; n++) {
        expect(uzbekNumber(n), isNotEmpty);
        expect(russianNumber(n), isNotEmpty);
      }
    });

    test("savollar darajadan oshmaydi, 4 xil variant", () {
      for (final level in CountingLevel.values) {
        final game = CountingGame(CountingLanguage.russian, level, random: Random(level.index));
        for (final q in game.questions) {
          expect(q.number, inInclusiveRange(1, level.max));
          expect(q.options.toSet().length, 4);
          expect(q.options, contains(q.number));
          expect(q.options.every((o) => o >= 1 && o <= level.max), isTrue);
        }
      }
    });
  });

  group('Shakldan buyum', () {
    test("5 ta buyum, bo'laklar taxta ichida", () {
      expect(buildObjects.length, 5);
      for (final o in buildObjects) {
        for (final p in o.parts) {
          expect(p.left >= 0 && p.top >= 0, isTrue, reason: o.name);
          expect(p.left + p.width, lessThanOrEqualTo(1.0), reason: o.name);
          expect(p.top + p.height, lessThanOrEqualTo(1.0), reason: o.name);
        }
      }
    });

    test("noto'g'ri joy — xato; bo'lak markaziga tashlasa — joylashadi va o'yin tugaydi", () {
      final game = ShapeBuilderGame(random: Random(4));
      final first = game.tray.first;
      // Taxta chetidagi bo'sh joy — hech bir bo'lak yo'q.
      expect(game.place(first, 0.99, 0.99), PlaceResult.wrong);
      expect(game.mistakes, 1);

      PlaceResult? last;
      for (var o = 0; o < game.objects.length; o++) {
        while (!game.isObjectComplete) {
          final piece = game.tray.first;
          // Shu shakldagi bo'sh joylardan birining markaziga tashlaymiz.
          final parts = game.current.parts;
          final slot = List.generate(
            parts.length,
            (i) => i,
          ).firstWhere((i) => !game.filled.contains(i) && parts[i].shape == parts[piece].shape);
          final p = parts[slot];
          last = game.place(piece, p.left + p.width / 2, p.top + p.height / 2);
          expect(last, isNot(PlaceResult.wrong), reason: game.current.name);
        }
        if (last == PlaceResult.objectFinished) game.nextObject();
      }
      expect(last, PlaceResult.gameFinished);
      expect(game.stars, 3);
    });
  });
}
