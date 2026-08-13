import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';

class RecoveryFitApp extends ConsumerWidget {
  const RecoveryFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure StorageService is initialized before router
    return FutureBuilder(
      future: StorageService.instance.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
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
