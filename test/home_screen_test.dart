import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/theme/app_theme.dart';
import 'package:gym_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets(
      'renders GymApp top header, group selector, ranking and feed in light theme',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('GymApp'), findsOneWidget);

    // Verify Group selector
    expect(find.text('Grupo Alpha'), findsOneWidget);

    // Verify Ranking Card and tabs
    expect(find.text('Ranking'), findsOneWidget);
    expect(find.text('Grupo'), findsOneWidget);
    expect(find.text('Amigos'), findsOneWidget);
    expect(find.text('Ver todos'), findsOneWidget);

    // Verify ranking users & animal badges
    expect(find.text('Rafael'), findsOneWidget);
    expect(find.text('Você'), findsOneWidget);
    expect(find.text('🦁 LEÃO'), findsNWidgets(2));

    // Verify feed item
    expect(find.text('Bruna'), findsOneWidget);
    expect(find.text('ode corrida ao amanhecer ☀️✨'), findsOneWidget);
    expect(find.text('46:30'), findsOneWidget);
    expect(find.text('432'), findsOneWidget);
  });

  testWidgets('renders HomeScreen correctly in dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GymApp'), findsOneWidget);
    expect(find.text('Ranking'), findsOneWidget);
    expect(find.text('Bruna'), findsOneWidget);
  });
}
