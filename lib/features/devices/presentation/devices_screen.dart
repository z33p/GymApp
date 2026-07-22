import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_providers.dart';
import '../domain/fitness_provider.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appleConnection =
        ref.watch(deviceConnectionProvider(FitnessProviderType.appleHealth));
    final appleSyncState =
        ref.watch(syncStateProvider(FitnessProviderType.appleHealth));
    final syncController = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connect Devices')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (Platform.isIOS)
            appleConnection.when(
              data: (connection) => _DeviceCard(
                title: 'Apple Health',
                subtitle:
                    'GymApp imports workouts recorded by Apple Watch or any app that saves workouts to Apple Health.',
                status: connection.isPreviewMode
                    ? 'Preview mode'
                    : connection.connected
                        ? 'Active'
                        : 'Not connected',
                helperText: connection.message,
                trailing: appleSyncState.when(
                  data: (state) => Text(
                    state?.lastSuccessfulSyncAt == null
                        ? 'No successful sync yet'
                        : 'Last sync: ${state!.lastSuccessfulSyncAt!.toLocal()}',
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
                primaryButtonLabel: 'Connect Apple Health',
                onPrimaryPressed: () async {
                  await ref
                      .read(syncControllerProvider.notifier)
                      .connectAppleHealth();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Apple Health connection updated.')),
                    );
                  }
                },
                secondaryButtonLabel: 'Sync now',
                onSecondaryPressed: () async {
                  await ref
                      .read(syncControllerProvider.notifier)
                      .syncAppleHealth();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout sync complete.')),
                    );
                  }
                },
              ),
              error: (error, _) =>
                  Text('Failed to load Apple Health status: $error'),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 16),
          const _ComingSoonCard(
            title: 'Health Connect',
            description:
                'Android import architecture is ready for future Health Connect support.',
          ),
          const SizedBox(height: 16),
          const _ComingSoonCard(
            title: 'Garmin',
            description:
                'Garmin sync is planned after the local-first MVP ships.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manual sync',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                      'Sync on demand and refresh the local feed from Apple Health or preview data.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: syncController.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(syncControllerProvider.notifier)
                                .syncAppleHealth();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Manual sync finished.')),
                              );
                            }
                          },
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Sync now'),
                  ),
                  if (syncController.hasError) ...[
                    const SizedBox(height: 12),
                    Text('Sync error: ${syncController.error}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.primaryButtonLabel,
    required this.secondaryButtonLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.helperText,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String status;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final String? helperText;
  final Widget? trailing;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleLarge)),
                Chip(label: Text(status)),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            if (helperText != null) ...[
              const SizedBox(height: 8),
              Text(helperText!),
            ],
            if (trailing != null) ...[
              const SizedBox(height: 8),
              trailing!,
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                    onPressed: onPrimaryPressed,
                    child: Text(primaryButtonLabel)),
                OutlinedButton.icon(
                  onPressed: onSecondaryPressed,
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(secondaryButtonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleLarge)),
                const Chip(label: Text('Coming soon')),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
