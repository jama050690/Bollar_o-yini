import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/choice_card.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'mini_sudoku_game.dart';

const _gameId = 'mini_sudoku';

/// Mini-Sudoku: 3x3 sehrli kvadratni 1–9 raqamlari bilan to'ldirish.
class MiniSudokuScreen extends ConsumerStatefulWidget {
  const MiniSudokuScreen({super.key});

  @override
  ConsumerState<MiniSudokuScreen> createState() => _MiniSudokuScreenState();
}

class _MiniSudokuScreenState extends ConsumerState<MiniSudokuScreen> {
  MiniSudokuGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _selectedCell;
  int? _wrongNumber;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(SudokuLevel level) {
    setState(() {
      _game = MiniSudokuGame(level);
      _selectedCell = _firstEmpty();
    });
    _stopwatch
      ..reset()
      ..start();
  }

  int? _firstEmpty() {
    final index = _game!.cells.indexOf(null);
    return index < 0 ? null : index;
  }

  void _onNumber(int value) {
    final game = _game!;
    final cell = _selectedCell;
    if (_celebrating || cell == null) return;

    final outcome = game.place(cell, value);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() {
      _wrongNumber = outcome == PlaceOutcome.wrong ? value : null;
      if (outcome != PlaceOutcome.wrong) _selectedCell = _firstEmpty();
    });

    switch (outcome) {
      case PlaceOutcome.correct:
        break;
      case PlaceOutcome.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _wrongNumber = null);
        });
      case PlaceOutcome.puzzleFinished:
        sound.play(SoundService.correct);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() {
            _celebrating = false;
            game.nextPuzzle();
            _selectedCell = _firstEmpty();
          });
        });
      case PlaceOutcome.gameFinished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1500), () {
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
      title: AppStrings.sudokuTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.puzzleIndex + 1, MiniSudokuGame.puzzleCount),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(MiniSudokuGame game) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _celebrating ? AppStrings.wellDone : AppStrings.sudokuRule,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Center(child: _Board(game: game, selected: _selectedCell, onSelect: _selectCell)),
        SizedBox(
          height: 40,
          child: Center(
            child: _wrongNumber != null
                ? const Text(
                    AppStrings.tryAgain,
                    style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                  )
                : _selectedCell == null && !_celebrating
                    ? const Text(AppStrings.sudokuPickCell, style: TextStyle(fontSize: 20))
                    : null,
          ),
        ),
        _NumberPad(
          used: game.cells.whereType<int>().toSet(),
          wrong: _wrongNumber,
          onTap: _onNumber,
        ),
      ],
    );
  }

  void _selectCell(int index) {
    final game = _game!;
    if (_celebrating || game.cells[index] != null) return;
    setState(() => _selectedCell = index);
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<SudokuLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.chooseLevel, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            const Text(AppStrings.sudokuRule, style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final level in SudokuLevel.values)
                  ChoiceCard(
                    emoji: level.emoji,
                    label: level.label,
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

/// 3x3 taxta; o'ng tomonda va pastda to'liq qator/ustun yig'indisi ko'rinadi.
class _Board extends StatelessWidget {
  const _Board({required this.game, required this.selected, required this.onSelect});

  final MiniSudokuGame game;
  final int? selected;
  final ValueChanged<int> onSelect;

  static const _cellSize = 88.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r < 3; r++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var c = 0; c < 3; c++) _buildCell(r * 3 + c),
              _SumLabel(sum: game.rowSum(r)),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var c = 0; c < 3; c++)
              SizedBox(width: _cellSize + 8, child: Center(child: _SumLabel(sum: game.colSum(c)))),
            const SizedBox(width: 56),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(int index) {
    final value = game.cells[index];
    final isGiven = game.givens.contains(index);
    final isSelected = index == selected;

    return GestureDetector(
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _cellSize,
        height: _cellSize,
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isGiven
              ? const Color(0xFFFFF3C4)
              : value != null
                  ? const Color(0xFFC8E6C9)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black12,
            width: isSelected ? 5 : 2,
          ),
        ),
        child: Text(
          value?.toString() ?? '?',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: value == null ? Colors.black26 : AppColors.text,
          ),
        ),
      ),
    );
  }
}

class _SumLabel extends StatelessWidget {
  const _SumLabel({required this.sum});

  final int? sum;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 40,
      child: Center(
        child: Text(
          sum == null ? '' : '=$sum',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF43A047)),
        ),
      ),
    );
  }
}

/// 1–9 raqam tugmalari. Taxtada bor raqamlar xiralashadi.
class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.used, required this.wrong, required this.onTap});

  final Set<int> used;
  final int? wrong;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var n = 1; n <= 9; n++)
          Opacity(
            opacity: used.contains(n) ? 0.3 : 1,
            child: Material(
              color: n == wrong ? const Color(0xFFFFE0B2) : Colors.white,
              elevation: 3,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: used.contains(n) ? null : () => onTap(n),
                child: SizedBox.square(
                  dimension: 72,
                  child: Center(
                    child: Text(
                      '$n',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
