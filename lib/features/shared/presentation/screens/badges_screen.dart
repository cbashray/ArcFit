import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../workouts/domain/entities/workout_entity.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../gamification/gamification.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncBadges();
    });
  }

  Future<void> _syncBadges() async {
    final workouts = await ref.read(workoutsProvider.future);
    final streak = await ref.read(streakProvider.future);
    final prs = await ref.read(personalRecordsProvider.future);

    final newlyUnlocked = await ref.read(badgesProvider.notifier).checkAndSync(
          workouts: workouts,
          streak: streak,
          prsCount: prs.length,
        );

    if (newlyUnlocked.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 You unlocked ${newlyUnlocked.length} new badge${newlyUnlocked.length > 1 ? 's' : ''}: '
            '${newlyUnlocked.map((b) => '${b.emoji} ${b.name}').join(', ')}!',
          ),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  ({int current, int target, String unit}) _getProgress(
    BadgeEntity badge,
    List<WorkoutEntity> workouts,
    int streak,
    int prsCount,
  ) {
    final totalWorkouts = workouts.length;
    final totalSets = workouts.fold<int>(0, (sum, w) => sum + w.totalSets);
    final uniqueExercises = workouts
        .expand((w) => w.exercises.map((e) => e.exerciseName.trim().toLowerCase()))
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;
    final hasEarlyBird = workouts.any((w) => w.date.hour < 7);
    final hasNightOwl = workouts.any((w) => w.date.hour >= 21);

    switch (badge.id) {
      case 'first_workout':
        return (current: totalWorkouts, target: 1, unit: 'workout');
      case 'streak_3':
        return (current: streak, target: 3, unit: 'days');
      case 'streak_7':
        return (current: streak, target: 7, unit: 'days');
      case 'streak_30':
        return (current: streak, target: 30, unit: 'days');
      case 'workouts_10':
        return (current: totalWorkouts, target: 10, unit: 'workouts');
      case 'workouts_50':
        return (current: totalWorkouts, target: 50, unit: 'workouts');
      case 'workouts_100':
        return (current: totalWorkouts, target: 100, unit: 'workouts');
      case 'sets_100':
        return (current: totalSets, target: 100, unit: 'sets');
      case 'sets_1000':
        return (current: totalSets, target: 1000, unit: 'sets');
      case 'pr_first':
        return (current: prsCount, target: 1, unit: 'PR');
      case 'pr_10':
        return (current: prsCount, target: 10, unit: 'PRs');
      case 'variety':
        return (current: uniqueExercises, target: 10, unit: 'exercises');
      case 'early_bird':
        return (current: hasEarlyBird ? 1 : 0, target: 1, unit: '< 7:00 AM');
      case 'night_owl':
        return (current: hasNightOwl ? 1 : 0, target: 1, unit: '> 9:00 PM');
      default:
        return (current: badge.isUnlocked ? 1 : 0, target: 1, unit: '');
    }
  }

  void _showBadgeDialog(
    BadgeEntity badge,
    ({int current, int target, String unit}) progress,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isUnlocked = badge.isUnlocked;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Text(badge.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(badge.name, textAlign: TextAlign.center),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUnlocked
                          ? Icons.check_circle_rounded
                          : Icons.lock_outline_rounded,
                      size: 18,
                      color: isUnlocked
                          ? AppTheme.primaryGreen
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUnlocked
                          ? 'Unlocked on ${DateFormat('MMMM d, yyyy').format(badge.unlockedAt!)}'
                          : 'Progress: ${progress.current.clamp(0, progress.target)} / ${progress.target} ${progress.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? AppTheme.primaryGreen
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(badgesProvider);
    final workoutsAsync = ref.watch(workoutsProvider);
    final streakAsync = ref.watch(streakProvider);
    final prsAsync = ref.watch(personalRecordsProvider);

    final workouts = workoutsAsync.valueOrNull ?? [];
    final streak = streakAsync.valueOrNull ?? 0;
    final prsCount = prsAsync.valueOrNull?.length ?? 0;

    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    final filteredBadges = badges.where((b) {
      if (_selectedFilter == 'Unlocked') return b.isUnlocked;
      if (_selectedFilter == 'Locked') return !b.isUnlocked;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Badges ($unlockedCount/${badges.length}) 🏅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync & Check Badges',
            onPressed: () async {
              await _syncBadges();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Badges refreshed!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Achievements',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${badges.isEmpty ? 0 : ((unlockedCount / badges.length) * 100).round()}% Completed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: badges.isEmpty ? 0 : unlockedCount / badges.length,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$unlockedCount of ${badges.length} badges unlocked',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Unlocked', 'Locked'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Badges Grid
          Expanded(
            child: filteredBadges.isEmpty
                ? Center(
                    child: Text(
                      'No badges in "$_selectedFilter"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: filteredBadges.length,
                    itemBuilder: (context, index) {
                      final badge = filteredBadges[index];
                      final progress =
                          _getProgress(badge, workouts, streak, prsCount);
                      return _BadgeTile(
                        badge: badge,
                        progress: progress,
                        onTap: () => _showBadgeDialog(badge, progress),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeEntity badge;
  final ({int current, int target, String unit}) progress;
  final VoidCallback onTap;

  const _BadgeTile({
    required this.badge,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unlocked = badge.isUnlocked;
    final progressRatio = (progress.current / progress.target).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unlocked
                ? (isDark
                    ? AppTheme.accentOrange.withValues(alpha: 0.12)
                    : AppTheme.accentOrange.withValues(alpha: 0.08))
                : (theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unlocked
                  ? AppTheme.accentOrange.withValues(alpha: 0.45)
                  : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200),
              width: unlocked ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji
              Text(
                unlocked ? badge.emoji : '🔒',
                style: TextStyle(
                  fontSize: 28,
                  color: unlocked ? null : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 6),

              // Name
              Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: unlocked
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),

              // Subtitle / Progress
              if (unlocked) ...[
                Text(
                  DateFormat('MMM d, yyyy').format(badge.unlockedAt!),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 4,
                      backgroundColor: isDark
                          ? const Color(0xFF333333)
                          : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(
                          AppTheme.primaryGreen),
                    ),
                  ),
                ),
                Text(
                  '${progress.current.clamp(0, progress.target)}/${progress.target} ${progress.unit}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
