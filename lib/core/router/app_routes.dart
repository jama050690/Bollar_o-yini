/// Marshrut yo'llari. Ota-ona paneli 3-bosqichda qo'shiladi.
abstract final class AppRoutes {
  static const home = '/';
  static const profiles = '/profiles';
  static const profileCreate = '/profiles/create';
  static const result = '/result';

  static String game(String gameId) => '/game/$gameId';
}
