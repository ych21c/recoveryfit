import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Top-level entry widget.
/// Platform initialization is handled by SplashScreen concurrently with its
/// animation, so the router (and SplashScreen) are visible on the very first
/// frame — which allows integration tests to find SplashScreen immediately
/// after pumpWidget.
class RecoveryFitApp extends StatelessWidget {
  const RecoveryFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _AppRouter());
  }
}

class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'RecoveryFit',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
