import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../../../core/providers/theme_provider.dart'
    show themeModeProvider;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';
import '../../../auth/domain/entities/user_entity.dart' show UserEntity;
import '../../../auth/presentation/providers/auth_providers.dart' show authNotifierProvider;
import '../widgets/edit_profile_sheet.dart' show EditProfileSheet;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminderEnabled = true;
  int _reminderHour = 8;
  int _reminderMinute = 0;
  bool _inactivityNudge = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        toolbarHeight: 56,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space6),
        children: [
          // ── Profile Section ────────────────────────────────────────────────
          _ProfileCard(),
          const SizedBox(height: AppTheme.space6),

          // ── Appearance ─────────────────────────────────────────────────────
          SectionHeader(title: 'Appearance'),
          const SizedBox(height: AppTheme.space3),
          DataCard(
            child: Column(
              children: [
                _ThemeModeTile(
                  value: ThemeMode.system,
                  label: 'System',
                  subtitle: 'Follow device setting',
                  icon: Icons.brightness_auto_outlined,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _ThemeModeTile(
                  value: ThemeMode.light,
                  label: 'Light',
                  subtitle: 'Always light mode',
                  icon: Icons.light_mode_outlined,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _ThemeModeTile(
                  value: ThemeMode.dark,
                  label: 'Dark',
                  subtitle: 'Always dark mode',
                  icon: Icons.dark_mode_outlined,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space6),

          // ── Notifications ──────────────────────────────────────────────────
          SectionHeader(title: 'Notifications'),
          const SizedBox(height: AppTheme.space3),
          DataCard(
            child: Column(
              children: [
                _NotificationTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Workout Reminder',
                  subtitle: 'Daily reminder to workout',
                  trailing: Switch.adaptive(
                    value: _reminderEnabled,
                    onChanged: (v) => setState(() => _reminderEnabled = v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: theme.colorScheme.primary,
                  ),
                  onTap: () => _showReminderTimePicker(),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _NotificationTile(
                  icon: Icons.bedtime_outlined,
                  title: 'Inactivity Nudge',
                  subtitle: 'Reminder if no workout logged',
                  trailing: Switch.adaptive(
                    value: _inactivityNudge,
                    onChanged: (v) => setState(() => _inactivityNudge = v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: theme.colorScheme.primary,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space6),

          // ── Data Management ────────────────────────────────────────────────
          SectionHeader(title: 'Data & Privacy'),
          const SizedBox(height: AppTheme.space3),
          DataCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Export Data',
                  subtitle: 'CSV export of all workouts',
                  onTap: () => context.pushNamed('export'),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete All Data',
                  subtitle: 'Permanently erase all data',
                  titleColor: theme.colorScheme.error,
                  onTap: () => _showDeleteConfirmation(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space6),

          // ── About ──────────────────────────────────────────────────────────
          SectionHeader(title: 'About'),
          const SizedBox(height: AppTheme.space3),
          DataCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  subtitle: '1.0.0',
                  trailing: const Text('1.0.0', style: TextStyle(fontFamily: 'JetBrainsMono')),
                  onTap: null,
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _SettingsTile(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () {},
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () {},
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve ArcFit',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReminderTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Theme.of(context).colorScheme.surface,
            hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
            dayPeriodTextColor: Theme.of(context).colorScheme.onSurface,
            dialHandColor: Theme.of(context).colorScheme.primary,
            dialBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text('This will permanently delete all your workouts, nutrition logs, progress data, and settings. This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app: ref.read(dataRepositoryProvider).deleteAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// PROFILE CARD
// ══════════════════════════════════════════════════════════════════════════════════════

class _ProfileCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).valueOrNull?.user;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Alex Rivera';
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'alex@arcfit.app';
    final userAge = user?.age ?? 26;
    final userHeight = user?.height?.round() ?? 178;
    final userWeight = user?.weight?.round() ?? 75;
    final userAvatar = (user?.avatarEmoji?.isNotEmpty == true) ? user!.avatarEmoji! : '🦁';

    return DataCard(
      child: Row(
        children: [
          Avatar(
            emoji: userAvatar,
            size: 64,
            borderColor: theme.colorScheme.primary,
            borderWidth: 2,
          ),
          const SizedBox(width: AppTheme.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.space3),
                Row(
                  children: [
                    _ProfileStat(label: 'Age', value: '$userAge yrs', color: theme.colorScheme.primary),
                    const SizedBox(width: AppTheme.space3),
                    _ProfileStat(label: 'Height', value: '$userHeight cm', color: theme.colorScheme.secondary),
                    const SizedBox(width: AppTheme.space3),
                    _ProfileStat(label: 'Weight', value: '$userWeight kg', color: theme.colorScheme.tertiary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 22, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () => _showEditProfileSheet(context, user),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserEntity? user) {
    if (user != null) {
      EditProfileSheet.show(context, user);
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const _EditProfileSheet(),
      );
    }
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════════════
// SETTINGS TILES
// ═════════════════════════════════════════════════════════════════════════════════════

class _ThemeModeTile extends StatelessWidget {
  final ThemeMode value;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeTile({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Icon(icon, size: 20, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
      ),
      title: Text(label, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 22)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500, color: titleColor)),
      subtitle: Text(subtitle, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// EDIT PROFILE SHEET
// ══════════════════════════════════════════════════════════════════════════════════════

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _nameController = TextEditingController(text: 'Alex Rivera');
  final _ageController = TextEditingController(text: '26');
  final _heightController = TextEditingController(text: '178');
  final _weightController = TextEditingController(text: '75');
  String _selectedAvatar = '🦁';
  bool _isSaving = false;

  final List<String> _avatars = [
    '🦁', '🐯', '🐻', '🐺', '🦅', '🦈', '🦍', '🐂',
    '🐎', '🐅', '🐘', '🦏', '🐊', '🦂', '🦁', '🐉',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppTheme.space3),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space2),
              child: Row(
                children: [
                  Text('Edit Profile', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  IconButton(icon: Icon(Icons.close_rounded, size: 22, color: theme.colorScheme.onSurfaceVariant), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
                children: [
                  // Avatar picker
                  Center(
                    child: Column(
                      children: [
                        Text('Choose Avatar', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: AppTheme.space3),
                        Wrap(
                          spacing: AppTheme.space2,
                          runSpacing: AppTheme.space2,
                          children: _avatars.map((avatar) => GestureDetector(
                            onTap: () => setState(() => _selectedAvatar = avatar),
                            child: Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedAvatar == avatar
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(
                                  color: _selectedAvatar == avatar
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant,
                                  width: _selectedAvatar == avatar ? 2 : 1,
                                ),
                              ),
                              child: Text(avatar, style: TextStyle(fontSize: 24)),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space5),

                  // Form fields
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outlined, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space3),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            prefixIcon: Icon(Icons.cake_outlined, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            prefixIcon: Icon(Icons.height_outlined, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space3),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space5),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                      child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}