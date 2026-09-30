import 'package:flutter/widgets.dart';

import '../../core/constants/age_group.dart';
import '../../core/constants/app_strings.dart';
import 'letter_number/letter_number_screen.dart';
import 'math_adventure/math_adventure_screen.dart';
import 'maze_quiz/maze_quiz_screen.dart';
import 'memory_match/memory_match_screen.dart';
import 'mini_sudoku/mini_sudoku_screen.dart';
import 'shape_sorter/shape_sorter_screen.dart';
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
];

GameInfo? gameById(String id) {
  for (final game in gameCatalog) {
    if (game.id == id) return game;
  }
  return null;
}

List<GameInfo> gamesFor(AgeGroup group) =>
    gameCatalog.where((game) => game.group == group).toList();
