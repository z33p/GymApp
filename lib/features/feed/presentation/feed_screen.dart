import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_providers.dart';
import '../../workouts/presentation/widgets/workout_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(feedWorkoutsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
      ),
      body: workouts.when(
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyFeed();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final workout = items[index];
              return WorkoutCard(
                workout: workout,
                onTap: workout.id == null ? null : () => context.push('/workouts/${workout.id}'),
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('Failed to load feed: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Connect Apple Health to import workouts automatically.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Imported workouts will appear here after your first sync.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
