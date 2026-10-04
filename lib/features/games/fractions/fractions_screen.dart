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
import 'fractions_game.dart';

const _gameId = 'fractions';

/// Kasrlar: pitsaning qancha qismi rangli ekanini topish va kasrlarni solishtirish.
class FractionsScreen extends ConsumerStatefulWidget {
  const FractionsScreen({super.key});

  @override
  ConsumerState<FractionsScreen> createState() => _FractionsScreenState();
}

class _FractionsScreenState extends ConsumerState<FractionsScreen> {
  FractionsGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  Fraction? _wrong;

  /// To'g'ri topilgan savol qisqa vaqt yashil holda ko'rsatiladi.
  FractionQuestion? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(FractionLevel level) {
    setState(() => _game = FractionsGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onAnswer(Fraction option) {
    final game = _game!;
    if (_solved != null || game.isFinished) return;

    final question = game.current;
    final outcome = game.answer(option);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();

    switch (outcome) {
      case FractionOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = option);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case FractionOutcome.correct:
        sound.play(SoundService.correct);
        setState(() {
          _wrong = null;
          _solved = question;
        });
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _solved = null);
        });
      case FractionOutcome.finished:
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

  Color _tint(Fraction option, FractionQuestion q) => option == _wrong
      ? const Color(0xFFFFE0B2)
      : _solved != null && option == q.answer
      ? const Color(0xFFC8E6C9)
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.fractionsTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, FractionsGame.questionCount),
                FractionsGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null
          ? _LevelPicker(onSelected: _start)
          : game.level.compare
          ? _buildCompare(game)
          : _buildIdentify(game),
    );
  }

  Widget _feedback() => SizedBox(
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
  );

  /// ① va ② daraja: bitta pitsa, 4 ta kasr varianti.
  Widget _buildIdentify(FractionsGame game) {
    final q = _solved ?? game.current;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth - 120, constraints.maxHeight * 0.36);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Column(
                children: [
                  Center(
                    child: SizedBox.square(
                      dimension: side,
                      child: CustomPaint(painter: PizzaPainter(q.answer)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.whichFraction,
                    style: TextStyle(fontSize: 26, color: AppColors.text),
                  ),
                ],
              ),
            ),
            _feedback(),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                for (final option in q.options)
                  Material(
                    color: _tint(option, q),
                    elevation: 3,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      onTap: () => _onAnswer(option),
                      child: Center(child: FractionText(option)),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// ③ daraja: ikki pitsa yonma-yon, kattasini bosish kerak.
  Widget _buildCompare(FractionsGame game) {
    final q = _solved ?? game.current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: Text(
            AppStrings.whichBigger,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
        ),
        _feedback(),
        Row(
          children: [
            for (final option in q.options) ...[
              if (option != q.options.first) const SizedBox(width: 16),
              Expanded(
                child: Material(
                  color: _tint(option, q),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    onTap: () => _onAnswer(option),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(painter: PizzaPainter(option)),
                          ),
                          const SizedBox(height: 8),
                          FractionText(option),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Kasrni maktabdagidek yozadi: surat, chiziq, maxraj.
class FractionText extends StatelessWidget {
  const FractionText(this.fraction, {super.key});

  final Fraction fraction;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.text);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${fraction.numerator}', style: style),
        Container(width: 44, height: 4, color: AppColors.text),
        Text('${fraction.denominator}', style: style),
      ],
    );
  }
}

/// Pitsa: d ta teng bo'lak, n tasi pishgan (rangli), qolgani bo'sh.
class PizzaPainter extends CustomPainter {
  const PizzaPainter(this.fraction);

  final Fraction fraction;

  static const _filled = Color(0xFFFFB74D);
  static const _empty = Color(0xFFFFF3E0);
  static const _crust = Color(0xFF8D6E63);
  static const _pepperoni = Color(0xFFE53935);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.94;
    final rect = Rect.fromCircle(center: center, radius: r);
    final sweep = 2 * pi / fraction.denominator;

    for (var i = 0; i < fraction.denominator; i++) {
      final start = -pi / 2 + i * sweep;
      final filled = i < fraction.numerator;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = filled ? _filled : _empty);
      if (filled) {
        // Har bo'lak o'rtasida bitta kolbasa doirasi.
        final mid = start + sweep / 2;
        canvas.drawCircle(
          center + Offset(cos(mid), sin(mid)) * (r * 0.6),
          r * 0.1,
          Paint()..color = _pepperoni,
        );
      }
    }

    final line = Paint()
      ..color = _crust
      ..strokeWidth = r * 0.04;
    for (var i = 0; i < fraction.denominator; i++) {
      final angle = -pi / 2 + i * sweep;
      canvas.drawLine(center, center + Offset(cos(angle), sin(angle)) * r, line);
    }
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..color = _crust,
    );
  }

  @override
  bool shouldRepaint(PizzaPainter oldDelegate) => oldDelegate.fraction != fraction;
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<FractionLevel> onSelected;

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
                for (final level in FractionLevel.values)
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
