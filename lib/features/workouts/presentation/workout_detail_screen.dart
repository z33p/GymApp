import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_providers.dart';
import '../../../core/utils/formatters.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.workoutId, super.key});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutByIdProvider(workoutId));
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Detail')),
      body: workout.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Workout not found.'));
          }
          final facts = <MapEntry<String, String?>>[
            MapEntry('Activity', item.displayActivityType),
            MapEntry('Start', Formatters.dateTime(item.startTime)),
            MapEntry('End', Formatters.dateTime(item.endTime)),
            MapEntry('Duration', Formatters.duration(item.durationSeconds)),
            MapEntry('Calories', Formatters.calories(item.activeEnergyKcal)),
            MapEntry('Distance', Formatters.distanceMeters(item.distanceMeters)),
            MapEntry('Source', item.displaySource),
            MapEntry('Imported', Formatters.dateTime(item.importedAt)),
          ];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      for (final fact in facts.where((entry) => entry.value != null)) ...[
                        Row(
                          children: [
                            Expanded(child: Text(fact.key)),
                            Expanded(
                              child: Text(
                                fact.value!,
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
              if (kDebugMode && item.rawPayload != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(const JsonEncoder.withIndent('  ').convert(item.rawPayload)),
                  ),
                ),
              ],
            ],
          );
        },
        error: (error, _) => Center(child: Text('Failed to load workout: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
