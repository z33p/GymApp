import 'package:flutter/material.dart';

import '../../../../core/design_system/ds_theme.dart';
import '../../../../core/design_system/widgets/ds_card.dart';
import '../../../../core/design_system/widgets/ds_gap.dart';
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
    final dsTheme = context.dsTheme;

    return DsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  workout.displayActivityType,
                  style: dsTheme.typography.titleMedium,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: dsTheme.spacing.s,
                  vertical: dsTheme.spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(workout.platform.label),
              ),
            ],
          ),
          DsGap.xs(context),
          Text(
            Formatters.dateTime(workout.startTime),
            style: dsTheme.typography.caption,
          ),
          DsGap.s(context),
          Wrap(
            spacing: dsTheme.spacing.xs,
            runSpacing: dsTheme.spacing.xs,
            children: [
              _FactChip(label: Formatters.duration(workout.durationSeconds)),
              if (Formatters.calories(workout.activeEnergyKcal)
                  case final calories?)
                _FactChip(label: calories),
              if (Formatters.distanceMeters(workout.distanceMeters)
                  case final distance?)
                _FactChip(label: distance),
              _FactChip(label: workout.displaySource),
            ],
          ),
        ],
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
