import 'dart:math';

import '../../../core/constants/app_strings.dart';

/// Qiyinlik darajalari (TZ Modul A-1): 4x4, 4x6, 6x6.
enum MemoryDifficulty {
  easy(columns: 4, rows: 4, label: AppStrings.levelEasy, emoji: '🐣'),
  medium(columns: 4, rows: 6, label: AppStrings.levelMedium, emoji: '🐥'),
  hard(columns: 6, rows: 6, label: AppStrings.levelHard, emoji: '🦅');

  const MemoryDifficulty({
    required this.columns,
    required this.rows,
    required this.label,
    required this.emoji,
  });

  final int columns;
  final int rows;
  final String label;
  final String emoji;

  int get pairCount => columns * rows ~/ 2;
}

class MemoryCard {
  MemoryCard(this.symbol);

  final String symbol;
  bool isFaceUp = false;
  bool isMatched = false;
}

enum FlipOutcome { ignored, firstFlipped, matched, mismatched }

/// O'yin mantiqi — UI dan mustaqil, shuning uchun alohida test qilinadi.
class MemoryGame {
  MemoryGame(this.difficulty, {Random? random})
      : cards = _deal(difficulty.pairCount, random ?? Random());

  /// Hayvon va mevalar (eng qiyin daraja uchun 18 juft kerak).
  static const symbols = [
    '🐶', '🐱', '🐭', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', //
    '🦁', '🐮', '🐷', '🐸', '🐵', '🍎', '🍌', '🍇', '🍓',
  ];

  final MemoryDifficulty difficulty;
  final List<MemoryCard> cards;

  int moves = 0;
  int mismatches = 0;
  int? _firstIndex;
  bool _waitingToHide = false;

  bool get isFinished => cards.every((card) => card.isMatched);

  /// Juftlar sonidan ko'p xato qilmasa 3, ikki barobargacha 2, aks holda 1 yulduz.
  int get stars {
    final pairs = difficulty.pairCount;
    if (mismatches <= pairs) return 3;
    if (mismatches <= pairs * 2) return 2;
    return 1;
  }

  static List<MemoryCard> _deal(int pairCount, Random random) {
    final chosen = (List.of(symbols)..shuffle(random)).take(pairCount);
    return [for (final s in chosen) ...[MemoryCard(s), MemoryCard(s)]]..shuffle(random);
  }

  FlipOutcome flip(int index) {
    final card = cards[index];
    if (_waitingToHide || card.isFaceUp || card.isMatched) return FlipOutcome.ignored;

    card.isFaceUp = true;
    final first = _firstIndex;
    if (first == null) {
      _firstIndex = index;
      return FlipOutcome.firstFlipped;
    }

    _firstIndex = null;
    moves++;
    if (cards[first].symbol == card.symbol) {
      cards[first].isMatched = true;
      card.isMatched = true;
      return FlipOutcome.matched;
    }
    mismatches++;
    _waitingToHide = true;
    return FlipOutcome.mismatched;
  }

  /// Mos kelmagan ikki kartani yopadi (UI qisqa pauzadan keyin chaqiradi).
  void hideMismatched() {
    for (final card in cards) {
      if (!card.isMatched) card.isFaceUp = false;
    }
    _waitingToHide = false;
  }
}
