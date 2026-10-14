import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';
import 'profile.dart';

/// Barcha profillar ro'yxati (oila uchun bir nechta profil).
class ProfilesNotifier extends Notifier<List<Profile>> {
  @override
  List<Profile> build() {
    return HiveStorage.profiles.values.map(Profile.fromMap).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Profile add({required String name, required int age, required String avatar}) {
    final now = DateTime.now();
    final profile = Profile(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      age: age,
      avatar: avatar,
      createdAt: now,
    );
    HiveStorage.profiles.put(profile.id, profile.toMap());
    state = [...state, profile];
    return profile;
  }

  /// Sovg'alar do'konidan olingan avatarni "kiyish".
  void updateAvatar(String id, String avatar) {
    state = [
      for (final p in state)
        if (p.id == id)
          Profile(id: p.id, name: p.name, age: p.age, avatar: avatar, createdAt: p.createdAt)
        else
          p,
    ];
    final updated = state.firstWhere((p) => p.id == id);
    HiveStorage.profiles.put(id, updated.toMap());
  }
}

final profilesProvider =
    NotifierProvider<ProfilesNotifier, List<Profile>>(ProfilesNotifier.new);

/// Hozir o'ynayotgan profil id si. Ilova qayta ochilganda tiklanadi.
class ActiveProfileIdNotifier extends Notifier<String?> {
  static const _key = 'activeProfileId';

  @override
  String? build() => HiveStorage.settings.get(_key) as String?;

  void select(String id) {
    HiveStorage.settings.put(_key, id);
    state = id;
  }
}

final activeProfileIdProvider =
    NotifierProvider<ActiveProfileIdNotifier, String?>(ActiveProfileIdNotifier.new);

final activeProfileProvider = Provider<Profile?>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  for (final profile in ref.watch(profilesProvider)) {
    if (profile.id == id) return profile;
  }
  return null;
});
