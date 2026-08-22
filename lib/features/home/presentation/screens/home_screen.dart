import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../workouts/domain/entities/workout_entity.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';

/// Consecutive-day workout streak ending today or yesterday.
final streakProvider = FutureProvider<int>((ref) async {
  final workouts = await ref.watch(workoutsProvider.future);
  if (workouts.isEmpty) return 0;

  final workoutDays = workouts
      .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
      .toSet();

  var streak = 0;
  var day = DateTime.now();
  day = DateTime(day.year, day.month, day.day);

  // A streak can start today or yesterday.
  if (!workoutDays.contains(day)) {
    day = day.subtract(const Duration(days: 1));
  }

  while (workoutDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull?.user;
    final workoutsAsync = ref.watch(workoutsProvider);
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  size: 18, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 10),
            const Text(
              'FitX',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Badges',
            onPressed: () => context.pushNamed('badges'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(workoutsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome
            Text(
              'Welcome back${user != null && user.name.isNotEmpty ? ', ${user.name.split(' ').first}' : ''}! 💪',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Ready to crush today\'s workout?',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Primary CTA
            _StartWorkoutCard(
              onTap: () => context.goNamed('workoutLogging'),
            ),
            const SizedBox(height: 20),

            // Stats
            workoutsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Error loading stats: $error',
                      style: const TextStyle(color: AppTheme.errorRed)),
                ),
              ),
              data: (workouts) {
                final totalSets = workouts.fold<int>(
                    0, (sum, w) => sum + w.totalSets);
                final totalCalories = workouts.fold<double>(
                    0, (sum, w) => sum + w.totalCaloriesBurned);
                final streak = streakAsync.valueOrNull ?? 0;

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.fitness_center_rounded,
                        label: 'Workouts',
                        value: '${workouts.length}',
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.layers_rounded,
                        label: 'Total sets',
                        value: '$totalSets',
                        color: AppTheme.secondaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Day streak',
                        value: '$streak',
                        color: AppTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.bolt_rounded,
                        label: 'kcal',
                        value: totalCalories >= 1000
                            ? '${(totalCalories / 1000).toStringAsFixed(1)}k'
                            : '${totalCalories.round()}',
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick actions — 3 rows of 2
            const Text(
              'Explore',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _QuickActionRow(
              tiles: [
                _ActionTileData(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Workout',
                  subtitle: 'Generate a plan',
                  color: Colors.deepPurple,
                  route: 'generateWorkout',
                ),
                _ActionTileData(
                  icon: Icons.menu_book_rounded,
                  label: 'Exercises',
                  subtitle: 'Browse library',
                  color: AppTheme.secondaryBlue,
                  route: 'exerciseLibrary',
                ),
              ],
              onTap: (route) => context.pushNamed(route),
            ),
            const SizedBox(height: 10),
            _QuickActionRow(
              tiles: [
                _ActionTileData(
                  icon: Icons.show_chart_rounded,
                  label: 'Progress',
                  subtitle: 'Charts & trends',
                  color: AppTheme.primaryGreen,
                  route: 'progress',
                ),
                _ActionTileData(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Nutrition',
                  subtitle: 'Track your diet',
                  color: Colors.teal,
                  route: 'nutrition',
                ),
              ],
              onTap: (route) => context.pushNamed(route),
            ),
            const SizedBox(height: 10),
            _QuickActionRow(
              tiles: [
                _ActionTileData(
                  icon: Icons.smart_toy_rounded,
                  label: 'AI Coach',
                  subtitle: 'Ask anything',
                  color: Colors.indigo,
                  route: 'fitnessCoach',
                ),
                _ActionTileData(
                  icon: Icons.emoji_events_rounded,
                  label: 'My PRs',
                  subtitle: 'Personal records',
                  color: AppTheme.accentOrange,
                  route: 'personalRecords',
                ),
              ],
              onTap: (route) => context.pushNamed(route),
            ),
            const SizedBox(height: 24),

            // Recent workouts
            Row(
              children: [
                const Text(
                  'Recent Workouts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                workoutsAsync.maybeWhen(
                  data: (workouts) => workouts.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          '${workouts.length}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            workoutsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (workouts) {
                if (workouts.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.history_rounded,
                            size: 36, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'No workouts yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your logged workouts will show up here',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final workout in workouts.take(5))
                      _WorkoutHistoryCard(
                        workout: workout,
                        onDelete: () => ref
                            .read(workoutsProvider.notifier)
                            .delete(workout.id),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start Workout CTA card
// ─────────────────────────────────────────────────────────────────────────────

class _StartWorkoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StartWorkoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Log sets, reps and weights',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat cards
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick action tiles
// ─────────────────────────────────────────────────────────────────────────────

class _ActionTileData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final String route;

  const _ActionTileData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}

class _QuickActionRow extends StatelessWidget {
  final List<_ActionTileData> tiles;
  final ValueChanged<String> onTap;

  const _QuickActionRow({required this.tiles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tiles
          .expand((tile) => [
                Expanded(child: _ActionTile(data: tile, onTap: onTap)),
                if (tile != tiles.last) const SizedBox(width: 10),
              ])
          .toList(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final _ActionTileData data;
  final ValueChanged<String> onTap;

  const _ActionTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(data.route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(data.icon, size: 20, color: data.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Workout history card
// ─────────────────────────────────────────────────────────────────────────────

class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutEntity workout;
  final VoidCallback onDelete;

  const _WorkoutHistoryCard({required this.workout, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, MMM d').format(workout.date);
    final durationLabel = workout.durationMinutes > 0
        ? '${workout.durationMinutes.round()} min'
        : '—';
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                size: 20, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateLabel • ${workout.exercises.length} exercises • '
                  '${workout.totalSets} sets • $durationLabel',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppTheme.errorRed),
                    SizedBox(width: 8),
                    Text('Delete',
                        style: TextStyle(color: AppTheme.errorRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
