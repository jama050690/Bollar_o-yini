import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Do'kondagi mahsulot. Narx ming so'mda (3 → "3 000 so'm").
class ShopItem {
  const ShopItem(this.emoji, this.price);

  final String emoji;
  final int price;
}

const shopItems = [
  ShopItem('🍎', 3),
  ShopItem('🍌', 4),
  ShopItem('🍞', 5),
  ShopItem('🥛', 8),
  ShopItem('🧃', 6),
  ShopItem('🍫', 7),
  ShopItem('🍪', 2),
  ShopItem('🥚', 9),
  ShopItem('🍬', 1),
  ShopItem('🧀', 10),
  ShopItem('🍦', 6),
  ShopItem('🥕', 2),
];

/// To'lov uchun pul kupyuralari (ming so'mda).
const shopBills = [10, 20, 50];

enum ShopLevel {
  two(label: AppStrings.shopLevelTwo, emoji: '🛒', items: 2, change: false),
  three(label: AppStrings.shopLevelThree, emoji: '🛍️', items: 3, change: false),
  change(label: AppStrings.shopLevelChange, emoji: '💵', items: 2, change: true);

  const ShopLevel({
    required this.label,
    required this.emoji,
    required this.items,
    required this.change,
  });

  final String label;
  final String emoji;
  final int items;

  /// true — xaridor pul beradi, qaytimni topish kerak.
  final bool change;
}

class ShopQuestion {
  const ShopQuestion(this.items, this.paid, this.options);

  final List<ShopItem> items;

  /// Berilgan pul (faqat "Qaytim" darajasida), aks holda null.
  final int? paid;

  /// 4 ta variant (ming so'mda), bittasi to'g'ri.
  final List<int> options;

  int get total => items.fold(0, (sum, item) => sum + item.price);
  int get answer => paid == null ? total : paid! - total;
}

enum ShopOutcome { correct, wrong, finished }

/// Do'kon: narxlarni qo'shish yoki qaytimni hisoblash. 10 ta savol.
class ShopGame {
  ShopGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = [for (var i = 0; i < questionCount; i++) makeQuestion(level, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final ShopLevel level;
  late final List<ShopQuestion> questions;
  int step = 0;
  int mistakes = 0;

  ShopQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static ShopQuestion makeQuestion(ShopLevel level, Random rnd) {
    final items = (List.of(shopItems)..shuffle(rnd)).take(level.items).toList();
    final total = items.fold(0, (sum, item) => sum + item.price);
    int? paid;
    if (level.change) {
      final bills = shopBills.where((b) => b > total).toList();
      paid = bills[rnd.nextInt(bills.length)];
    }
    final answer = paid == null ? total : paid - total;

    // Yaqin sonlar va (qaytimda) jami narx — odatiy xatolar.
    final candidates = <int>{
      answer + 1,
      answer - 1,
      answer + 2,
      answer - 2,
      answer + 10,
      answer - 10,
      if (paid != null) total,
    }.where((v) => v > 0 && v != answer).toList()
      ..shuffle(rnd);
    final options = [answer, ...candidates.take(optionCount - 1)]..shuffle(rnd);
    return ShopQuestion(items, paid, options);
  }

  ShopOutcome answer(int option) {
    if (option != current.answer) {
      mistakes++;
      return ShopOutcome.wrong;
    }
    step++;
    return isFinished ? ShopOutcome.finished : ShopOutcome.correct;
  }
}
