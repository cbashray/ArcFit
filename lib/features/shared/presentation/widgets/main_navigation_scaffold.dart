import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class MainNavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        indicatorColor: theme.colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSm)),
        ),
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: theme.colorScheme.shadow,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: _NavIcon(icon: Icons.dashboard_outlined, isDark: isDark),
            selectedIcon: _NavIcon(icon: Icons.dashboard_rounded, isDark: isDark, selected: true),
            label: 'Dashboard',
            tooltip: 'Dashboard',
          ),
          NavigationDestination(
            icon: _NavIcon(icon: Icons.leaderboard_outlined, isDark: isDark),
            selectedIcon: _NavIcon(icon: Icons.leaderboard_rounded, isDark: isDark, selected: true),
            label: 'Leaderboard',
            tooltip: 'Leaderboard',
          ),
          NavigationDestination(
            icon: _NavIcon(icon: Icons.fitness_center_outlined, isDark: isDark),
            selectedIcon: _NavIcon(icon: Icons.fitness_center_rounded, isDark: isDark, selected: true),
            label: 'Workout',
            tooltip: 'Workout',
          ),
          NavigationDestination(
            icon: _NavIcon(icon: Icons.restaurant_menu_outlined, isDark: isDark),
            selectedIcon: _NavIcon(icon: Icons.restaurant_menu_rounded, isDark: isDark, selected: true),
            label: 'Nutrition',
            tooltip: 'Nutrition',
          ),
          NavigationDestination(
            icon: _NavIcon(icon: Icons.smart_toy_outlined, isDark: isDark),
            selectedIcon: _NavIcon(icon: Icons.smart_toy_rounded, isDark: isDark, selected: true),
            label: 'AI Coach',
            tooltip: 'AI Coach',
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool selected;

  const _NavIcon({
    required this.icon,
    required this.isDark,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Icon(
      icon,
      size: 22,
      color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
    );
  }
}