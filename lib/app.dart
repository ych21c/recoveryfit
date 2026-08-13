import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';

class RecoveryFitApp extends StatelessWidget {
  const RecoveryFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _AppBody());
  }
}

class _AppBody extends ConsumerWidget {
  const _AppBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure StorageService is initialized before router
    return FutureBuilder(
      future: StorageService.instance.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xFF0D1B2A),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
              ),
            ),
          );
        }
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'RecoveryFit',
          theme: AppTheme.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
