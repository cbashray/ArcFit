import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Appearance ───────────────────────────────────────────────────
          _SectionHeader(label: 'Appearance'),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  iconColor: Colors.deepPurple,
                  title: 'Theme',
                  subtitle: _themeName(themeMode),
                  trailing: _ThemeSegmentedButton(
                    value: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setTheme(mode),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Workout ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Workout'),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.timer_outlined,
                  iconColor: AppTheme.accentOrange,
                  title: 'Rest Timer',
                  subtitle: 'Shown in workout logging screen',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.calculate_outlined,
                  iconColor: AppTheme.secondaryBlue,
                  title: '1RM Calculator',
                  subtitle: 'Available in every exercise card',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Data ─────────────────────────────────────────────────────────
          _SectionHeader(label: 'Data'),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.emoji_events_outlined,
                  iconColor: AppTheme.accentOrange,
                  title: 'Personal Records',
                  subtitle: 'View all your best lifts',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => context.pushNamed('personalRecords'),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  iconColor: AppTheme.primaryGreen,
                  title: 'Export Workout History',
                  subtitle: 'Download as CSV or PDF',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => context.pushNamed('export'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── About ────────────────────────────────────────────────────────
          _SectionHeader(label: 'About'),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.grey,
                  title: 'FitX',
                  subtitle: 'Version 1.0.0 — AI-powered fitness tracker',
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.code_rounded,
                  iconColor: Colors.grey,
                  title: 'Built with Flutter & Riverpod',
                  subtitle: 'Feature-first clean architecture',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── Sign out ─────────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
              side: const BorderSide(color: AppTheme.errorRed),
              padding:
                  const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(title,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _ThemeSegmentedButton extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmentedButton({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode_outlined, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.phone_android_rounded, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode_outlined, size: 16),
        ),
      ],
      selected: {value},
      onSelectionChanged: (set) => onChanged(set.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
