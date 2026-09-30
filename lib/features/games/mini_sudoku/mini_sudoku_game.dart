import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Daraja = nechta katak bo'sh qoldiriladi.
enum SudokuLevel {
  easy(empty: 3, label: AppStrings.levelEasy, emoji: '🐢'),
  medium(empty: 4, label: AppStrings.levelMedium, emoji: '🐇'),
  hard(empty: 6, label: AppStrings.levelHard, emoji: '🚀');

  const SudokuLevel({required this.empty, required this.label, required this.emoji});

  final int empty;
  final String label;
  final String emoji;
}

/// 1–9 raqamlaridan tuzilgan barcha 8 ta 3x3 sehrli kvadrat
/// (bitta asosiy kvadratning burilishlari va aks ettirilishlari).
/// Har qator, ustun va diagonal yig'indisi = 15.
final List<List<int>> magicSquares = _buildMagicSquares();

List<List<int>> _buildMagicSquares() {
  const base = [2, 7, 6, 9, 5, 1, 4, 3, 8];
  List<int> rotate(List<int> s) => [for (var r = 0; r < 3; r++) for (var c = 0; c < 3; c++) s[(2 - c) * 3 + r]];
  List<int> mirror(List<int> s) => [for (var r = 0; r < 3; r++) for (var c = 0; c < 3; c++) s[r * 3 + (2 - c)]];

  final result = <List<int>>[];
  var square = base;
  for (var i = 0; i < 4; i++) {
    result
      ..add(square)
      ..add(mirror(square));
    square = rotate(square);
  }
  return result;
}

enum PlaceOutcome { correct, wrong, puzzleFinished, gameFinished }

/// Mini-Sudoku mantiqi: 3 ta boshqotirma, bo'sh kataklarni 1–9 bilan to'ldirish.
class MiniSudokuGame {
  MiniSudokuGame(this.level, {Random? random}) : _random = random ?? Random() {
    _newPuzzle();
  }

  static const puzzleCount = 3;

  final SudokuLevel level;
  final Random _random;

  int puzzleIndex = 0;
  int mistakes = 0;

  /// 9 ta katak: null = bo'sh.
  late List<int?> cells;

  /// Boshidan berilgan kataklar (o'zgartirib bo'lmaydi).
  late Set<int> givens;

  bool get isPuzzleComplete => !cells.contains(null);
  bool get isLastPuzzle => puzzleIndex == puzzleCount - 1;
  int get stars => starsForMistakes(mistakes);

  void _newPuzzle() {
    final solution = magicSquares[_random.nextInt(magicSquares.length)];
    final emptyCells = (List.generate(9, (i) => i)..shuffle(_random)).take(level.empty).toSet();
    cells = [for (var i = 0; i < 9; i++) emptyCells.contains(i) ? null : solution[i]];
    givens = {for (var i = 0; i < 9; i++) if (!emptyCells.contains(i)) i};
  }

  /// Hozirgi to'ldirilgan kataklarga mos keladigan sehrli kvadratlar.
  /// Bir nechta javob to'g'ri bo'lishi mumkin — shuning uchun bitta yechim bilan emas,
  /// mos keladigan barcha kvadratlar bilan tekshiramiz.
  Iterable<List<int>> get _candidates => magicSquares.where((square) {
        for (var i = 0; i < 9; i++) {
          final v = cells[i];
          if (v != null && v != square[i]) return false;
        }
        return true;
      });

  bool isValid(int cell, int value) {
    if (cells[cell] != null) return false;
    return _candidates.any((square) => square[cell] == value);
  }

  PlaceOutcome place(int cell, int value) {
    if (!isValid(cell, value)) {
      mistakes++;
      return PlaceOutcome.wrong;
    }
    cells[cell] = value;
    if (!isPuzzleComplete) return PlaceOutcome.correct;
    return isLastPuzzle ? PlaceOutcome.gameFinished : PlaceOutcome.puzzleFinished;
  }

  void nextPuzzle() {
    if (isLastPuzzle) return;
    puzzleIndex++;
    _newPuzzle();
  }

  /// Qator/ustun yig'indisi (ekranda ko'rsatish uchun). To'liq bo'lmasa null.
  int? rowSum(int row) => _sum([row * 3, row * 3 + 1, row * 3 + 2]);
  int? colSum(int col) => _sum([col, col + 3, col + 6]);

  int? _sum(List<int> indexes) {
    var total = 0;
    for (final i in indexes) {
      final v = cells[i];
      if (v == null) return null;
      total += v;
    }
    return total;
  }
}
