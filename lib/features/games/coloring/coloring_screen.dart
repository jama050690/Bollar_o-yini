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
import 'coloring_game.dart';
import 'coloring_pictures.dart';

const _gameId = 'coloring';

/// Rasm bo'yash: rangni tanlab, rasm bo'lagini bosib bo'yaydi.
class ColoringScreen extends ConsumerStatefulWidget {
  const ColoringScreen({super.key});

  @override
  ConsumerState<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends ConsumerState<ColoringScreen> {
  ColoringGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(ColoringPicture picture) {
    setState(() => _game = ColoringGame(picture));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onTap(Offset local, double side) {
    final game = _game!;
    if (_celebrating) return;
    final outcome = game.tap(local * (100 / side));
    if (outcome == ColoringOutcome.none) return;
    setState(() {});

    if (outcome == ColoringOutcome.finished) {
      _stopwatch.stop();
      ref.read(soundServiceProvider).play(SoundService.win);
      setState(() => _celebrating = true);
      _timer = Timer(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        finishGame(
          context,
          ref,
          GameResult(gameId: _gameId, stars: ColoringGame.stars, duration: _stopwatch.elapsed),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.coloringTitle,
      color: AgeGroup.a.color,
      trailing: game == null ? null : Text(game.picture.emoji, style: const TextStyle(fontSize: 28)),
      child: game == null ? _PicturePicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(ColoringGame game) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _celebrating ? '🎉 ${AppStrings.coloringDone} 🎉' : AppStrings.coloringHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = min(constraints.maxWidth, constraints.maxHeight);
                return Center(
                  child: GestureDetector(
                    onTapUp: (details) => _onTap(details.localPosition, side),
                    child: Container(
                      width: side,
                      height: side,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                      ),
                      child: CustomPaint(
                        painter: _PicturePainter(game.picture, [...game.colors]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Palitra: 12 ta katta rang doirasi (gorizontal aylantiriladi).
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: coloringPalette.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final color = coloringPalette[i];
                final selected = color == game.selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => game.selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 64,
                    height: 64,
                    margin: EdgeInsets.all(selected ? 0 : 6),
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.text : Colors.white,
                        width: selected ? 5 : 3,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ElevatedButton.icon(
              onPressed: _celebrating ? null : () => setState(game.clear),
              icon: const Icon(Icons.cleaning_services_rounded, size: 32),
              label: const Text(AppStrings.clearAll, style: TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PicturePicker extends StatelessWidget {
  const _PicturePicker({required this.onSelected});

  final ValueChanged<ColoringPicture> onSelected;

  @override
  Widget build(BuildContext context) {
    final pictures = [for (final build in coloringPictures) build()];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.choosePicture, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final picture in pictures)
                  ChoiceCard(
                    emoji: picture.emoji,
                    label: picture.name,
                    color: Colors.white,
                    onTap: () => onSelected(picture),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PicturePainter extends CustomPainter {
  _PicturePainter(this.picture, this.colors);

  final ColoringPicture picture;
  final List<int?> colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF37474F);

    for (var i = 0; i < picture.regions.length; i++) {
      final color = colors[i];
      canvas.drawPath(picture.regions[i], Paint()..color = color == null ? Colors.white : Color(color));
      canvas.drawPath(picture.regions[i], outline);
    }
    for (final detail in picture.details) {
      canvas.drawPath(detail, outline);
    }
    final dotPaint = Paint()..color = const Color(0xFF37474F);
    for (final dot in picture.dots) {
      canvas.drawPath(dot, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_PicturePainter old) =>
      old.picture != picture || !_sameColors(old.colors, colors);

  static bool _sameColors(List<int?> a, List<int?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
