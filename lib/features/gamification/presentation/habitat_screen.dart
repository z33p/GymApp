import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_providers.dart';
import '../../workouts/domain/imported_workout.dart';
import '../domain/fauna_rank.dart';
import 'fauna_mascot.dart';

class HabitatScreen extends ConsumerWidget {
  const HabitatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rank = ref.watch(faunaProgressProvider);
    final workouts = ref.watch(feedWorkoutsProvider);
    final syncState = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habitat')),
      body: rank.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load your Habitat: $error')),
        data: (value) => _HabitatContent(
          rank: value,
          workouts: workouts.valueOrNull ?? const [],
          isSyncing: syncState.isLoading,
          onSync: () => ref.read(syncControllerProvider.notifier).syncAppleHealth(),
        ),
      ),
    );
  }
}

class _HabitatContent extends StatelessWidget {
  const _HabitatContent({
    required this.rank,
    required this.workouts,
    required this.isSyncing,
    required this.onSync,
  });

  final FaunaRank rank;
  final List<ImportedWorkout> workouts;
  final bool isSyncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = rank.nextTierPoints == null ? 1.0 : rank.formPoints / rank.nextTierPoints!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaunaMascot(rank: rank),
                const SizedBox(height: 20),
                Text(
                  rank.isAtApex ? 'Você alcançou o ápice da fauna.' : '${rank.pointsToNext} treinos para ${rank.nextTier!.label}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress.clamp(0, 1)),
                const SizedBox(height: 8),
                Text('Forma atual • ${rank.formPoints} pontos'),
                Text('Legado anual • ${rank.legacyPoints} treinos'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: isSyncing ? null : onSync,
          icon: isSyncing ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync_rounded),
          label: Text(isSyncing ? 'Sincronizando...' : 'Sincronizar agora'),
        ),
        const SizedBox(height: 24),
        Text('Atividade recente', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (workouts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Seu Habitat começa com o próximo treino. Sincronize uma fonte para evoluir de Rato.'),
            ),
          )
        else
          for (final workout in workouts.take(3))
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center_rounded),
                title: Text(workout.displayActivityType),
                subtitle: Text(workout.displaySource),
                trailing: Text('${workout.durationSeconds ~/ 60} min'),
              ),
            ),
      ],
    );
  }
}
