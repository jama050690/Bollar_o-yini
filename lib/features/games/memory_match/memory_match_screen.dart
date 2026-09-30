import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/choice_card.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'memory_game.dart';

const _gameId = 'memory_match';

/// Xotira o'yini: hayvon/meva juftliklarini topish.
class MemoryMatchScreen extends ConsumerStatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  ConsumerState<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends ConsumerState<MemoryMatchScreen> {
  MemoryGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(MemoryDifficulty difficulty) {
    setState(() => _game = MemoryGame(difficulty));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onCardTap(int index) {
    final game = _game!;
    final outcome = game.flip(index);
    if (outcome == FlipOutcome.ignored) return;
    setState(() {});

    final sound = ref.read(soundServiceProvider);
    switch (outcome) {
      case FlipOutcome.matched:
        sound.play(SoundService.correct);
        if (game.isFinished) {
          _stopwatch.stop();
          _timer = Timer(const Duration(milliseconds: 700), _finish);
        }
      case FlipOutcome.mismatched:
        // Bola ikkala kartani ko'rib olishi uchun qisqa pauza.
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(game.hideMismatched);
        });
      case FlipOutcome.firstFlipped:
      case FlipOutcome.ignored:
        break;
    }
  }

  void _finish() {
    if (!mounted) return;
    finishGame(
      context,
      ref,
      GameResult(gameId: _gameId, stars: _game!.stars, duration: _stopwatch.elapsed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.memoryTitle,
      color: AgeGroup.a.color,
      child: game == null ? _DifficultyPicker(onSelected: _start) : _buildBoard(game),
    );
  }

  Widget _buildBoard(MemoryGame game) {
    final columns = game.difficulty.columns;
    final rows = game.difficulty.rows;
    const spacing = 8.0;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Kartalar ekranga to'liq sig'ishi uchun o'lchamni hisoblaymiz.
          final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
          final cellHeight = (constraints.maxHeight - spacing * (rows - 1)) / rows;
          final cell = min(cellWidth, cellHeight);

          return Center(
            child: SizedBox(
              width: cell * columns + spacing * (columns - 1),
              height: cell * rows + spacing * (rows - 1),
              child: GridView.count(
                crossAxisCount: columns,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < game.cards.length; i++)
                    _FlipCard(card: game.cards[i], onTap: () => _onCardTap(i)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({required this.onSelected});

  final ValueChanged<MemoryDifficulty> onSelected;

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
                for (final d in MemoryDifficulty.values)
                  ChoiceCard(
                    emoji: d.emoji,
                    label: '${d.label}\n${d.columns}×${d.rows}',
                    color: Colors.white,
                    onTap: () => onSelected(d),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Aylanadigan karta: orqa tomoni "?" , old tomoni emoji.
class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.card, required this.onTap});

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: card.isFaceUp ? 1 : 0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, _) {
          final showFront = value >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi),
            child: showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _front(),
                  )
                : _back(),
          );
        },
      ),
    );
  }

  Widget _front() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: card.isMatched ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: card.isMatched ? const Color(0xFF66BB6A) : Colors.black12,
          width: 3,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: FittedBox(child: Text(card.symbol)),
    );
  }

  Widget _back() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7E57C2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: const FittedBox(
        child: Text(
          '?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
