import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_providers.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return currentUser.when(
      loading: () => const Material(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => Material(child: Center(child: Text('Could not load session: $error'))),
      data: (user) => user == null ? const LoginScreen() : child,
    );
  }
}
