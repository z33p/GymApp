import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/imported_workout.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    required this.workout,
    this.onTap,
    super.key,
  });

  final ImportedWorkout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.displayActivityType,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(workout.platform.label),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(Formatters.dateTime(workout.startTime)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FactChip(label: Formatters.duration(workout.durationSeconds)),
                  if (Formatters.calories(workout.activeEnergyKcal) case final calories?) _FactChip(label: calories),
                  if (Formatters.distanceMeters(workout.distanceMeters) case final distance?) _FactChip(label: distance),
                  _FactChip(label: workout.displaySource),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
