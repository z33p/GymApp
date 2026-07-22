import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/gamification/domain/fauna_rank.dart';
import 'package:gym_app/features/gamification/presentation/fauna_mascot.dart';

void main() {
  testWidgets('renders every fauna tier with its mascot and semantics',
      (tester) async {
    final semantics = tester.ensureSemantics();
    for (final tier in FaunaTier.values) {
      final rank = FaunaRank(
        tier: tier,
        formPoints: tier.minimumPoints,
        legacyPoints: tier.minimumPoints,
        nextTier:
            tier == FaunaTier.apex ? null : FaunaTier.values[tier.index + 1],
        nextTierPoints: tier == FaunaTier.apex
            ? null
            : FaunaTier.values[tier.index + 1].minimumPoints,
      );

      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: FaunaMascot(rank: rank))));

      expect(find.text(tier.label), findsOneWidget);
      expect(find.text(tier.mascot), findsOneWidget);
      expect(
          find.bySemanticsLabel(
              '${tier.label}, ${tier.minimumPoints} pontos de Forma'),
          findsOneWidget);
    }
    semantics.dispose();
  });

  testWidgets('renders the current animal and its progress', (tester) async {
    final semantics = tester.ensureSemantics();
    const rank = FaunaRank(
      tier: FaunaTier.bear,
      formPoints: 3,
      legacyPoints: 8,
      nextTier: FaunaTier.rhino,
      nextTierPoints: 4,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FaunaMascot(rank: rank)),
      ),
    );

    expect(find.text('Urso'), findsOneWidget);
    expect(find.text('🐻'), findsOneWidget);
    expect(find.text('3 Forma • 8 Legado'), findsOneWidget);
    expect(find.bySemanticsLabel('Urso, 3 pontos de Forma'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('renders the apex identity without choosing a faction',
      (tester) async {
    const rank = FaunaRank(
      tier: FaunaTier.apex,
      formPoints: 12,
      legacyPoints: 20,
      nextTier: null,
      nextTierPoints: null,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FaunaMascot(rank: rank, compact: true)),
      ),
    );

    expect(find.text('Leão ou Dragão'), findsOneWidget);
    expect(find.text('🦁🐉'), findsOneWidget);
  });
}
