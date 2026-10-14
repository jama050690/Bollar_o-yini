import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import '../profile/profile_providers.dart';
import 'rewards_catalog.dart';

/// Bitta bolaning hamyoni: tangalar, sotib olingan sovg'alar va tanlangan fon.
class Wallet {
  const Wallet({this.coins = 0, this.owned = const {}, this.backgroundId = kDefaultBackgroundId});

  final int coins;
  final Set<String> owned;
  final String backgroundId;

  /// Bepul sovg'alar har doim "sotib olingan" hisoblanadi.
  bool owns(RewardItem item) => item.price == 0 || owned.contains(item.id);
}

// Hive `settings` qutisidagi kalitlar (profil bo'yicha alohida).
String _coinsKey(String profileId) => 'coins|$profileId';
String _ownedKey(String profileId) => 'owned|$profileId';
String _backgroundKey(String profileId) => 'background|$profileId';

/// Faol profilning hamyoni. Profil almashsa, o'sha bolaning hamyoni yuklanadi.
class WalletNotifier extends Notifier<Wallet> {
  String? _profileId;

  @override
  Wallet build() {
    final profileId = _profileId = ref.watch(activeProfileIdProvider);
    if (profileId == null) return const Wallet();

    final box = HiveStorage.settings;
    final owned = box.get(_ownedKey(profileId)) as List? ?? const [];
    return Wallet(
      coins: box.get(_coinsKey(profileId)) as int? ?? 0,
      owned: {...owned.cast<String>()},
      backgroundId: box.get(_backgroundKey(profileId)) as String? ?? kDefaultBackgroundId,
    );
  }

  void earn(int amount) {
    final profileId = _profileId;
    if (profileId == null || amount <= 0) return;
    _save(profileId, Wallet(
      coins: state.coins + amount,
      owned: state.owned,
      backgroundId: state.backgroundId,
    ));
  }

  /// Sovg'ani sotib oladi. Tanga yetmasa `false` qaytaradi.
  /// Allaqachon sotib olingan bo'lsa, qayta pul yechilmaydi.
  bool buy(RewardItem item) {
    final profileId = _profileId;
    if (profileId == null) return false;
    if (state.owns(item)) return true;
    if (state.coins < item.price) return false;

    _save(profileId, Wallet(
      coins: state.coins - item.price,
      owned: {...state.owned, item.id},
      backgroundId: state.backgroundId,
    ));
    return true;
  }

  void selectBackground(BackgroundReward background) {
    final profileId = _profileId;
    if (profileId == null || !state.owns(background)) return;
    _save(profileId, Wallet(
      coins: state.coins,
      owned: state.owned,
      backgroundId: background.id,
    ));
  }

  void _save(String profileId, Wallet wallet) {
    final box = HiveStorage.settings;
    box.put(_coinsKey(profileId), wallet.coins);
    box.put(_ownedKey(profileId), wallet.owned.toList());
    box.put(_backgroundKey(profileId), wallet.backgroundId);
    state = wallet;
  }
}

final walletProvider = NotifierProvider<WalletNotifier, Wallet>(WalletNotifier.new);
