import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_providers.dart';
import '../../../core/design_system/ds_theme.dart';
import '../../../core/design_system/widgets/ds_gap.dart';
import 'widgets/workout_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allWorkouts = ref.watch(allWorkoutsProvider).value ?? const [];
    final workouts = ref.watch(historyWorkoutsProvider);
    final calculator = ref.watch(workoutStatsCalculatorProvider);
    final activities = calculator.distinctActivities(allWorkouts);
    final sources = calculator.distinctSources(allWorkouts);
    final filters = ref.watch(historyFiltersProvider);
    final spacing = context.dsSpacing;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.l, 0, spacing.l, spacing.m),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search workouts or sources',
                  ),
                  onChanged: (value) {
                    ref.read(historyFiltersProvider.notifier).state = filters.copyWith(query: value);
                  },
                ),
                DsGap.s(context),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        initialValue: filters.activityType,
                        hint: const Text('Activity', overflow: TextOverflow.ellipsis),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All activities', overflow: TextOverflow.ellipsis),
                          ),
                          ...activities.map<DropdownMenuItem<String?>>(
                            (activity) => DropdownMenuItem<String?>(
                              value: activity,
                              child: Text(activity.replaceAll('_', ' '), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(historyFiltersProvider.notifier).state = filters.copyWith(
                                activityType: value,
                                clearActivityType: value == null,
                              );
                        },
                      ),
                    ),
                    DsGap.s(context, horizontal: true),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        initialValue: filters.sourceName,
                        hint: const Text('Source', overflow: TextOverflow.ellipsis),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All sources', overflow: TextOverflow.ellipsis),
                          ),
                          ...sources.map<DropdownMenuItem<String?>>(
                            (source) => DropdownMenuItem<String?>(
                              value: source,
                              child: Text(source, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(historyFiltersProvider.notifier).state = filters.copyWith(
                                sourceName: value,
                                clearSourceName: value == null,
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: workouts.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No workouts match your current filters.'));
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(spacing.l, 0, spacing.l, spacing.l),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => DsGap.s(context),
                  itemBuilder: (context, index) {
                    final workout = items[index];
                    return WorkoutCard(
                      workout: workout,
                      onTap: workout.id == null ? null : () => context.push('/workouts/${workout.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading history: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
