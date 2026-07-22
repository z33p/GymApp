import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../l10n/app_localizations.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTitle)),
      body: stats.when(
        data: (value) {
          return GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              StatCard(label: 'Workouts this week', value: '${value.workoutsThisWeek}', icon: Icons.fitness_center_rounded),
              StatCard(label: 'Workouts this month', value: '${value.workoutsThisMonth}', icon: Icons.calendar_month_rounded),
              StatCard(label: 'Duration this week', value: Formatters.duration(value.totalDurationThisWeekSeconds), icon: Icons.timer_rounded),
              StatCard(label: 'Calories this week', value: '${value.totalCaloriesThisWeek.round()} kcal', icon: Icons.local_fire_department_rounded),
              StatCard(label: 'Distance this week', value: Formatters.distanceMeters(value.totalDistanceThisWeekMeters) ?? '0 m', icon: Icons.route_rounded),
              StatCard(label: 'Current streak', value: '${value.currentStreakDays} days', icon: Icons.bolt_rounded),
            ],
          );
        },
        error: (error, _) => Center(child: Text(l10n.failedToLoadProgress('$error'))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
