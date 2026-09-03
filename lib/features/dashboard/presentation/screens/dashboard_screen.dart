import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/screens/home_screen.dart'; // streakProvider
import '../../../nutrition/presentation/providers/nutrition_providers.dart';
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
        onRefresh: () async {
          ref.invalidate(todayWorkoutSummaryProvider);
          ref.invalidate(todayProgressProvider);
          ref.invalidate(weeklyActivityProvider);
          ref.invalidate(dailyNutritionProvider);
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
              onBodyStats: () => context.pushNamed('bodyMetrics'),
              onLogFood: () => context.pushNamed('addFood'),
            ),
            const SizedBox(height: 24),

            // ── Explore (link to full Home) ─────────────────
            _ExploreCard(
              onTap: () => context.pushNamed('home_full'),
            ),
            const SizedBox(height: 16),
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
    final nutritionAsync = ref.watch(dailyNutritionProvider);
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = progressAsync.valueOrNull ?? 0.0;
    final workout = workoutAsync.valueOrNull;
    final nutrition = nutritionAsync.valueOrNull;
    final streak = streakAsync.valueOrNull ?? 0;

    final workoutCount = workout?.workoutCount ?? 0;
    final workoutMinutes = workout?.totalDurationMinutes ?? 0.0;
    final workoutCalories = workout?.totalCaloriesBurned ?? 0.0;
    final foodCalories = nutrition?.totalCalories ?? 0.0;

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

    // Format calories display (prefer workout active burn, fallback to food intake)
    final totalCalories = workoutCalories > 0 ? workoutCalories : foodCalories;
    final String caloriesValue =
        totalCalories > 0 ? '${totalCalories.round()} kcal' : '—';

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
                  icon: Icons.local_fire_department_rounded,
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
  final VoidCallback onBodyStats;
  final VoidCallback onLogFood;

  const _QuickActionsRow({
    required this.onStartWorkout,
    required this.onBodyStats,
    required this.onLogFood,
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
            icon: Icons.monitor_weight_outlined,
            label: 'Body\nStats',
            color: AppTheme.secondaryBlue,
            onTap: onBodyStats,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.restaurant_outlined,
            label: 'Log\nFood',
            color: AppTheme.accentOrange,
            onTap: onLogFood,
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
// Explore Card (link to full Home screen)
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ExploreCard({required this.onTap});

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
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.explore_rounded,
                    size: 26, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore All Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'AI Workouts, Exercises, Habits, Reports & more',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
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
