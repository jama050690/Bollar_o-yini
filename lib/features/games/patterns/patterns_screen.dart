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
import 'patterns_game.dart';

const _gameId = 'patterns';

/// Naqshni davom ettir: ketma-ketlikdagi ❓ o'rniga keladigan rasmni topish.
class PatternsScreen extends ConsumerStatefulWidget {
  const PatternsScreen({super.key});

  @override
  ConsumerState<PatternsScreen> createState() => _PatternsScreenState();
}

class _PatternsScreenState extends ConsumerState<PatternsScreen> {
  PatternsGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  String? _wrong;

  /// To'g'ri topilgan naqsh to'liq holda qisqa vaqt ko'rsatiladi.
  PatternQuestion? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(PatternLevel level) {
    setState(() => _game = PatternsGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onAnswer(String option) {
    final game = _game!;
    if (_solved != null || game.isFinished) return;

    final question = game.current;
    final outcome = game.answer(option);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();

    switch (outcome) {
      case PatternOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = option);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case PatternOutcome.correct:
        sound.play(SoundService.correct);
        setState(() {
          _wrong = null;
          _solved = question;
        });
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _solved = null);
        });
      case PatternOutcome.finished:
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
      title: AppStrings.patternsTitle,
      color: AgeGroup.a.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, PatternsGame.questionCount),
                PatternsGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(PatternsGame game) {
    final q = _solved ?? game.current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              const Text(
                AppStrings.continuePattern,
                style: TextStyle(fontSize: 26, color: AppColors.text),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < q.sequence.length; i++)
                    Container(
                      width: 40,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: i == q.missing
                          ? BoxDecoration(
                              color: _solved != null
                                  ? const Color(0xFFC8E6C9)
                                  : const Color(0xFFFFF59D),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: FittedBox(
                        child: Text(
                          i == q.missing && _solved == null ? '❓' : q.sequence[i],
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                    ),
                ],
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
                : _solved != null
                    ? const Text(AppStrings.wellDone, style: TextStyle(fontSize: 22))
                    : null,
          ),
        ),
        GridView.count(
          crossAxisCount: q.options.length == 3 ? 3 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: q.options.length == 3 ? 1 : 1.6,
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
                  child: Center(child: Text(option, style: const TextStyle(fontSize: 52))),
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

  final ValueChanged<PatternLevel> onSelected;

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
                for (final level in PatternLevel.values)
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
