import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/config/app_providers.dart';
import 'package:gym_app/features/auth/domain/app_user.dart';
import 'package:gym_app/features/auth/domain/auth_repository.dart';
import 'package:gym_app/features/auth/presentation/login_screen.dart';

class FakeAuthRepository implements AuthRepository {
  bool debugSignedIn = false;

  final user = AppUser(
    id: 'debug-user',
    displayName: 'Debug User',
    username: 'debug',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  @override
  Future<void> clearUser() async => debugSignedIn = false;

  @override
  Future<AppUser?> getCurrentUser() async => debugSignedIn ? user : null;

  @override
  Future<AppUser> signInDebug() async {
    debugSignedIn = true;
    return user;
  }

  @override
  Future<void> signInWith(AuthProvider provider) async {
    throw AuthProviderNotConfiguredException(provider);
  }
}

Widget buildLogin(FakeAuthRepository auth) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      bootstrapProvider.overrideWith((ref) async {}),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  testWidgets('shows external providers and explicit debug entry', (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(buildLogin(auth));

    expect(find.text('Entre no GymApp'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('Continuar com Microsoft'), findsOneWidget);
    expect(find.text('Continuar com Apple'), findsOneWidget);
    expect(find.text('Entrar em modo desenvolvimento'), findsOneWidget);
  });

  testWidgets('debug entry creates a local session and remains explicit', (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(buildLogin(auth));

    await tester.tap(find.text('Entrar em modo desenvolvimento'));
    await tester.pumpAndSettle();

    expect(auth.debugSignedIn, isTrue);
    expect(find.textContaining('Nenhuma conta externa é criada.'), findsOneWidget);
  });

  testWidgets('unconfigured provider explains how to continue in debug', (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(buildLogin(auth));

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Google ainda não está conectado'), findsOneWidget);
    expect(find.text('Entre no GymApp'), findsOneWidget);
  });
}
