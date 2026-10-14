import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Har bir yulduz uchun beriladigan tanga (★ = 5, ★★ = 10, ★★★ = 15).
const kCoinsPerStar = 5;

int coinsForStars(int stars) => stars * kCoinsPerStar;

/// Do'kondagi sovg'a: tanga bilan ochiladi. Haqiqiy pul ishlatilmaydi.
sealed class RewardItem {
  const RewardItem({required this.id, required this.price});

  /// Sotib olinganlar ro'yxatida saqlanadigan kalit.
  final String id;
  final int price;
}

/// Yangi avatar — sotib olingach profilga "kiyiladi".
class AvatarReward extends RewardItem {
  const AvatarReward(this.emoji, int price) : super(id: 'avatar:$emoji', price: price);

  final String emoji;
}

/// Bosh ekran foni.
class BackgroundReward extends RewardItem {
  const BackgroundReward({
    required String key,
    required this.emoji,
    required this.label,
    required this.colors,
    required super.price,
  }) : super(id: 'bg:$key');

  final String emoji;
  final String label;
  final List<Color> colors;
}

const kShopAvatars = [
  AvatarReward('🦄', 30),
  AvatarReward('🐧', 30),
  AvatarReward('🐨', 40),
  AvatarReward('🐯', 40),
  AvatarReward('🦉', 50),
  AvatarReward('🐙', 60),
  AvatarReward('🦖', 80),
  AvatarReward('🐲', 100),
];

const kDefaultBackgroundId = 'bg:default';

/// Bepul, har doim ochiq fon.
const kDefaultBackground = BackgroundReward(
  key: 'default',
  emoji: '☀️',
  label: AppStrings.bgDefault,
  colors: [AppColors.background, AppColors.background],
  price: 0,
);

/// Ranglar och tanlangan — matn har doim yaxshi o'qiladi.
const kBackgrounds = [
  kDefaultBackground,
  BackgroundReward(
    key: 'sky',
    emoji: '🌤️',
    label: AppStrings.bgSky,
    colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
    price: 20,
  ),
  BackgroundReward(
    key: 'meadow',
    emoji: '🌿',
    label: AppStrings.bgMeadow,
    colors: [Color(0xFFF1F8E9), Color(0xFFC5E1A5)],
    price: 30,
  ),
  BackgroundReward(
    key: 'candy',
    emoji: '🍭',
    label: AppStrings.bgCandy,
    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
    price: 40,
  ),
  BackgroundReward(
    key: 'sunset',
    emoji: '🌅',
    label: AppStrings.bgSunset,
    colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
    price: 50,
  ),
  BackgroundReward(
    key: 'space',
    emoji: '🌌',
    label: AppStrings.bgSpace,
    colors: [Color(0xFFEDE7F6), Color(0xFFB39DDB)],
    price: 60,
  ),
];

BackgroundReward backgroundById(String id) =>
    kBackgrounds.firstWhere((b) => b.id == id, orElse: () => kDefaultBackground);
