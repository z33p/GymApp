import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final l10n = AppLocalizations.of(context)!;

    final leftTabs = [
      ('/home', l10n.homeTitle, Icons.home_rounded),
      ('/progress', l10n.progressTitle, Icons.bar_chart_rounded),
    ];

    final rightTabs = [
      ('/devices', 'Devices', Icons.watch_rounded),
      ('/settings', l10n.settingsTitle, Icons.settings_rounded),
    ];

    int getSelectedIndex() {
      for (int i = 0; i < leftTabs.length; i++) {
        if (location == leftTabs[i].$1 || location.startsWith('${leftTabs[i].$1}/')) {
          return i;
        }
      }
      for (int i = 0; i < rightTabs.length; i++) {
        if (location == rightTabs[i].$1 || location.startsWith('${rightTabs[i].$1}/')) {
          return i + 2; // Offset for center FAB
        }
      }
      return 0;
    }

    final selectedIndex = getSelectedIndex();
    const primaryColor = Color(0xFF2563EB);
    const activeColor = Color(0xFF2563EB);
    const inactiveColor = Color(0xFF94A3B8);

    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          elevation: 4,
          shape: const CircleBorder(),
          backgroundColor: primaryColor,
          onPressed: () => context.push('/publish'),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        padding: EdgeInsets.zero,
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left Tabs
            for (int i = 0; i < leftTabs.length; i++)
              _buildNavItem(
                context: context,
                route: leftTabs[i].$1,
                label: leftTabs[i].$2,
                icon: leftTabs[i].$3,
                isSelected: selectedIndex == i,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),

            // Spacer for center FAB
            const SizedBox(width: 48),

            // Right Tabs
            for (int i = 0; i < rightTabs.length; i++)
              _buildNavItem(
                context: context,
                route: rightTabs[i].$1,
                label: rightTabs[i].$2,
                icon: rightTabs[i].$3,
                isSelected: selectedIndex == (i + 2),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String route,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final color = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
