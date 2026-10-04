import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/services/tts_service.dart';
import '../../../shared/widgets/choice_card.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'translate_game.dart';

const _gameId = 'translate';

/// Tarjimon: o'zbekcha so'z → ruscha/inglizcha tarjimasini topish (ovoz bilan).
/// Teskari darajada chet tilidagi so'z ko'rsatiladi va o'zbekchasi topiladi.
class TranslateScreen extends ConsumerStatefulWidget {
  const TranslateScreen({super.key});

  @override
  ConsumerState<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends ConsumerState<TranslateScreen> {
  TargetLanguage? _language;
  TranslateGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  String? _wrong;

  /// To'g'ri javobdan keyin tarjima ko'rsatilib, ovozda aytiladi.
  String? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(TranslateLevel level) {
    final game = TranslateGame(_language!, level: level);
    setState(() => _game = game);
    _stopwatch
      ..reset()
      ..start();
    _speakPrompt(game);
  }

  /// Teskari darajada savoldagi chet tilidagi so'z ovozda aytiladi.
  void _speakPrompt(TranslateGame game) {
    if (!game.level.isReverse || game.isFinished) return;
    ref.read(ttsServiceProvider).speak(game.current.prompt, language: game.language.ttsLanguage);
  }

  void _onAnswer(String option) {
    final game = _game!;
    if (_solved != null || game.isFinished) return;

    final question = game.current;
    final outcome = game.answer(option);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();

    if (outcome == TranslateOutcome.wrong) {
      sound.play(SoundService.tryAgain);
      setState(() => _wrong = option);
      _timer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _wrong = null);
      });
      return;
    }

    sound.play(outcome == TranslateOutcome.finished ? SoundService.win : SoundService.correct);
    setState(() {
      _wrong = null;
      _solved = option;
    });
    // To'g'ri javob ovozi tugagach, so'zni tarjima tilida aytamiz.
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref
          .read(ttsServiceProvider)
          .speak(question.word.translation(game.language), language: game.language.ttsLanguage);
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (outcome == TranslateOutcome.finished) {
          _stopwatch.stop();
          finishGame(
            context,
            ref,
            GameResult(gameId: _gameId, stars: game.stars, duration: _stopwatch.elapsed),
          );
        } else {
          setState(() => _solved = null);
          _speakPrompt(game);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.translateTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, TranslateGame.questionCount),
                TranslateGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: _language == null
          ? _LanguagePicker(onSelected: (language) => setState(() => _language = language))
          : game == null
          ? _LevelPicker(onSelected: _start)
          : _buildGame(game),
    );
  }

  Widget _buildGame(TranslateGame game) {
    // Javob topilgach step oshadi — ko'rsatish uchun oldingi savolni olamiz.
    final q = _solved != null ? game.questions[game.step - 1] : game.current;
    final reverse = game.level.isReverse;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          // Teskari darajada kartochkani bosib so'zni qayta eshitish mumkin.
          onTap: reverse && _solved == null ? () => _speakPrompt(game) : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Column(
              children: [
                Text(q.word.emoji, style: const TextStyle(fontSize: 88)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    reverse ? '${game.language.flag}  ${q.prompt}  🔊' : q.prompt,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(switch ((_solved != null, reverse)) {
                  (true, false) => '${game.language.flag}  $_solved  ✅',
                  (true, true) => '$_solved  ✅',
                  (false, false) => '${game.language.flag}  ${AppStrings.translateHint}',
                  (false, true) => AppStrings.translateReverseHint,
                }, style: const TextStyle(fontSize: 26, color: AppColors.primary)),
              ],
            ),
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
          crossAxisCount: q.options.length == 3 ? 1 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: q.options.length == 3 ? 4.5 : 2,
          children: [
            for (final option in q.options)
              Material(
                color: option == _wrong
                    ? const Color(0xFFFFE0B2)
                    : option == _solved
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
                          option,
                          style: const TextStyle(
                            fontSize: 30,
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

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.onSelected});

  final ValueChanged<TargetLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.chooseLanguage, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final language in TargetLanguage.values)
                  ChoiceCard(
                    emoji: language.flag,
                    label: language.label,
                    color: Colors.white,
                    onTap: () => onSelected(language),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<TranslateLevel> onSelected;

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
                for (final level in TranslateLevel.values)
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
