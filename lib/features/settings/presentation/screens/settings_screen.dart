import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _reminderEnabled;
  late int _reminderHour;
  late int _reminderMinute;
  late bool _nudgeEnabled;

  @override
  void initState() {
    super.initState();
    final notif = ref.read(notificationServiceProvider);
    _reminderEnabled = notif.isReminderEnabled;
    _reminderHour = notif.reminderHour;
    _reminderMinute = notif.reminderMinute;
    _nudgeEnabled = notif.isInactivityNudgeEnabled;
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );
    if (picked != null) {
      final notif = ref.read(notificationServiceProvider);
      await notif.setReminderTime(picked.hour, picked.minute);
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder set for ${picked.format(context)} daily ⏰',
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final notif = ref.watch(notificationServiceProvider);

    final timeOfDay = TimeOfDay(hour: _reminderHour, minute: _reminderMinute);
    final formattedTime = timeOfDay.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Appearance ───────────────────────────────────────────────────
          const _SectionHeader(label: 'Appearance'),
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

          // ─── Notifications & Reminders ──────────────────────────────────
          const _SectionHeader(label: 'Reminders & Motivation'),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  iconColor: AppTheme.primaryGreen,
                  title: 'Daily Workout Reminder',
                  subtitle: _reminderEnabled
                      ? 'Scheduled for $formattedTime'
                      : 'Disabled',
                  trailing: Switch.adaptive(
                    value: _reminderEnabled,
                    activeTrackColor: AppTheme.primaryGreen,
                    onChanged: (val) async {
                      await notif.setReminderEnabled(val);
                      setState(() => _reminderEnabled = val);
                    },
                  ),
                  onTap: _reminderEnabled ? _pickReminderTime : null,
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.flash_on_rounded,
                  iconColor: AppTheme.accentOrange,
                  title: 'Inactivity Smart Nudge',
                  subtitle: 'Sends a motivational alert if inactive for 3 days',
                  trailing: Switch.adaptive(
                    value: _nudgeEnabled,
                    activeTrackColor: AppTheme.accentOrange,
                    onChanged: (val) async {
                      await notif.setInactivityNudgeEnabled(val);
                      setState(() => _nudgeEnabled = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Workout ──────────────────────────────────────────────────────
          const _SectionHeader(label: 'Workout & Training'),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.bookmark_border_rounded,
                  iconColor: Colors.deepPurple,
                  title: 'Workout Templates',
                  subtitle: 'Manage custom & pre-built routines',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => context.pushNamed('workoutTemplates'),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.emoji_events_outlined,
                  iconColor: AppTheme.accentOrange,
                  title: 'Weekly Challenges',
                  subtitle: 'View missions & claim XP rewards',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => context.pushNamed('challenges'),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.leaderboard_outlined,
                  iconColor: AppTheme.secondaryBlue,
                  title: 'Community Leaderboard',
                  subtitle: 'See top athlete rankings & podium',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => context.pushNamed('leaderboard'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Data & Reports ───────────────────────────────────────────────
          const _SectionHeader(label: 'Data & Analytics'),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.pie_chart_outline_rounded,
                  iconColor: Colors.deepPurple,
                  title: 'Weekly & Monthly Reports',
                  subtitle: 'Comprehensive performance breakdown & PDF',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => context.pushNamed('summaryReport'),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.military_tech_outlined,
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
                  subtitle: 'Download as CSV format',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => context.pushNamed('export'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── About ────────────────────────────────────────────────────────
          const _SectionHeader(label: 'About'),
          Card(
            child: Column(
              children: [
                const _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.grey,
                  title: 'FitX',
                  subtitle: 'Version 1.0.0 — AI-powered fitness tracker',
                ),
                const Divider(height: 1, indent: 56),
                const _SettingsTile(
                  icon: Icons.code_rounded,
                  iconColor: Colors.grey,
                  title: 'Built with Flutter & Riverpod',
                  subtitle: 'Clean feature-first architecture',
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
              padding: const EdgeInsets.symmetric(vertical: 14),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
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
