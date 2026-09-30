import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/age_group.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import 'profile.dart';
import 'profile_providers.dart';

/// Profil yaratish (FR-1): ism, yosh, avatar.
class ProfileCreateScreen extends ConsumerStatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  ConsumerState<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends ConsumerState<ProfileCreateScreen> {
  final _nameController = TextEditingController();
  int? _age;
  String _avatar = kAvatars.first;

  bool get _canSave => _nameController.text.trim().isNotEmpty && _age != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final profile = ref.read(profilesProvider.notifier).add(
          name: _nameController.text.trim(),
          age: _age!,
          avatar: _avatar,
        );
    ref.read(activeProfileIdProvider.notifier).select(profile.id);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        leading: context.canPop()
            ? IconButton(
                iconSize: 36,
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(AppStrings.createProfileTitle, style: textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(AppStrings.avatarLabel, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final avatar in kAvatars)
                  _SelectableCircle(
                    selected: avatar == _avatar,
                    onTap: () => setState(() => _avatar = avatar),
                    child: Text(avatar, style: const TextStyle(fontSize: 40)),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Text(AppStrings.nameLabel, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 28),
              decoration: InputDecoration(
                hintText: AppStrings.nameHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.ageLabel, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var age = AgeGroup.minSupportedAge; age <= AgeGroup.maxSupportedAge; age++)
                  _SelectableCircle(
                    selected: age == _age,
                    color: AgeGroup.fromAge(age).color,
                    onTap: () => setState(() => _age = age),
                    child: Text(
                      '$age',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(72),
              ),
              child: const Text(AppStrings.saveProfile),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableCircle extends StatelessWidget {
  const _SelectableCircle({
    required this.selected,
    required this.onTap,
    required this.child,
    this.color = Colors.white,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.black12,
            width: selected ? 5 : 2,
          ),
        ),
        child: child,
      ),
    );
  }
}
