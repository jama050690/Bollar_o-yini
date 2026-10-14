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
    required String Function() label,
    required this.colors,
    required super.price,
  })  : _label = label,
        super(id: 'bg:$key');

  final String emoji;
  final String Function() _label;
  String get label => _label();
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

// Fon nomlari joriy tilda olinadi (const katalogda funksiya sifatida saqlanadi).
String _bgDefault() => AppStrings.bgDefault;
String _bgSky() => AppStrings.bgSky;
String _bgMeadow() => AppStrings.bgMeadow;
String _bgCandy() => AppStrings.bgCandy;
String _bgSunset() => AppStrings.bgSunset;
String _bgSpace() => AppStrings.bgSpace;

/// Bepul, har doim ochiq fon.
const kDefaultBackground = BackgroundReward(
  key: 'default',
  emoji: '☀️',
  label: _bgDefault,
  colors: [AppColors.background, AppColors.background],
  price: 0,
);

/// Ranglar och tanlangan — matn har doim yaxshi o'qiladi.
const kBackgrounds = [
  kDefaultBackground,
  BackgroundReward(
    key: 'sky',
    emoji: '🌤️',
    label: _bgSky,
    colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
    price: 20,
  ),
  BackgroundReward(
    key: 'meadow',
    emoji: '🌿',
    label: _bgMeadow,
    colors: [Color(0xFFF1F8E9), Color(0xFFC5E1A5)],
    price: 30,
  ),
  BackgroundReward(
    key: 'candy',
    emoji: '🍭',
    label: _bgCandy,
    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
    price: 40,
  ),
  BackgroundReward(
    key: 'sunset',
    emoji: '🌅',
    label: _bgSunset,
    colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
    price: 50,
  ),
  BackgroundReward(
    key: 'space',
    emoji: '🌌',
    label: _bgSpace,
    colors: [Color(0xFFEDE7F6), Color(0xFFB39DDB)],
    price: 60,
  ),
];

BackgroundReward backgroundById(String id) =>
    kBackgrounds.firstWhere((b) => b.id == id, orElse: () => kDefaultBackground);
