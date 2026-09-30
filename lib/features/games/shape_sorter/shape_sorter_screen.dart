import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'shape_sorter_game.dart';
import 'toy_view.dart';

const _gameId = 'shape_sorter';

/// Rang-Shakl sortiri: drag & drop orqali o'yinchoqlarni saralash.
class ShapeSorterScreen extends ConsumerStatefulWidget {
  const ShapeSorterScreen({super.key});

  @override
  ConsumerState<ShapeSorterScreen> createState() => _ShapeSorterScreenState();
}

class _ShapeSorterScreenState extends ConsumerState<ShapeSorterScreen> {
  final _game = ShapeSorterGame();
  final _stopwatch = Stopwatch()..start();
  Timer? _timer;
  bool _showTryAgain = false;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDrop(Toy toy, int binIndex) {
    final outcome = _game.drop(toy, binIndex);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _showTryAgain = outcome == DropOutcome.wrong);

    switch (outcome) {
      case DropOutcome.correct:
        sound.play(SoundService.correct);
      case DropOutcome.wrong:
        // O'yinchoq o'z joyiga qaytadi, jazo yo'q — faqat rag'batlantirish.
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _showTryAgain = false);
        });
      case DropOutcome.roundFinished:
        sound.play(SoundService.correct);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            _celebrating = false;
            _game.startNextRound();
          });
        });
      case DropOutcome.gameFinished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          finishGame(
            context,
            ref,
            GameResult(gameId: _gameId, stars: _game.stars, duration: _stopwatch.elapsed),
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = _game.currentRound;

    return GameScaffold(
      title: AppStrings.shapeSorterTitle,
      color: AgeGroup.a.color,
      trailing: Text(
        AppStrings.round(_game.roundIndex + 1, _game.rounds.length),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _celebrating
                  ? AppStrings.wellDone
                  : round.sortBy == SortBy.color
                      ? AppStrings.sortByColor
                      : AppStrings.sortByShape,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: 36,
              child: _showTryAgain
                  ? const Text(
                      AppStrings.tryAgain,
                      style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                    )
                  : null,
            ),
            // Saralanadigan o'yinchoqlar
            Expanded(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    for (final toy in _game.remaining)
                      Draggable<Toy>(
                        data: toy,
                        feedback: ToyView(toy: toy, size: 96),
                        childWhenDragging: Opacity(
                          opacity: 0.25,
                          child: ToyView(toy: toy, size: 80),
                        ),
                        child: ToyView(toy: toy, size: 80),
                      ),
                  ],
                ),
              ),
            ),
            // Savatlar
            Row(
              children: [
                for (var i = 0; i < round.bins.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _BinView(
                        bin: round.bins[i],
                        placed: _game.placed[i],
                        onAccept: (toy) => _onDrop(toy, i),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BinView extends StatelessWidget {
  const _BinView({required this.bin, required this.placed, required this.onAccept});

  final SortBin bin;
  final List<Toy> placed;
  final ValueChanged<Toy> onAccept;

  @override
  Widget build(BuildContext context) {
    final binColor = bin.color?.color ?? Colors.white;

    return DragTarget<Toy>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 170,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: binColor.withValues(alpha: hovering ? 0.55 : 0.3),
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: hovering ? AppColors.text : binColor,
              width: hovering ? 5 : 3,
            ),
          ),
          child: Column(
            children: [
              // Savat belgisi: rang rejimida rangli doira, shakl rejimida shakl konturi.
              if (bin.shape != null)
                ShapeOutline(shape: bin.shape!, size: 56)
              else
                const Text('🧺', style: TextStyle(fontSize: 44)),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [for (final toy in placed) ToyView(toy: toy, size: 30)],
              ),
            ],
          ),
        );
      },
    );
  }
}
