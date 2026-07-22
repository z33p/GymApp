import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_providers.dart';
import '../../../core/config/app_settings.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsControllerProvider);
    final syncController = ref.watch(syncControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(user.value?.displayName ?? l10n.localAthlete),
              subtitle: Text('@${user.value?.username ?? 'gymapp'}'),
            ),
          ),
          const SizedBox(height: 16),
          settings.when(
            data: (value) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<AppThemePreference>(
                      initialValue: value.themePreference,
                      decoration: const InputDecoration(labelText: 'Theme'),
                      items: AppThemePreference.values
                          .map((theme) => DropdownMenuItem(value: theme, child: Text(theme.name)))
                          .toList(),
                      onChanged: (selection) {
                        if (selection != null) {
                          ref.read(settingsControllerProvider.notifier).updateTheme(selection);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AppUnits>(
                      initialValue: value.units,
                      decoration: const InputDecoration(labelText: 'Units'),
                      items: AppUnits.values
                          .map((units) => DropdownMenuItem(value: units, child: Text(units.name)))
                          .toList(),
                      onChanged: (selection) {
                        if (selection != null) {
                          ref.read(settingsControllerProvider.notifier).updateUnits(selection);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            error: (error, _) => Text(l10n.failedToLoadSettings('$error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.localDataTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.localDataDescription),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: syncController.isLoading
                        ? null
                        : () async {
                            await ref.read(syncControllerProvider.notifier).clearLocalData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.localDataCleared)),
                              );
                            }
                          },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.clearLocalData),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
