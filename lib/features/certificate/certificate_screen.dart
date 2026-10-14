import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/confetti_overlay.dart';
import '../../shared/widgets/mascot.dart';
import '../achievements/achievements_providers.dart';
import '../profile/profile_providers.dart';
import 'certificate_providers.dart';

const _gold = Color(0xFFFFB300);
const _brown = Color(0xFF6D4C41);

/// Guruhdagi barcha o'yinlarni o'tgan bolaga beriladigan sertifikat.
class CertificateScreen extends ConsumerStatefulWidget {
  const CertificateScreen({super.key});

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  String? _day;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(activeProfileProvider);
    if (profile != null && ref.read(certificateProvider).unlocked) {
      _day = certificateDay(profile.id, DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);
    final status = ref.watch(certificateProvider);
    final day = _day;

    // Ochilmagan sertifikatga to'g'ridan-to'g'ri kirib bo'lmaydi.
    if (profile == null || !status.unlocked || day == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.certificateButton)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppStrings.certificateLocked(status.gamesLeft),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: AppColors.text),
            ),
          ),
        ),
      );
    }

    final medals = ref.watch(unlockedMedalsProvider).length;
    final group = profile.ageGroup;
    final date = day.split('-').reversed.join('.');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 32,
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTapTarget,
            minHeight: AppSizes.minTapTarget,
          ),
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.achievements),
        ),
        title: Text(AppStrings.certificateButton),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF5),
                            borderRadius: BorderRadius.circular(AppSizes.radius - 6),
                            border: Border.all(color: group.color, width: 4),
                          ),
                          child: Column(
                            children: [
                              const Text('🏅🎓🏅', style: TextStyle(fontSize: 44)),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppStrings.certificateTitle,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                    color: _brown,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.certificateGiven,
                                style: TextStyle(fontSize: 18, color: AppColors.text),
                              ),
                              const SizedBox(height: 8),
                              Text(profile.avatar, style: const TextStyle(fontSize: 56)),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  profile.name,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              const Divider(color: _gold, thickness: 2, height: 24),
                              Text(
                                AppStrings.certificateFor('${group.emoji} ${group.title}'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, color: AppColors.text),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 24,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.certificateStars(status.totalStars),
                                    style: const TextStyle(fontSize: 20, color: AppColors.text),
                                  ),
                                  Text(
                                    AppStrings.certificateMedals(medals),
                                    style: const TextStyle(fontSize: 20, color: AppColors.text),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.certificateDate(date),
                                style: const TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Mascot(messages: AppStrings.certificatePraise),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.certificateSaveHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: ConfettiOverlay()),
        ],
      ),
    );
  }
}

/// Yutuqlar javonidagi sertifikat tugmasi: ochilgan bo'lsa — oltin, aks holda — qancha qolgani.
class CertificateButton extends ConsumerWidget {
  const CertificateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(certificateProvider);

    if (!status.unlocked) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: Colors.black12, width: 2),
        ),
        child: Column(
          children: [
            Text(
              AppStrings.certificateLocked(status.gamesLeft),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.certificateLockedHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => context.push(AppRoutes.certificate),
      style: ElevatedButton.styleFrom(
        backgroundColor: _gold,
        foregroundColor: _brown,
        minimumSize: const Size(double.infinity, 72),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      child: Text(AppStrings.certificateButton),
    );
  }
}
