import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Maxfiylik siyosati (Apple 5.1.1). Matn ilova ichida — internetsiz ham o'qiladi.
/// Faqat PIN bilan ochilgan ota-ona panelidan kiriladi (router tekshiradi).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = AppStrings.privacySections(AppInfo.author, AppInfo.email);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.privacyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppStrings.privacyEffective(AppInfo.privacyEffectiveDate),
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            for (final (title, body) in sections)
              _Card(
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(body, style: const TextStyle(fontSize: 17, height: 1.5)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Ilova haqida: nom, versiya, xavfsizlik belgilari va aloqa.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.aboutTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Card(
              children: [
                const Center(child: Text('🧠', style: TextStyle(fontSize: 72))),
                Center(
                  child: Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    AppStrings.aboutVersion(AppInfo.displayVersion),
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.aboutDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
            _Card(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final badge in AppStrings.aboutBadges)
                      Chip(
                        label: Text(badge, style: const TextStyle(fontSize: 16)),
                        backgroundColor: AppColors.background,
                      ),
                  ],
                ),
              ],
            ),
            _Card(
              children: [
                Text(
                  AppStrings.aboutAuthor(AppInfo.author),
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(AppStrings.aboutContact, style: const TextStyle(fontSize: 17)),
                // Tashqi havola emas (Kids kategoriyasi): faqat nusxa olish mumkin.
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
                  child: Row(
                    children: [
                      const Expanded(
                        child: SelectableText(
                          AppInfo.email,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        iconSize: 28,
                        constraints: const BoxConstraints(
                          minWidth: AppSizes.minTapTarget,
                          minHeight: AppSizes.minTapTarget,
                        ),
                        tooltip: AppStrings.copy,
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(const ClipboardData(text: AppInfo.email));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(AppStrings.copied)));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
