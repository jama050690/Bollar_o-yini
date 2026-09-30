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
import 'math_adventure_game.dart';

const _gameId = 'math_adventure';

/// Matematik sarguzasht: qo'shish/ayirish, har to'g'ri javob — bir qadam oldinga.
class MathAdventureScreen extends ConsumerStatefulWidget {
  const MathAdventureScreen({super.key});

  @override
  ConsumerState<MathAdventureScreen> createState() => _MathAdventureScreenState();
}

class _MathAdventureScreenState extends ConsumerState<MathAdventureScreen> {
  MathAdventureGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrongOption;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(MathLevel level) {
    setState(() => _game = MathAdventureGame(level));
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
    setState(() => _wrongOption = outcome == AnswerOutcome.wrong ? value : null);

    switch (outcome) {
      case AnswerOutcome.correct:
        sound.play(SoundService.correct);
      case AnswerOutcome.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrongOption = null);
        });
      case AnswerOutcome.finished:
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
      title: AppStrings.mathTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.step, MathAdventureGame.questionCount),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(MathAdventureGame game) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdventureTrack(step: game.step, emoji: game.level.emoji),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
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
          height: 40,
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
                _AnswerButton(
                  value: option,
                  wrong: option == _wrongOption,
                  onTap: () => _onAnswer(option),
                ),
            ],
          ),
      ],
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<MathLevel> onSelected;

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
                for (final level in MathLevel.values)
                  ChoiceCard(
                    emoji: level.emoji,
                    label: '${level.label}\n${AppStrings.upTo(level.max)}',
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

/// Sarguzasht yo'li: personaj har to'g'ri javobda 🏁 tomon bir qadam yuradi.
class _AdventureTrack extends StatelessWidget {
  const _AdventureTrack({required this.step, required this.emoji});

  final int step;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    const total = MathAdventureGame.questionCount;
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEDC8),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Yo'l nuqtalari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i <= total; i++)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= step ? const Color(0xFF7CB342) : Colors.white,
                  ),
                ),
            ],
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('🏁', style: TextStyle(fontSize: 40)),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            alignment: Alignment(-1 + 2 * step / total, 0),
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.value, required this.wrong, required this.onTap});

  final int value;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: wrong ? const Color(0xFFFFE0B2) : Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: onTap,
        child: Center(
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
