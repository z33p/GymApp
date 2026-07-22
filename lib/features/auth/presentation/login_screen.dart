import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_providers.dart';
import '../domain/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  AuthProvider? _loadingProvider;
  String? _errorMessage;

  Future<void> _signInDebug() async {
    setState(() {
      _loadingProvider = null;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInDebug();
      ref.invalidate(currentUserProvider);
      ref.invalidate(bootstrapProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage =
          'Não foi possível iniciar o modo de desenvolvimento: $error');
    }
  }

  Future<void> _signInExternal(AuthProvider provider) async {
    setState(() {
      _loadingProvider = provider;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWith(provider);
    } on AuthProviderNotConfiguredException {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _errorMessage =
            '${_providerLabel(provider)} ainda não está conectado ao backend. Use o modo de desenvolvimento para continuar.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _errorMessage = 'Não foi possível iniciar o login: $error';
      });
    }
  }

  String _providerLabel(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => 'Google',
      AuthProvider.microsoft => 'Microsoft',
      AuthProvider.apple => 'Apple',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = _loadingProvider != null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(Icons.pets_rounded,
                              color: theme.colorScheme.onPrimary, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Seu treino.\nSua fauna.',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Entre no GymApp',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Crie sua identidade para acompanhar sua evolução, grupos e ranking.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _ProviderButton(
                    label: 'Continuar com Google',
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: isBusy
                        ? null
                        : () => _signInExternal(AuthProvider.google),
                  ),
                  const SizedBox(height: 12),
                  _ProviderButton(
                    label: 'Continuar com Microsoft',
                    icon: Icons.window_rounded,
                    onPressed: isBusy
                        ? null
                        : () => _signInExternal(AuthProvider.microsoft),
                  ),
                  const SizedBox(height: 12),
                  _ProviderButton(
                    label: 'Continuar com Apple',
                    icon: Icons.apple,
                    onPressed: isBusy
                        ? null
                        : () => _signInExternal(AuthProvider.apple),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('DESENVOLVIMENTO',
                              style: theme.textTheme.labelSmall),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _signInDebug,
                      icon: const Icon(Icons.developer_mode_rounded),
                      label: Text(_loadingProvider == null
                          ? 'Entrar em modo desenvolvimento'
                          : 'Conectando...'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usa um perfil local de debug. Nenhuma conta externa é criada.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(_errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton(
      {required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          alignment: Alignment.centerLeft),
    );
  }
}
