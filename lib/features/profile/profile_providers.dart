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
