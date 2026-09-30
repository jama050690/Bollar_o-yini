import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/games/game_catalog.dart';
import '../../features/games/game_result.dart';
import '../../features/games/result/result_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/profile_create_screen.dart';
import '../../features/profile/profile_providers.dart';
import '../../features/profile/profile_select_screen.dart';
import 'app_routes.dart';

export 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    // Foydalanuvchi oqimi (TZ 3-bo'lim):
    // profil yo'q → yaratish (FR-1); faol profil yo'q → tanlash; aks holda → bosh menyu.
    redirect: (context, state) {
      final location = state.matchedLocation;
      final hasProfiles = ref.read(profilesProvider).isNotEmpty;
      final hasActive = ref.read(activeProfileProvider) != null;

      if (!hasProfiles && location != AppRoutes.profileCreate) {
        return AppRoutes.profileCreate;
      }
      if (hasProfiles && !hasActive && !location.startsWith(AppRoutes.profiles)) {
        return AppRoutes.profiles;
      }
      if (location == AppRoutes.result && state.extra is! GameResult) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profiles,
        builder: (context, state) => const ProfileSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileCreate,
        builder: (context, state) => const ProfileCreateScreen(),
      ),
      GoRoute(
        path: '/game/:gameId',
        redirect: (context, state) =>
            gameById(state.pathParameters['gameId']!) == null ? AppRoutes.home : null,
        builder: (context, state) => gameById(state.pathParameters['gameId']!)!.builder(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => ResultScreen(result: state.extra! as GameResult),
      ),
    ],
  );
});
