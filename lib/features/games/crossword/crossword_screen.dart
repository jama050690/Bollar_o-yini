import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/choice_card.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'crossword_game.dart';

const _gameId = 'crossword';

/// Mini-krossvord: rasm-ishorani bosib so'zni tanlaydi, harflar bilan to'ldiradi.
class CrosswordScreen extends ConsumerStatefulWidget {
  const CrosswordScreen({super.key});

  @override
  ConsumerState<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends ConsumerState<CrosswordScreen> {
  CrosswordGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  String? _wrongLetter;
  bool _finished = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(CrosswordLevel level) {
    setState(() => _game = CrosswordGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onLetter(String letter) {
    final game = _game!;
    if (_finished || game.isWordDone(game.selected)) return;

    final outcome = game.tapLetter(letter);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _wrongLetter = outcome == CrosswordOutcome.wrong ? letter : null);

    switch (outcome) {
      case CrosswordOutcome.correct:
        break;
      case CrosswordOutcome.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrongLetter = null);
        });
      case CrosswordOutcome.wordFinished:
        sound.play(SoundService.correct);
        _timer = Timer(const Duration(milliseconds: 700), () {
          if (mounted) setState(game.selectNextOpen);
        });
      case CrosswordOutcome.gameFinished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() => _finished = true);
        _timer = Timer(const Duration(milliseconds: 1600), () {
          if (!mounted) return;
          finishGame(
            context,
            ref,
            GameResult(gameId: _gameId, stars: game.stars, duration: _stopwatch.elapsed),
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.crosswordTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                List.generate(game.puzzle.words.length, game.isWordDone).where((d) => d).length,
                game.puzzle.words.length,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(CrosswordGame game) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Rasm-ishoralar: bosilsa so'z tanlanadi.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < game.puzzle.words.length; i++)
                _ClueButton(
                  emoji: game.puzzle.words[i].entry.emoji,
                  selected: i == game.selected && !_finished,
                  done: game.isWordDone(i),
                  onTap: () => setState(() => game.select(i)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final puzzle = game.puzzle;
                final cellSize = min(
                  56.0,
                  min(constraints.maxWidth / puzzle.cols, constraints.maxHeight / puzzle.rows),
                );
                final selectedCells = game.selectedWord.cells.toSet();
                final cursor = game.cursor;
                return Center(
                  child: SizedBox(
                    width: cellSize * puzzle.cols,
                    height: cellSize * puzzle.rows,
                    child: Stack(
                      children: [
                        for (final cell in puzzle.solution.keys)
                          Positioned(
                            left: cell.$2 * cellSize,
                            top: cell.$1 * cellSize,
                            width: cellSize,
                            height: cellSize,
                            child: _CellView(
                              letter: game.filled[cell],
                              highlighted: !_finished && selectedCells.contains(cell),
                              isCursor: !_finished && cell == cursor,
                              onTap: () => setState(() => game.selectCell(cell)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 36,
            child: Center(
              child: Text(
                _finished
                    ? AppStrings.wellDone
                    : _wrongLetter != null
                        ? AppStrings.tryAgain
                        : AppStrings.crosswordHint,
                style: TextStyle(
                  fontSize: 20,
                  color: _wrongLetter != null ? const Color(0xFFFB8C00) : AppColors.text,
                ),
              ),
            ),
          ),
          if (!_finished)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final letter in game.tiles)
                  _LetterTile(
                    letter: letter,
                    wrong: letter == _wrongLetter,
                    onTap: () => _onLetter(letter),
                  ),
              ],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<CrosswordLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.chooseLevel, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final level in CrosswordLevel.values)
                  ChoiceCard(
                    emoji: level.emoji,
                    label: AppStrings.wordsCount(level.words),
                    color: Colors.white,
                    onTap: () => onSelected(level),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClueButton extends StatelessWidget {
  const _ClueButton({
    required this.emoji,
    required this.selected,
    required this.done,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: done
          ? const Color(0xFFC8E6C9)
          : selected
              ? const Color(0xFFFFF59D)
              : Colors.white,
      elevation: selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? AppColors.text : Colors.transparent, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 34))),
        ),
      ),
    );
  }
}

class _CellView extends StatelessWidget {
  const _CellView({
    required this.letter,
    required this.highlighted,
    required this.isCursor,
    required this.onTap,
  });

  final String? letter;
  final bool highlighted;
  final bool isCursor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isCursor
              ? const Color(0xFFFFE082)
              : highlighted
                  ? const Color(0xFFFFF9C4)
                  : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: highlighted ? AppColors.text : Colors.black26, width: 1.5),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                letter?.toUpperCase() ?? '',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.letter, required this.wrong, required this.onTap});

  final String letter;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: wrong ? const Color(0xFFFFE0B2) : Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 64,
          child: Center(
            child: Text(
              letter.toUpperCase(),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
