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
import 'shop_game.dart';

const _gameId = 'shop';

/// Do'kon: mahsulotlar narxini qo'shish va qaytimni hisoblash.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrong;

  /// To'g'ri topilgan savol qisqa vaqt yashil holda ko'rsatiladi.
  ShopQuestion? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(ShopLevel level) {
    setState(() => _game = ShopGame(level));
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
      case ShopOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = option);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case ShopOutcome.correct:
        sound.play(SoundService.correct);
        setState(() {
          _wrong = null;
          _solved = question;
        });
        _timer = Timer(const Duration(milliseconds: 1000), () {
          if (mounted) setState(() => _solved = null);
        });
      case ShopOutcome.finished:
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
      title: AppStrings.shopTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, ShopGame.questionCount),
                ShopGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(ShopGame game) {
    final q = _solved ?? game.current;
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [for (final item in q.items) _ItemCard(item: item)],
              ),
              if (q.paid != null) ...[
                const SizedBox(height: 12),
                Text(
                  AppStrings.shopPaid(q.paid!),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _solved != null
                    ? '${AppStrings.som(q.answer)}  ✅'
                    : q.paid != null
                        ? AppStrings.shopChange
                        : AppStrings.shopTotal,
                style: const TextStyle(fontSize: 26, color: AppColors.text),
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
          childAspectRatio: 2,
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
                          AppStrings.som(option),
                          style: const TextStyle(
                            fontSize: 26,
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

/// Mahsulot kartochkasi: katta rasm va narx yorlig'i.
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 2),
      ),
      child: Column(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 48)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppStrings.som(item.price),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<ShopLevel> onSelected;

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
                for (final level in ShopLevel.values)
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
