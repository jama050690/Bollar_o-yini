import 'package:flutter/widgets.dart';

import '../../core/constants/age_group.dart';
import '../../core/constants/app_strings.dart';
import 'letter_number/letter_number_screen.dart';
import 'memory_match/memory_match_screen.dart';
import 'shape_sorter/shape_sorter_screen.dart';

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
];

GameInfo? gameById(String id) {
  for (final game in gameCatalog) {
    if (game.id == id) return game;
  }
  return null;
}

List<GameInfo> gamesFor(AgeGroup group) =>
    gameCatalog.where((game) => game.group == group).toList();
