import 'dart:math';

import 'package:aqlli_dostlar/features/games/speed_math/speed_math_game.dart';
import 'package:aqlli_dostlar/features/games/sudoku/sudoku_game.dart';
import 'package:aqlli_dostlar/features/games/translate/translate_game.dart';
import 'package:aqlli_dostlar/features/games/translate_plus/translate_plus_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tarjimon+', () {
    test("har til va darajada 10 ta takrorlanmas savol, 4 ta turli variant", () {
      for (final language in TargetLanguage.values) {
        for (final level in TranslatePlusLevel.values) {
          expect(level.items.length, greaterThanOrEqualTo(TranslatePlusGame.questionCount));
          final game = TranslatePlusGame(language, level, random: Random(1));
          expect(game.questions.map((q) => q.item.uzbek).toSet().length, 10);
          for (final q in game.questions) {
            expect(q.answer, q.item.translation(language));
            expect(q.options.length, 4);
            expect(q.options.toSet().length, 4);
            expect(q.options, contains(q.answer));
          }
        }
      }
    });

    test('xato yulduzni kamaytiradi', () {
      final game = TranslatePlusGame(
        TargetLanguage.english,
        TranslatePlusLevel.sentences,
        random: Random(2),
      );
      final wrong = game.current.options.firstWhere((o) => o != game.current.answer);
      expect(game.answer(wrong), PhraseOutcome.wrong);
      for (var i = 0; i < 9; i++) {
        expect(game.answer(game.current.answer), PhraseOutcome.correct);
      }
      expect(game.answer(game.current.answer), PhraseOutcome.finished);
      expect(game.mistakes, 1);
    });
  });

  group('Tez hisob', () {
    int solve(String text) {
      final t = text.split(' ');
      final a = int.parse(t[0]);
      final b = int.parse(t[2]);
      return switch (t[1]) {
        '+' => a + b,
        '−' => a - b,
        '×' => a * b,
        ':' => a % b == 0 ? a ~/ b : -1,
        _ => throw ArgumentError(t[1]),
      };
    }

    test("misollar to'g'ri va variantlar musbat, turli", () {
      final rnd = Random(3);
      for (final level in SpeedLevel.values) {
        for (var i = 0; i < 500; i++) {
          final q = SpeedMathGame.makeQuestion(level, rnd);
          expect(solve(q.text), q.answer, reason: q.text);
          expect(q.options.length, 4);
          expect(q.options.toSet().length, 4);
          expect(q.options.where((o) => o == q.answer).length, 1);
          expect(q.options.every((o) => o > 0), isTrue);
          if (level == SpeedLevel.addSub) expect(q.text, matches(RegExp('[+−]')));
          if (level == SpeedLevel.mulDiv) expect(q.text, matches(RegExp('[×:]')));
        }
      }
    });

    test("xato javob misolni o'zgartirmaydi, yulduz to'g'ri javoblar soniga qarab", () {
      final game = SpeedMathGame(SpeedLevel.mixed, random: Random(4));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.answer)), isFalse);
      expect(game.current, same(q));
      expect(game.stars, 1);
      for (var i = 0; i < SpeedMathGame.twoStars; i++) {
        expect(game.answer(game.current.answer), isTrue);
      }
      expect(game.stars, 2);
      while (game.correct < SpeedMathGame.threeStars) {
        game.answer(game.current.answer);
      }
      expect(game.stars, 3);
    });
  });

  group('Sudoku', () {
    bool validSolution(SudokuGame game) {
      final n = game.size;
      final s = game.solution;
      final full = {for (var d = 1; d <= n; d++) d};
      for (var i = 0; i < n; i++) {
        if (s[i].toSet().length != n || !s[i].toSet().containsAll(full)) return false;
        if ({for (var r = 0; r < n; r++) s[r][i]}.length != n) return false;
      }
      final br = game.level.boxRows;
      final bc = game.level.boxCols;
      for (var r0 = 0; r0 < n; r0 += br) {
        for (var c0 = 0; c0 < n; c0 += bc) {
          final box = {
            for (var r = r0; r < r0 + br; r++)
              for (var c = c0; c < c0 + bc; c++) s[r][c],
          };
          if (box.length != n) return false;
        }
      }
      return true;
    }

    test("yechim to'g'ri, bo'sh kataklar soni darajaga mos", () {
      for (final level in SudokuLevel.values) {
        for (var seed = 0; seed < 40; seed++) {
          final game = SudokuGame(level, random: Random(seed));
          expect(validSolution(game), isTrue);
          expect(game.blanksLeft, level.blanks, reason: '$level seed $seed');
          // Berilgan kataklar yechimga mos.
          for (var r = 0; r < game.size; r++) {
            for (var c = 0; c < game.size; c++) {
              final v = game.cells[r][c];
              if (v != null) expect(v, game.solution[r][c]);
              expect(game.given[r][c], v != null);
            }
          }
        }
      }
    });

    test("noto'g'ri raqam — xato, to'g'ri raqamlar o'yinni tugatadi", () {
      final game = SudokuGame(SudokuLevel.six, random: Random(7));
      final empty = [
        for (var r = 0; r < game.size; r++)
          for (var c = 0; c < game.size; c++)
            if (game.cells[r][c] == null) (r, c),
      ];
      final (r0, c0) = empty.first;
      final wrong = game.solution[r0][c0] % game.size + 1;
      expect(game.enter(r0, c0, wrong), SudokuOutcome.wrong);
      expect(game.mistakes, 1);

      // Berilgan katakka yozib bo'lmaydi.
      final givenCell = [
        for (var r = 0; r < game.size; r++)
          for (var c = 0; c < game.size; c++)
            if (game.given[r][c]) (r, c),
      ].first;
      expect(game.enter(givenCell.$1, givenCell.$2, 1), SudokuOutcome.ignored);

      for (var i = 0; i < empty.length; i++) {
        final (r, c) = empty[i];
        final outcome = game.enter(r, c, game.solution[r][c]);
        expect(outcome, i == empty.length - 1 ? SudokuOutcome.finished : SudokuOutcome.correct);
      }
      expect(game.isFinished, isTrue);
      expect(game.stars, 3);
    });
  });
}
