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
import 'speed_math_game.dart';

const _gameId = 'speed_math';

/// Tez hisob: 60 soniyalik taymer bilan misollar.
class SpeedMathScreen extends ConsumerStatefulWidget {
  const SpeedMathScreen({super.key});

  @override
  ConsumerState<SpeedMathScreen> createState() => _SpeedMathScreenState();
}

class _SpeedMathScreenState extends ConsumerState<SpeedMathScreen> {
  SpeedMathGame? _game;
  Timer? _clock;
  Timer? _flash;
  int _left = SpeedMathGame.seconds;
  int? _wrong;
  bool _right = false;
  bool _over = false;

  @override
  void dispose() {
    _clock?.cancel();
    _flash?.cancel();
    super.dispose();
  }

  void _start(SpeedLevel level) {
    setState(() {
      _game = SpeedMathGame(level);
      _left = SpeedMathGame.seconds;
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    setState(() => _left--);
    if (_left > 0) return;

    _clock?.cancel();
    _flash?.cancel();
    final game = _game!;
    setState(() => _over = true);
    ref.read(soundServiceProvider).play(SoundService.win);
    _flash = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      finishGame(
        context,
        ref,
        GameResult(
          gameId: _gameId,
          stars: game.stars,
          duration: const Duration(seconds: SpeedMathGame.seconds),
        ),
      );
    });
  }

  void _onAnswer(int option) {
    final game = _game!;
    if (_over) return;

    final sound = ref.read(soundServiceProvider);
    _flash?.cancel();
    if (game.answer(option)) {
      sound.play(SoundService.correct);
      setState(() {
        _wrong = null;
        _right = true;
      });
      _flash = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _right = false);
      });
    } else {
      sound.play(SoundService.tryAgain);
      setState(() => _wrong = option);
      _flash = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _wrong = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.speedMathTitle,
      color: AgeGroup.c.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.secondsLeft(_left),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(SpeedMathGame game) {
    final q = game.current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _left / SpeedMathGame.seconds,
            minHeight: 14,
            backgroundColor: Colors.white,
            color: _left > 10 ? AgeGroup.c.color : const Color(0xFFFB8C00),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: _right ? const Color(0xFFC8E6C9) : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              Text(
                AppStrings.correctCount(game.correct),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _over ? AppStrings.wellDone : '${q.text} = ?',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                AppStrings.speedHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppColors.text),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: Center(
            child: _wrong != null
                ? const Text(
                    AppStrings.tryAgain,
                    style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                  )
                : null,
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            for (final option in q.options)
              Material(
                color: option == _wrong ? const Color(0xFFFFE0B2) : Colors.white,
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

  final ValueChanged<SpeedLevel> onSelected;

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
                for (final level in SpeedLevel.values)
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
