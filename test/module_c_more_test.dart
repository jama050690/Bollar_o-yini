import 'dart:math';

import 'package:aqlli_dostlar/features/games/anagram/anagram_game.dart';
import 'package:aqlli_dostlar/features/games/geo_quiz/geo_quiz_game.dart';
import 'package:aqlli_dostlar/features/games/nature_quiz/nature_quiz_game.dart';
import 'package:flutter_test/flutter_test.dart';

/// 4 ta turli variant, bittasi to'g'ri javob.
void expectOptions(List<String> options, String answer) {
  expect(options.length, 4);
  expect(options.toSet().length, 4);
  expect(options.where((o) => o == answer).length, 1);
}

void main() {
  group('Geografiya', () {
    test("har darajada 10 ta takrorlanmas savol va to'g'ri variantlar", () {
      for (final level in GeoLevel.values) {
        expect(level.items.length, greaterThanOrEqualTo(GeoQuizGame.questionCount));
        for (var seed = 0; seed < 30; seed++) {
          final game = GeoQuizGame(level, random: Random(seed));
          expect(game.questions.length, 10);
          expect(game.questions.map((q) => q.text).toSet().length, 10);
          for (final q in game.questions) {
            expectOptions(q.options, q.answer);
          }
        }
      }
    });

    test('poytaxt darajalarida savol shablon bilan tuziladi', () {
      final game = GeoQuizGame(GeoLevel.asia, random: Random(1));
      expect(game.questions.every((q) => q.text.endsWith('poytaxti qaysi?')), isTrue);
    });

    test("xato yulduzni kamaytiradi, oxirgi javob o'yinni tugatadi", () {
      final game = GeoQuizGame(GeoLevel.world, random: Random(2));
      final wrong = game.current.options.firstWhere((o) => o != game.current.answer);
      expect(game.answer(wrong), GeoOutcome.wrong);
      for (var i = 0; i < 9; i++) {
        expect(game.answer(game.current.answer), GeoOutcome.correct);
      }
      expect(game.answer(game.current.answer), GeoOutcome.finished);
      expect(game.mistakes, 1);
    });
  });

  group('Tabiat', () {
    test("savollar to'liq va takrorlanmas", () {
      for (final level in NatureLevel.values) {
        expect(level.items.length, greaterThanOrEqualTo(NatureQuizGame.questionCount));
        for (final item in level.items) {
          expect(item.wrong.length, 3);
          expect({item.answer, ...item.wrong}.length, 4, reason: item.prompt);
        }
        final game = NatureQuizGame(level, random: Random(3));
        expect(game.questions.map((q) => q.text).toSet().length, 10);
        for (final q in game.questions) {
          expectOptions(q.options, q.answer);
        }
      }
    });
  });

  group('Anagramma', () {
    test("har darajaga yetarli so'z, takrorlanmas", () {
      expect(anagramBank.map((w) => w.word).toSet().length, anagramBank.length);
      for (final level in AnagramLevel.values) {
        expect(anagramBank.where(level.fits).length, greaterThanOrEqualTo(AnagramGame.wordCount));
      }
      // Har bir so'z biror darajaga tushadi.
      for (final word in anagramBank) {
        expect(AnagramLevel.values.any((l) => l.fits(word)), isTrue, reason: word.word);
      }
    });

    test("harflar aralashgan va so'z harflaridan iborat", () {
      final game = AnagramGame(AnagramLevel.long, random: Random(4));
      final letters = game.current.letters;
      expect(game.tiles.join(), isNot(game.current.word));
      expect([...game.tiles]..sort(), [...letters]..sort());
    });

    test("noto'g'ri so'z — xato, to'g'ri so'z — keyingisi", () {
      final game = AnagramGame(AnagramLevel.five, random: Random(5));

      // Kartochkalarni aralash tartibda qo'yish — noto'g'ri.
      for (var i = 0; i < game.tiles.length - 1; i++) {
        expect(game.place(i), AnagramOutcome.placed);
      }
      expect(game.place(game.tiles.length - 1), AnagramOutcome.wrong);
      expect(game.mistakes, 1);
      expect(game.place(0), AnagramOutcome.ignored);

      // Harfni qaytarish.
      game.removeAt(0);
      expect(game.placed.length, game.tiles.length - 1);
      game.clear();

      for (var w = 0; w < AnagramGame.wordCount; w++) {
        final letters = game.current.letters;
        final used = <int>{};
        late AnagramOutcome outcome;
        for (final letter in letters) {
          final tile = [
            for (var i = 0; i < game.tiles.length; i++) i,
          ].firstWhere((i) => !used.contains(i) && game.tiles[i] == letter);
          used.add(tile);
          outcome = game.place(tile);
        }
        if (w < AnagramGame.wordCount - 1) {
          expect(outcome, AnagramOutcome.correct);
          game.nextWord();
        } else {
          expect(outcome, AnagramOutcome.finished);
        }
      }
      expect(game.mistakes, 1);
    });
  });
}
