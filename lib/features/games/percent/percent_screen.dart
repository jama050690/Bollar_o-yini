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
import 'percent_game.dart';

const _gameId = 'percent';

/// Foizlar: sonning foizini va chegirmali narxni topish.
class PercentScreen extends ConsumerStatefulWidget {
  const PercentScreen({super.key});

  @override
  ConsumerState<PercentScreen> createState() => _PercentScreenState();
}

class _PercentScreenState extends ConsumerState<PercentScreen> {
  PercentGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrong;

  /// To'g'ri topilgan savol qisqa vaqt yashil holda ko'rsatiladi.
  PercentQuestion? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(PercentLevel level) {
    setState(() => _game = PercentGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onAnswer(int option) {
    final game = _game!;
    if (_solved != null || game.isFinished) return;

    final question = game.current;
    final outcome = game.answer(option);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();

    switch (outcome) {
      case PercentOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = option);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case PercentOutcome.correct:
        sound.play(SoundService.correct);
        setState(() {
          _wrong = null;
          _solved = question;
        });
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _solved = null);
        });
      case PercentOutcome.finished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() {
          _wrong = null;
          _solved = question;
        });
        _timer = Timer(const Duration(milliseconds: 1400), () {
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
      title: AppStrings.percentTitle,
      color: AgeGroup.c.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, PercentGame.questionCount),
                PercentGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(PercentGame game) {
    final q = _solved ?? game.current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              if (q.isDiscount) ...[
                Text(
                  AppStrings.som(q.number),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  AppStrings.discount(q.percent),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                  ),
                ),
              ] else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${AppStrings.percentOf(q.number, q.percent)} = ?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                _solved != null
                    ? '${_format(q, q.answer)}  ✅'
                    : q.isDiscount
                    ? AppStrings.newPrice
                    : '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: AppColors.text),
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
                color: option == _wrong
                    ? const Color(0xFFFFE0B2)
                    : _solved != null && option == q.answer
                    ? const Color(0xFFC8E6C9)
                    : Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  onTap: () => _onAnswer(option),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _format(q, option),
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
        ),
      ],
    );
  }
}

/// Chegirmada javob so'mda, aks holda oddiy son.
String _format(PercentQuestion q, int value) => q.isDiscount ? AppStrings.som(value) : '$value';

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<PercentLevel> onSelected;

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
                for (final level in PercentLevel.values)
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
