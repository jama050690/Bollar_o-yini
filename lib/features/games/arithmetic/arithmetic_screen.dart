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
import 'arithmetic_game.dart';

const _gameId = 'arithmetic';

/// Arifmetika: 4 amal, 3 daraja, 10 ta misol.
class ArithmeticScreen extends ConsumerStatefulWidget {
  const ArithmeticScreen({super.key});

  @override
  ConsumerState<ArithmeticScreen> createState() => _ArithmeticScreenState();
}

class _ArithmeticScreenState extends ConsumerState<ArithmeticScreen> {
  ArithmeticGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrongOption;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(ArithmeticLevel level) {
    setState(() => _game = ArithmeticGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onAnswer(int value) {
    final game = _game!;
    if (game.isFinished) return;

    final outcome = game.answer(value);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _wrongOption = outcome == ArithmeticOutcome.wrong ? value : null);

    switch (outcome) {
      case ArithmeticOutcome.correct:
        sound.play(SoundService.correct);
      case ArithmeticOutcome.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrongOption = null);
        });
      case ArithmeticOutcome.finished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        _timer = Timer(const Duration(milliseconds: 1200), () {
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
      title: AppStrings.arithmeticTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + 1).clamp(1, ArithmeticGame.questionCount),
                ArithmeticGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(ArithmeticGame game) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Text(
            game.isFinished ? AppStrings.wellDone : game.current.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: Center(
            child: _wrongOption != null
                ? const Text(
                    AppStrings.tryAgain,
                    style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                  )
                : null,
          ),
        ),
        if (!game.isFinished)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              for (final option in game.current.options)
                Material(
                  color: option == _wrongOption ? const Color(0xFFFFE0B2) : Colors.white,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    onTap: () => _onAnswer(option),
                    child: Center(
                      child: Text(
                        '$option',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<ArithmeticLevel> onSelected;

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
                for (final level in ArithmeticLevel.values)
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
