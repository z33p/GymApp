import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GymApp()));
}

class GymApp extends ConsumerStatefulWidget {
  const GymApp({super.key});

  @override
  ConsumerState<GymApp> createState() => _GymAppState();
}

class _GymAppState extends ConsumerState<GymApp> with WidgetsBindingObserver {
  late final router = createRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(() => ref.read(bootstrapProvider.future));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncControllerProvider.notifier).syncAppleHealth(manual: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final bootstrap = ref.watch(bootstrapProvider);
    final bootstrapSyncWarning = ref.watch(bootstrapSyncWarningProvider);

    return MaterialApp.router(
      title: 'GymApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings?.themeMode ?? ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        final content = bootstrap.when(
          data: (_) => AuthGate(child: child ?? const SizedBox.shrink()),
          error: (error, _) => Material(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('GymApp could not finish startup.'),
                    const SizedBox(height: 12),
                    Text('$error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(bootstrapProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          loading: () => const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );

        if (bootstrapSyncWarning == null || bootstrap.isLoading || bootstrap.hasError) {
          return content;
        }

        return Column(
          children: [
            MaterialBanner(
              content: Text(bootstrapSyncWarning),
              actions: [
                TextButton(
                  onPressed: () => ref.read(syncControllerProvider.notifier).syncAppleHealth(),
                  child: const Text('Retry sync'),
                ),
                TextButton(
                  onPressed: () => ref.read(bootstrapSyncWarningProvider.notifier).state = null,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}
