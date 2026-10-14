import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';

/// Kutilmagan xatolarni ushlaydi. Xatolar faqat qurilma konsoliga yoziladi —
/// hech qayerga yuborilmaydi (FR-9, analytics yo'q).
void installErrorHandlers() {
  // Asinxron (Future, platforma kanali) xatolari ilovani yiqitmasin.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Kutilmagan xato: $error\n$stack');
    return true;
  };

  // Release'da kulrang ekran o'rniga bolaga muloyim ekran ko'rsatiladi.
  // Debug'da esa dasturchi uchun odatiy qizil ekran qoladi.
  if (!kDebugMode) {
    ErrorWidget.builder = (details) => const AppErrorView();
  }
}

/// Bolani qo'rqitmaydigan xato ekrani.
///
/// [onRetry] berilsa "Qayta urinish" tugmasi chiqadi (ishga tushishdagi xato),
/// aks holda "Bosh menyuga" tugmasi.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, box) {
          // Xato kichik joyda (karta, ro'yxat ichida) bo'lsa — faqat belgi.
          if (!box.hasBoundedHeight || box.maxHeight < 320 || box.maxWidth < 260) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('🙈', style: TextStyle(fontSize: 40)),
              ),
            );
          }
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🦉', style: TextStyle(fontSize: 96)),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.errorTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.errorHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, color: AppColors.text),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: onRetry ?? () => GoRouter.maybeOf(context)?.go(AppRoutes.home),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(240, AppSizes.minTapTarget),
                        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      child: Text(
                        onRetry != null ? AppStrings.errorRetryButton : AppStrings.errorHomeButton,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Lokal baza ochilmasa ko'rsatiladigan ilova (Hive, Riverpod va routersiz).
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Aqlli Do'stlar",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppErrorView(onRetry: onRetry),
    );
  }
}
