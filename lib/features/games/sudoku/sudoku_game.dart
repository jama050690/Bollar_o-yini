import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Daraja: o'lcham (4×4 — 2×2 qutilar, 6×6 — 2×3 qutilar) va bo'sh kataklar soni.
enum SudokuLevel {
  easy4(label: AppStrings.level4Easy, emoji: '🐣', boxRows: 2, boxCols: 2, blanks: 6),
  hard4(label: AppStrings.level4Hard, emoji: '🐥', boxRows: 2, boxCols: 2, blanks: 10),
  six(label: AppStrings.level6, emoji: '🦅', boxRows: 2, boxCols: 3, blanks: 18);

  const SudokuLevel({
    required this.label,
    required this.emoji,
    required this.boxRows,
    required this.boxCols,
    required this.blanks,
  });

  final String label;
  final String emoji;
  final int boxRows;
  final int boxCols;
  final int blanks;

  int get size => boxRows * boxCols;
}

enum SudokuOutcome { ignored, correct, wrong, finished }

/// Sudoku: har qator, ustun va qutida 1..n raqamlari bir martadan.
/// Jumboq yagona yechimga ega; kiritilgan raqam yechim bilan solishtiriladi.
class SudokuGame {
  SudokuGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    solution = _makeSolution(level, rnd);
    cells = [for (final row in solution) List<int?>.of(row)];
    _removeCells(rnd);
    given = [
      for (final row in cells) [for (final v in row) v != null],
    ];
  }

  final SudokuLevel level;
  late final List<List<int>> solution;

  /// Joriy holat: null — bo'sh katak.
  late final List<List<int?>> cells;

  /// Boshidan berilgan (o'zgarmas) kataklar.
  late final List<List<bool>> given;
  int mistakes = 0;

  int get size => level.size;
  int get blanksLeft => cells.fold(0, (sum, row) => sum + row.where((v) => v == null).length);
  bool get isFinished => blanksLeft == 0;
  int get stars => starsForMistakes(mistakes);

  /// Namuna asosida to'g'ri to'ldirilgan jadval, so'ng raqamlar, qatorlar va ustunlar aralashtiriladi.
  static List<List<int>> _makeSolution(SudokuLevel level, Random rnd) {
    final n = level.size;
    final br = level.boxRows;
    final bc = level.boxCols;
    final digits = [for (var d = 1; d <= n; d++) d]..shuffle(rnd);

    // Qatorlar: guruhlar (br qatordan) tartibi va guruh ichidagi tartib aralashadi.
    List<int> order(int groups, int perGroup) {
      final groupOrder = [for (var g = 0; g < groups; g++) g]..shuffle(rnd);
      return [
        for (final g in groupOrder)
          ...([for (var i = 0; i < perGroup; i++) g * perGroup + i]..shuffle(rnd)),
      ];
    }

    final rows = order(n ~/ br, br);
    final cols = order(n ~/ bc, bc);
    int pattern(int r, int c) => (bc * (r % br) + r ~/ br + c) % n;
    return [
      for (final r in rows) [for (final c in cols) digits[pattern(r, c)]],
    ];
  }

  bool _fits(List<List<int?>> grid, int r, int c, int v) {
    final n = size;
    for (var i = 0; i < n; i++) {
      if (grid[r][i] == v || grid[i][c] == v) return false;
    }
    final r0 = r - r % level.boxRows;
    final c0 = c - c % level.boxCols;
    for (var i = r0; i < r0 + level.boxRows; i++) {
      for (var j = c0; j < c0 + level.boxCols; j++) {
        if (grid[i][j] == v) return false;
      }
    }
    return true;
  }

  /// Yechimlar soni (2 dan oshsa to'xtaydi).
  int _countSolutions(List<List<int?>> grid, [int limit = 2]) {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c] != null) continue;
        var count = 0;
        for (var v = 1; v <= size && count < limit; v++) {
          if (!_fits(grid, r, c, v)) continue;
          grid[r][c] = v;
          count += _countSolutions(grid, limit - count);
          grid[r][c] = null;
        }
        return count;
      }
    }
    return 1;
  }

  void _removeCells(Random rnd) {
    final positions = [
      for (var r = 0; r < size; r++)
        for (var c = 0; c < size; c++) (r, c),
    ]..shuffle(rnd);
    var removed = 0;
    for (final (r, c) in positions) {
      if (removed == level.blanks) break;
      final keep = cells[r][c];
      cells[r][c] = null;
      if (_countSolutions(cells) == 1) {
        removed++;
      } else {
        cells[r][c] = keep;
      }
    }
  }

  SudokuOutcome enter(int row, int col, int value) {
    if (given[row][col] || cells[row][col] != null) return SudokuOutcome.ignored;
    if (solution[row][col] != value) {
      mistakes++;
      return SudokuOutcome.wrong;
    }
    cells[row][col] = value;
    return isFinished ? SudokuOutcome.finished : SudokuOutcome.correct;
  }
}
