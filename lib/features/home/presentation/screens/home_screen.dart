import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Placeholder post-login landing. Confirms the platform connection and shows
/// the signed-in user; real dashboards (shipments/tracking/wallet) come later.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('CBEX'),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.secondary, size: 56),
              const SizedBox(height: 16),
              Text(
                'مرحبًا، ${user?.name ?? ''}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(user?.email ?? '',
                  style: const TextStyle(color: Color(0xFF8693A8))),
              const SizedBox(height: 4),
              Text('الصلاحيات: ${user?.permissions.length ?? 0}',
                  style: const TextStyle(color: Color(0xFF8693A8))),
              const SizedBox(height: 24),
              const Text(
                'تم الاتصال بالمنصة بنجاح. الشاشات القادمة (الشحنات / التتبّع / المحفظة) قيد البناء.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF4A5870), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
