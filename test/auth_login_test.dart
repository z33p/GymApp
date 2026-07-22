import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/config/app_providers.dart';
import 'package:gym_app/features/auth/domain/app_user.dart';
import 'package:gym_app/features/auth/domain/auth_repository.dart';
import 'package:gym_app/features/auth/presentation/login_screen.dart';
import 'package:gym_app/features/auth/presentation/auth_gate.dart';
import 'package:gym_app/features/devices/domain/fitness_import_repository.dart';
import 'package:gym_app/features/devices/domain/fitness_provider.dart';

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

class CountingFitnessImportRepository implements FitnessImportRepository {
  int syncCalls = 0;

  @override
  Future<FitnessSyncResult> sync(FitnessProviderType provider,
      {bool manual = false}) async {
    syncCalls++;
    throw StateError('sync should not be called without a session');
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
  testWidgets('shows external providers and explicit debug entry',
      (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(buildLogin(auth));

    expect(find.text('Entre no GymApp'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('Continuar com Microsoft'), findsOneWidget);
    expect(find.text('Continuar com Apple'), findsOneWidget);
    expect(find.text('Entrar em modo desenvolvimento'), findsOneWidget);
  });

  testWidgets('debug entry creates a local session and remains explicit',
      (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(buildLogin(auth));

    await tester.tap(find.text('Entrar em modo desenvolvimento'));
    await tester.pumpAndSettle();

    expect(auth.debugSignedIn, isTrue);
    expect(
        find.textContaining('Nenhuma conta externa é criada.'), findsOneWidget);
  });

  testWidgets('unconfigured provider explains how to continue in debug',
      (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(buildLogin(auth));

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Google ainda não está conectado'), findsOneWidget);
    expect(find.text('Entre no GymApp'), findsOneWidget);
  });

  testWidgets('external buttons expose the same not-configured contract',
      (tester) async {
    for (final entry in <({String button, String provider})>[
      (button: 'Continuar com Microsoft', provider: 'Microsoft'),
      (button: 'Continuar com Apple', provider: 'Apple'),
    ]) {
      final auth = FakeAuthRepository();
      await tester.pumpWidget(buildLogin(auth));
      await tester.tap(find.text(entry.button));
      await tester.pumpAndSettle();
      expect(find.textContaining('${entry.provider} ainda não está conectado'),
          findsOneWidget);
    }
  });

  testWidgets('debug entry passes through AuthGate to the app', (tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          currentUserProvider.overrideWith(
              (ref) async => auth.debugSignedIn ? auth.user : null),
          bootstrapProvider.overrideWith((ref) async {}),
        ],
        child: const MaterialApp(home: AuthGate(child: Text('Habitat'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.text('Entrar em modo desenvolvimento'));
    await tester.pumpAndSettle();
    expect(find.text('Habitat'), findsOneWidget);
  });

  testWidgets('existing local session opens the app without login',
      (tester) async {
    final auth = FakeAuthRepository()..debugSignedIn = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          currentUserProvider.overrideWith((ref) async => auth.user),
        ],
        child: const MaterialApp(home: AuthGate(child: Text('Habitat'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Habitat'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  test('bootstrap without a session does not create a user or sync', () async {
    final auth = FakeAuthRepository();
    final fitness = CountingFitnessImportRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        fitnessImportRepositoryProvider.overrideWithValue(fitness),
      ],
    );
    addTearDown(container.dispose);

    await container.read(bootstrapProvider.future);
    expect(await auth.getCurrentUser(), isNull);
    expect(fitness.syncCalls, 0);
  });
}
