import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../shared/widgets/choice_card.dart';
import 'profile_providers.dart';

/// "Kim o'ynaydi?" — oiladagi profillardan birini tanlash.
class ProfileSelectScreen extends ConsumerWidget {
  const ProfileSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              AppStrings.whoPlays,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final profile in profiles)
                  ChoiceCard(
                    emoji: profile.avatar,
                    label: profile.name,
                    color: profile.ageGroup.color,
                    onTap: () {
                      ref.read(activeProfileIdProvider.notifier).select(profile.id);
                      context.go(AppRoutes.home);
                    },
                  ),
                ChoiceCard(
                  emoji: '➕',
                  label: AppStrings.addProfile,
                  color: Colors.white,
                  onTap: () => context.push(AppRoutes.profileCreate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
