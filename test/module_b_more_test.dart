import 'dart:math';

import 'package:aqlli_dostlar/features/games/clock/clock_game.dart';
import 'package:aqlli_dostlar/features/games/fractions/fractions_game.dart';
import 'package:aqlli_dostlar/features/games/shop/shop_game.dart';
import 'package:aqlli_dostlar/features/games/translate/translate_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Soat', () {
    test("vaqt matni va 12 soatlik aylanish", () {
      expect(const ClockTime(3, 5).text, '3:05');
      expect(ClockTime.wrap(13, 0), const ClockTime(1, 0));
      expect(ClockTime.wrap(0, 60), const ClockTime(12, 0));
    });

    test("har darajada 10 ta takrorlanmas vaqt, 4 xil variant, daqiqa qadami to'g'ri", () {
      for (final level in ClockLevel.values) {
        for (var seed = 0; seed < 20; seed++) {
          final game = ClockGame(level, random: Random(seed));
          expect(game.questions.map((q) => q.time).toSet().length, ClockGame.questionCount);
          for (final q in game.questions) {
            expect(level.allows(q.time), isTrue);
            expect(q.options.length, ClockGame.optionCount);
            expect(q.options.toSet().length, ClockGame.optionCount);
            expect(q.options, contains(q.answer));
          }
        }
      }
    });

    test("noto'g'ri javob — xato; to'g'rilari bilan tugaydi", () {
      final game = ClockGame(ClockLevel.fives, random: Random(1));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.answer)), ClockOutcome.wrong);
      expect(game.mistakes, 1);
      ClockOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.answer);
      }
      expect(last, ClockOutcome.finished);
      expect(game.stars, 3);
    });
  });

  group("Do'kon", () {
    test("mahsulotlar soni, qaytim musbat, 4 xil musbat variant", () {
      for (final level in ShopLevel.values) {
        final rnd = Random(level.index);
        for (var k = 0; k < 300; k++) {
          final q = ShopGame.makeQuestion(level, rnd);
          expect(q.items.length, level.items);
          expect(q.items.toSet().length, level.items);
          expect(q.paid != null, level.withChange);
          if (q.paid != null) {
            expect(shopBills, contains(q.paid));
            expect(q.paid! - q.total, greaterThan(0));
          }
          expect(q.options.length, ShopGame.optionCount);
          expect(q.options.toSet().length, ShopGame.optionCount);
          expect(q.options, contains(q.answer));
          expect(q.options.every((o) => o > 0), isTrue);
        }
      }
    });

    test("noto'g'ri javob — xato; to'g'rilari bilan tugaydi", () {
      final game = ShopGame(ShopLevel.change, random: Random(2));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.answer)), ShopOutcome.wrong);
      ShopOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.answer);
      }
      expect(last, ShopOutcome.finished);
      expect(game.mistakes, 1);
    });
  });

  group('Kasrlar', () {
    test("topish: maxraj darajaga mos, 4 ta qiymati har xil variant", () {
      for (final level in [FractionLevel.basic, FractionLevel.more]) {
        final rnd = Random(level.index);
        for (var k = 0; k < 300; k++) {
          final q = FractionsGame.makeQuestion(level, rnd);
          expect(q.answer.denominator, inInclusiveRange(level.minDen, level.maxDen));
          expect(q.answer.numerator, inInclusiveRange(1, q.answer.denominator - 1));
          expect(q.options.length, FractionsGame.optionCount);
          expect(q.options, contains(q.answer));
          for (var i = 0; i < q.options.length; i++) {
            for (var j = i + 1; j < q.options.length; j++) {
              expect(q.options[i].sameValue(q.options[j]), isFalse);
            }
          }
        }
      }
    });

    test("solishtirish: 2 ta har xil qiymatli kasr, javob — kattasi", () {
      final rnd = Random(7);
      for (var k = 0; k < 300; k++) {
        final q = FractionsGame.makeQuestion(FractionLevel.versus, rnd);
        expect(q.options.length, 2);
        expect(q.options[0].sameValue(q.options[1]), isFalse);
        final bigger = q.options[0].value > q.options[1].value ? q.options[0] : q.options[1];
        expect(q.answer, bigger);
      }
    });

    test("ketma-ket bir xil savol yo'q; to'g'ri javoblar bilan tugaydi", () {
      final game = FractionsGame(FractionLevel.basic, random: Random(3));
      for (var i = 1; i < game.questions.length; i++) {
        expect(game.questions[i].answer, isNot(game.questions[i - 1].answer));
      }
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.answer)), FractionOutcome.wrong);
      FractionOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.answer);
      }
      expect(last, FractionOutcome.finished);
      expect(game.stars, 3);
    });
  });

  group('Tarjimon darajalari', () {
    test("variantlar soni va yo'nalish darajaga mos", () {
      for (final language in TargetLanguage.values) {
        for (final level in TranslateLevel.values) {
          final game = TranslateGame(language, level: level, random: Random(level.index));
          for (final q in game.questions) {
            expect(q.options.length, level.options);
            expect(q.options.toSet().length, level.options);
            expect(q.options, contains(q.answer));
            if (level.isReverse) {
              expect(q.prompt, q.word.translation(language));
              expect(q.answer, q.word.uzbek);
              expect(q.options.every((o) => translateWords.any((w) => w.uzbek == o)), isTrue);
            } else {
              expect(q.prompt, q.word.uzbek);
              expect(q.answer, q.word.translation(language));
            }
          }
        }
      }
    });

    test("teskari darajada o'zbekcha javob bilan tugaydi", () {
      final game = TranslateGame(
        TargetLanguage.english,
        level: TranslateLevel.reverse,
        random: Random(4),
      );
      expect(game.answer(game.current.word.english), TranslateOutcome.wrong);
      TranslateOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.word.uzbek);
      }
      expect(last, TranslateOutcome.finished);
      expect(game.mistakes, 1);
    });
  });
}
