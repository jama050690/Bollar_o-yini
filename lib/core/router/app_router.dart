import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';

/// Marshrut nomlari. Qolgan ekranlar (profil, o'yin, natija, ota-ona paneli)
/// 1.2-qadamda qo'shiladi.
abstract final class AppRoutes {
  static const home = '/';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
