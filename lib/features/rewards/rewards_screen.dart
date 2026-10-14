import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/services/sound_service.dart';
import '../profile/profile_providers.dart';
import 'rewards_catalog.dart';
import 'rewards_providers.dart';

/// Sovg'alar do'koni: o'ynab yig'ilgan tangalarga avatar va fon ochiladi.
/// Haqiqiy pul ishlatilmaydi — faqat o'yindagi tangalar.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text, style: const TextStyle(fontSize: 20))));
  }

  /// Sotib olinmagan bo'lsa sotib oladi. Muvaffaqiyatli bo'lsa `true`.
  bool _acquire(BuildContext context, WidgetRef ref, RewardItem item) {
    final wallet = ref.read(walletProvider);
    if (wallet.owns(item)) return true;

    final sound = ref.read(soundServiceProvider);
    if (!ref.read(walletProvider.notifier).buy(item)) {
      sound.play(SoundService.tryAgain);
      _showMessage(context, AppStrings.rewardsNotEnough);
      return false;
    }
    sound.play(SoundService.win);
    _showMessage(context, AppStrings.rewardsBought);
    return true;
  }

  void _onAvatar(BuildContext context, WidgetRef ref, AvatarReward item) {
    final profile = ref.read(activeProfileProvider);
    if (profile == null || !_acquire(context, ref, item)) return;
    ref.read(profilesProvider.notifier).updateAvatar(profile.id, item.emoji);
  }

  void _onBackground(BuildContext context, WidgetRef ref, BackgroundReward item) {
    if (!_acquire(context, ref, item)) return;
    ref.read(walletProvider.notifier).selectBackground(item);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final profile = ref.watch(activeProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.rewardsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                AppStrings.coins(wallet.coins),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(AppStrings.rewardsAvatars, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in kShopAvatars)
                  _RewardCard(
                    preview: Text(item.emoji, style: const TextStyle(fontSize: 52)),
                    price: item.price,
                    owned: wallet.owns(item),
                    selected: profile?.avatar == item.emoji,
                    onTap: () => _onAvatar(context, ref, item),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Text(AppStrings.rewardsBackgrounds, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in kBackgrounds)
                  _RewardCard(
                    preview: Container(
                      width: 96,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.colors,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(item.emoji, style: const TextStyle(fontSize: 32)),
                    ),
                    label: item.label,
                    price: item.price,
                    owned: wallet.owns(item),
                    selected: wallet.backgroundId == item.id,
                    onTap: () => _onBackground(context, ref, item),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bitta sovg'a kartasi: rasm, (nomi) va holati — narx / "Tanlash" / "Tanlangan".
class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.preview,
    required this.price,
    required this.owned,
    required this.selected,
    required this.onTap,
    this.label,
  });

  final Widget preview;
  final String? label;
  final int price;
  final bool owned;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = selected
        ? AppStrings.rewardsSelected
        : owned
            ? AppStrings.rewardsSelect
            : AppStrings.price(price);

    return Material(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: BorderSide(
          color: selected ? AppColors.primary : Colors.transparent,
          width: 4,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: selected ? null : onTap,
        child: SizedBox(
          width: 140,
          height: label == null ? 140 : 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              preview,
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(label!, style: const TextStyle(fontSize: 18, color: AppColors.text)),
              ],
              const SizedBox(height: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: owned ? AppColors.text : const Color(0xFFF57F17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
