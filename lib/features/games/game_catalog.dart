import 'package:flutter/widgets.dart';

import '../../core/constants/age_group.dart';
import '../../core/constants/app_strings.dart';
import 'alphabets/alphabets_screen.dart';
import 'arithmetic/arithmetic_screen.dart';
import 'coloring/coloring_screen.dart';
import 'counting/counting_screen.dart';
import 'crossword/crossword_screen.dart';
import 'letter_number/letter_number_screen.dart';
import 'match_pairs/match_pairs_screen.dart';
import 'math_adventure/math_adventure_screen.dart';
import 'maze_quiz/maze_quiz_screen.dart';
import 'memory_match/memory_match_screen.dart';
import 'mini_sudoku/mini_sudoku_screen.dart';
import 'patterns/patterns_screen.dart';
import 'shape_builder/shape_builder_screen.dart';
import 'shape_sorter/shape_sorter_screen.dart';
import 'times_table/times_table_screen.dart';
import 'translate/translate_screen.dart';
import 'word_builder/word_builder_screen.dart';

/// Bitta mini-o'yin haqida ma'lumot. Har bir o'yin mustaqil papkada (FR-3).
class GameInfo {
  const GameInfo({
    required this.id,
    required this.title,
    required this.emoji,
    required this.group,
    required this.builder,
  });

  final String id;
  final String title;
  final String emoji;
  final AgeGroup group;
  final Widget Function() builder;
}

final List<GameInfo> gameCatalog = [
  GameInfo(
    id: 'memory_match',
    title: AppStrings.memoryTitle,
    emoji: '🃏',
    group: AgeGroup.a,
    builder: () => const MemoryMatchScreen(),
  ),
  GameInfo(
    id: 'letter_number',
    title: AppStrings.letterNumberTitle,
    emoji: '🔤',
    group: AgeGroup.a,
    builder: () => const LetterNumberScreen(),
  ),
  GameInfo(
    id: 'shape_sorter',
    title: AppStrings.shapeSorterTitle,
    emoji: '🔺',
    group: AgeGroup.a,
    builder: () => const ShapeSorterScreen(),
  ),
  GameInfo(
    id: 'times_table',
    title: AppStrings.timesTableTitle,
    emoji: '✖️',
    group: AgeGroup.a,
    builder: () => const TimesTableScreen(),
  ),
  GameInfo(
    id: 'alphabets',
    title: AppStrings.alphabetsTitle,
    emoji: '🌍',
    group: AgeGroup.a,
    builder: () => const AlphabetsScreen(),
  ),
  GameInfo(
    id: 'counting',
    title: AppStrings.countingTitle,
    emoji: '💯',
    group: AgeGroup.a,
    builder: () => const CountingScreen(),
  ),
  GameInfo(
    id: 'shape_builder',
    title: AppStrings.shapeBuilderTitle,
    emoji: '🏠',
    group: AgeGroup.a,
    builder: () => const ShapeBuilderScreen(),
  ),
  GameInfo(
    id: 'coloring',
    title: AppStrings.coloringTitle,
    emoji: '🎨',
    group: AgeGroup.a,
    builder: () => const ColoringScreen(),
  ),
  GameInfo(
    id: 'match_pairs',
    title: AppStrings.matchPairsTitle,
    emoji: '🐾',
    group: AgeGroup.a,
    builder: () => const MatchPairsScreen(),
  ),
  GameInfo(
    id: 'patterns',
    title: AppStrings.patternsTitle,
    emoji: '🔁',
    group: AgeGroup.a,
    builder: () => const PatternsScreen(),
  ),
  // ---------- Modul B (8–9 yosh) ----------
  GameInfo(
    id: 'math_adventure',
    title: AppStrings.mathTitle,
    emoji: '🚀',
    group: AgeGroup.b,
    builder: () => const MathAdventureScreen(),
  ),
  GameInfo(
    id: 'word_builder',
    title: AppStrings.wordBuilderTitle,
    emoji: '🔠',
    group: AgeGroup.b,
    builder: () => const WordBuilderScreen(),
  ),
  GameInfo(
    id: 'maze_quiz',
    title: AppStrings.mazeQuizTitle,
    emoji: '🧭',
    group: AgeGroup.b,
    builder: () => const MazeQuizScreen(),
  ),
  GameInfo(
    id: 'mini_sudoku',
    title: AppStrings.sudokuTitle,
    emoji: '🔢',
    group: AgeGroup.b,
    builder: () => const MiniSudokuScreen(),
  ),
  GameInfo(
    id: 'crossword',
    title: AppStrings.crosswordTitle,
    emoji: '🧩',
    group: AgeGroup.b,
    builder: () => const CrosswordScreen(),
  ),
  GameInfo(
    id: 'arithmetic',
    title: AppStrings.arithmeticTitle,
    emoji: '➗',
    group: AgeGroup.b,
    builder: () => const ArithmeticScreen(),
  ),
  GameInfo(
    id: 'translate',
    title: AppStrings.translateTitle,
    emoji: '🌐',
    group: AgeGroup.b,
    builder: () => const TranslateScreen(),
  ),
];

GameInfo? gameById(String id) {
  for (final game in gameCatalog) {
    if (game.id == id) return game;
  }
  return null;
}

List<GameInfo> gamesFor(AgeGroup group) =>
    gameCatalog.where((game) => game.group == group).toList();
