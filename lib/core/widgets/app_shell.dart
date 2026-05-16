import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const tabs = [
    ('/feed', 'Feed', Icons.dynamic_feed_rounded),
    ('/history', 'History', Icons.history_rounded),
    ('/progress', 'Progress', Icons.bar_chart_rounded),
    ('/devices', 'Devices', Icons.watch_rounded),
    ('/settings', 'Settings', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = tabs.indexWhere((tab) => location == tab.$1 || location.startsWith('${tab.$1}/'));

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.$3),
              label: tab.$2,
            ),
        ],
        onDestinationSelected: (value) => context.go(tabs[value].$1),
      ),
    );
  }
}
