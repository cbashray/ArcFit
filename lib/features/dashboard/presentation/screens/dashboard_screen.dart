import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../providers/dashboard_providers.dart';

/// Dashboard Screen – aggregated fitness overview.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull?.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final firstName = (user != null && user.name.isNotEmpty)
        ? user.name.split(' ').first
        : 'Champ';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $firstName 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ready to crush your goals?',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayWorkoutSummaryProvider);
          ref.invalidate(todayProgressProvider);
          ref.invalidate(weeklyActivityProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Today's Progress ────────────────────────────
            const _SectionTitle(title: "Today's Progress"),
            const SizedBox(height: 10),
            const _TodayProgressCard(),
            const SizedBox(height: 24),

            // ── Weekly Activity ─────────────────────────────
            const _SectionTitle(title: 'Weekly Activity'),
            const SizedBox(height: 10),
            const _WeeklyActivityChart(),
            const SizedBox(height: 24),

            // ── Quick Actions ───────────────────────────────
            const _SectionTitle(title: 'Quick Actions'),
            const SizedBox(height: 10),
            _QuickActionsRow(
              onStartWorkout: () => context.goNamed('workoutLogging'),
              onProgress: () => context.pushNamed('progress'),
              onBodyStats: () => context.pushNamed('bodyMetrics'),
            ),
            const SizedBox(height: 24),

            // ── Progress & Analytics Card ───────────────────
            const _SectionTitle(title: 'Progress & Analytics'),
            const SizedBox(height: 10),
            _ProgressDashboardCard(
              onTap: () => context.pushNamed('progress'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Progress Card
// ─────────────────────────────────────────────────────────────────────────────

class _TodayProgressCard extends ConsumerWidget {
  const _TodayProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(todayProgressProvider);
    final workoutAsync = ref.watch(todayWorkoutSummaryProvider);
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = progressAsync.valueOrNull ?? 0.0;
    final workout = workoutAsync.valueOrNull;
    final streak = streakAsync.valueOrNull ?? 0;

    final workoutCount = workout?.workoutCount ?? 0;
    final workoutMinutes = workout?.totalDurationMinutes ?? 0.0;
    final workoutCalories = workout?.totalCaloriesBurned ?? 0.0;

    // Format workout display
    final String workoutValue;
    if (workoutCount > 0) {
      if (workoutMinutes >= 1.0) {
        workoutValue = '${workoutMinutes.round()} min';
      } else if (workoutMinutes > 0) {
        final sec = (workoutMinutes * 60).round();
        workoutValue = sec > 0 ? '$sec sec' : '1 min';
      } else {
        workoutValue = '1 min';
      }
    } else {
      workoutValue = '—';
    }

    // Format calories display
    final String caloriesValue =
        workoutCalories > 0 ? '${workoutCalories.round()} kcal' : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Circular progress indicator
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Stats column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniStat(
                  icon: Icons.fitness_center_rounded,
                  color: AppTheme.primaryGreen,
                  label: 'Workout',
                  value: workoutValue,
                ),
                const SizedBox(height: 12),
                _MiniStat(
                  icon: Icons.local_fire_department_rounded,
                  color: AppTheme.accentOrange,
                  label: 'Calories',
                  value: caloriesValue,
                ),
                const SizedBox(height: 12),
                _MiniStat(
                  icon: Icons.bolt_rounded,
                  color: AppTheme.errorRed,
                  label: 'Streak',
                  value: streak > 0 ? '$streak day${streak > 1 ? 's' : ''}' : '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Activity Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyActivityChart extends ConsumerWidget {
  const _WeeklyActivityChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(weeklyActivityProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: activityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppTheme.errorRed, fontSize: 12)),
        ),
        data: (days) {
          final maxDuration = days
              .map((d) => d.durationMinutes)
              .fold<double>(0.0, (a, b) => math.max(a, b));
          final chartMax = maxDuration > 0 ? maxDuration * 1.3 : 60.0;

          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: chartMax,
              minY: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= days.length) {
                        return const SizedBox.shrink();
                      }
                      final isToday = idx == days.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          days[idx].dayLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isToday
                                ? AppTheme.primaryGreen
                                : Colors.grey.shade500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIdx, rod, rodIdx) {
                    return BarTooltipItem(
                      '${rod.toY.round()} min',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              barGroups: [
                for (var i = 0; i < days.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: days[i].durationMinutes > 0
                            ? days[i].durationMinutes
                            : 0,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        color: i == days.length - 1
                            ? AppTheme.primaryGreen
                            : AppTheme.primaryGreen.withValues(alpha: 0.45),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: chartMax,
                          color: isDark
                              ? Colors.grey.shade800.withValues(alpha: 0.3)
                              : Colors.grey.shade100,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onStartWorkout;
  final VoidCallback onProgress;
  final VoidCallback onBodyStats;

  const _QuickActionsRow({
    required this.onStartWorkout,
    required this.onProgress,
    required this.onBodyStats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.play_arrow_rounded,
            label: 'Start\nWorkout',
            color: AppTheme.primaryGreen,
            onTap: onStartWorkout,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.show_chart_rounded,
            label: 'Progress\nCharts',
            color: Colors.deepPurple,
            onTap: onProgress,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.monitor_weight_outlined,
            label: 'Body\nStats',
            color: AppTheme.secondaryBlue,
            onTap: onBodyStats,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
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
// Progress & Analytics Dashboard Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressDashboardCard extends ConsumerWidget {
  final VoidCallback onTap;

  const _ProgressDashboardCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final workouts = workoutsAsync.valueOrNull ?? [];
    final totalWorkouts = workouts.length;
    final totalVolume = workouts.fold<double>(
      0,
      (sum, w) =>
          sum +
          w.exercises.fold<double>(
            0,
            (eSum, e) => eSum + ((e.weight ?? 0) * e.reps * e.sets),
          ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.analytics_rounded,
                        color: Colors.deepPurple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Analytics',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Volume, strength gains & PR history',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ProgressStatPill(
                      label: 'Total Lifted',
                      value: totalVolume >= 1000
                          ? '${(totalVolume / 1000).toStringAsFixed(1)}k kg'
                          : '${totalVolume.round()} kg',
                      icon: Icons.fitness_center_rounded,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ProgressStatPill(
                      label: 'Logged Sessions',
                      value: '$totalWorkouts',
                      icon: Icons.history_rounded,
                      color: AppTheme.secondaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressStatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
