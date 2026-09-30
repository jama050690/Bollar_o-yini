import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'shape_builder_game.dart';

const _gameId = 'shape_builder';

/// Shakldan buyum: shakllarni konturga sudrab uy, mashina, daraxt va h.k. yig'ish.
class ShapeBuilderScreen extends ConsumerStatefulWidget {
  const ShapeBuilderScreen({super.key});

  @override
  ConsumerState<ShapeBuilderScreen> createState() => _ShapeBuilderScreenState();
}

class _ShapeBuilderScreenState extends ConsumerState<ShapeBuilderScreen> {
  final _game = ShapeBuilderGame();
  final _stopwatch = Stopwatch()..start();
  final _boardKey = GlobalKey();
  Timer? _timer;
  bool _showTryAgain = false;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// [feedbackOffset] — sudralgan bo'lakning global chap-yuqori nuqtasi.
  void _onDrop(int partIndex, Offset feedbackOffset, Size feedbackSize, double boardSide) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || _celebrating) return;

    // Bo'lak markazini taxta koordinatalariga (0..1) o'tkazamiz.
    final center = box.globalToLocal(feedbackOffset + feedbackSize.center(Offset.zero));
    final outcome = _game.place(partIndex, center.dx / boardSide, center.dy / boardSide);

    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _showTryAgain = outcome == PlaceResult.wrong);

    switch (outcome) {
      case PlaceResult.correct:
        sound.play(SoundService.correct);
      case PlaceResult.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _showTryAgain = false);
        });
      case PlaceResult.objectFinished:
        sound.play(SoundService.correct);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1600), () {
          if (!mounted) return;
          setState(() {
            _celebrating = false;
            _game.nextObject();
          });
        });
      case PlaceResult.gameFinished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1600), () {
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
    final object = _game.current;
    return GameScaffold(
      title: AppStrings.shapeBuilderTitle,
      color: AgeGroup.a.color,
      trailing: Text(
        AppStrings.round(_game.objectIndex + 1, _game.objects.length),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = min(constraints.maxWidth - 32, constraints.maxHeight * 0.55);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _celebrating
                      ? '${object.emoji} ${object.name}! ${AppStrings.wellDone}'
                      : '${object.emoji} ${object.name} — ${AppStrings.dragShapes}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 32,
                  child: _showTryAgain
                      ? const Text(
                          AppStrings.tryAgain,
                          style: TextStyle(fontSize: 20, color: Color(0xFFFB8C00)),
                        )
                      : null,
                ),
                DragTarget<int>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (details) {
                    final part = object.parts[details.data];
                    _onDrop(details.data, details.offset, _pieceSize(part, side), side);
                  },
                  builder: (context, candidates, rejected) => Container(
                    key: _boardKey,
                    width: side,
                    height: side,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      border: Border.all(
                        color: candidates.isNotEmpty ? AppColors.text : Colors.black12,
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      children: [
                        for (var i = 0; i < object.parts.length; i++)
                          Positioned(
                            left: object.parts[i].left * side,
                            top: object.parts[i].top * side,
                            width: object.parts[i].width * side,
                            height: object.parts[i].height * side,
                            child: PieceView(
                              part: object.parts[i],
                              filled: _game.filled.contains(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Pastdagi shakllar — sudrab taxtaga olib chiqiladi.
                Expanded(
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final index in _game.tray)
                          _TrayPiece(
                            part: object.parts[index],
                            index: index,
                            size: _pieceSize(object.parts[index], side),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Bo'lak haqiqiy o'lchamda sudraladi, lekin barmoq bilan ushlash uchun kamida 56 dp.
  Size _pieceSize(ShapePart part, double side) =>
      Size(max(part.width * side, 56), max(part.height * side, 56));
}

class _TrayPiece extends StatelessWidget {
  const _TrayPiece({required this.part, required this.index, required this.size});

  final ShapePart part;
  final int index;
  final Size size;

  @override
  Widget build(BuildContext context) {
    // Trayda katta bo'laklar kichraytiriladi, sudralganda esa asl o'lchamda ko'rinadi.
    final scale = min(1.0, 110 / max(size.width, size.height));
    final piece = SizedBox.fromSize(size: size, child: PieceView(part: part, filled: true));
    return Draggable<int>(
      data: index,
      feedback: piece,
      // Sudralgan bo'lak markazi barmoq ostida bo'ladi.
      dragAnchorStrategy: (draggable, context, position) => size.center(Offset.zero),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: SizedBox.fromSize(size: size * scale, child: PieceView(part: part, filled: true)),
      ),
      child: SizedBox.fromSize(
        size: size * scale,
        child: PieceView(part: part, filled: true),
      ),
    );
  }
}

/// Bo'lak: to'ldirilgan (rangli) yoki kontur (punktir o'rniga kulrang chiziq).
class PieceView extends StatelessWidget {
  const PieceView({super.key, required this.part, required this.filled});

  final ShapePart part;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PiecePainter(part.shape, filled ? Color(part.color) : null));
  }
}

class _PiecePainter extends CustomPainter {
  _PiecePainter(this.shape, this.fill);

  final PieceShape shape;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = switch (shape) {
      PieceShape.circle => Path()..addOval(rect.deflate(2)),
      PieceShape.square || PieceShape.rectangle => Path()
        ..addRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6))),
      PieceShape.triangle => Path()
        ..moveTo(rect.center.dx, rect.top + 2)
        ..lineTo(rect.right - 2, rect.bottom - 2)
        ..lineTo(rect.left + 2, rect.bottom - 2)
        ..close(),
    };

    if (fill != null) {
      canvas.drawPath(path, Paint()..color = fill!);
    } else {
      canvas.drawPath(path, Paint()..color = const Color(0xFFF1F1F1));
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = fill == null ? const Color(0xFF90A4AE) : Colors.black26,
    );
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.shape != shape || old.fill != fill;
}
