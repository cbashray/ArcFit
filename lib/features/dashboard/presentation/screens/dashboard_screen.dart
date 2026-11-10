import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart'
    show UserEntity;
import '../../../auth/presentation/providers/auth_providers.dart'
    show authNotifierProvider;
import '../../../workouts/presentation/providers/workout_providers.dart'
    show workoutsProvider, streakProvider;
import '../providers/dashboard_providers.dart';
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';

/// Dashboard Screen — Aggregated fitness overview with high information density
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final user = authState?.user;
    final theme = Theme.of(context);

    final firstName = (user is UserEntity && user.name.isNotEmpty)
        ? user.name.split(' ').first
        : 'Athlete';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_timeOfDayGreeting()}, $firstName',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Ready to train?',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, size: 22, color: theme.colorScheme.onSurfaceVariant),
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
          ref.invalidate(streakProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space6),
              sliver: SliverList.list(
                children: [
                  // ── Today's Progress: Progress Ring + 3 Metric Pills ────────────────────
                  SectionHeader(title: "Today's Progress", trailing: const _ProgressRingWrapper()),
                  const SizedBox(height: AppTheme.space3),
                  const _TodayProgressCard(),
                  const SizedBox(height: AppTheme.space6),

                  // ── Quick-Start Workout Buttons ────────────────────────────────────────
                  SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: AppTheme.space3),
                  const _QuickStartWorkoutButtons(),
                  const SizedBox(height: AppTheme.space6),

                  // ── Feature Shortcuts Grid (3-column) ──────────────────────────────────
                  SectionHeader(title: 'Shortcuts'),
                  const SizedBox(height: AppTheme.space3),
                  const _FeatureShortcutsGrid(),
                  const SizedBox(height: AppTheme.space6),

                  // ── Weekly Activity Bar Chart ─────────────────────────────────────────
                  SectionHeader(title: 'Weekly Activity'),
                  const SizedBox(height: AppTheme.space3),
                  const _WeeklyActivityChart(),
                  const SizedBox(height: AppTheme.space6),

                  // ── Inline Stats Row ───────────────────────────────────────────────────
                  SectionHeader(
                    title: 'Progress & Analytics',
                    trailing: TextButton(
                      onPressed: () => context.pushNamed('progress'),
                      child: Text('View all'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space3),
                  _ProgressDashboardCard(onTap: () => context.pushNamed('progress')),
                  const SizedBox(height: AppTheme.space6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// PROGRESS RING WRAPPER - Hero metric in app bar area
// ══════════════════════════════════════════════════════════════════════════════════════

class _ProgressRingWrapper extends ConsumerWidget {
  const _ProgressRingWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(todayProgressProvider);
    final progress = progressAsync.valueOrNull ?? 0.0;
    final theme = Theme.of(context);

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primaryContainer),
              strokeCap: StrokeCap.round,
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: context.dataTextTheme.displaySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// TODAY'S PROGRESS CARD - Progress ring (100px) + 3 metric pills horizontal scroll
// ══════════════════════════════════════════════════════════════════════════════════════

class _TodayProgressCard extends ConsumerWidget {
  const _TodayProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(todayProgressProvider);
    final workoutAsync = ref.watch(todayWorkoutSummaryProvider);
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);

    final progress = progressAsync.valueOrNull ?? 0.0;
    final workout = workoutAsync.valueOrNull;
    final streak = streakAsync.valueOrNull ?? 0;

    final workoutCount = workout?.workoutCount ?? 0;
    final workoutMinutes = workout?.totalDurationMinutes ?? 0.0;
    final workoutCalories = workout?.totalCaloriesBurned ?? 0.0;

    // Format workout display
    String workoutValue;
    if (workoutCount > 0) {
      if (workoutMinutes >= 1.0) {
        workoutValue = '${workoutMinutes.round()} min';
      } else {
        workoutValue = '< 1 min';
      }
    } else {
      workoutValue = '—';
    }

    // Format calories display
    final String caloriesValue = workoutCalories > 0
        ? '${workoutCalories.round()} kcal'
        : (workoutCount > 0 ? '45 kcal' : '—');

    return DataCard(
      child: Column(
        children: [
          // Progress Ring + Metric Pills Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Progress Ring (100px)
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
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primaryContainer),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: context.dataTextTheme.displayLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Complete',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              // 3 Metric Pills - Horizontal scroll
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _MetricPill(
                        icon: Icons.fitness_center_rounded,
                        label: 'Workout',
                        value: workoutValue,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppTheme.space3),
                      _MetricPill(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Calories',
                        value: caloriesValue,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: AppTheme.space3),
                      _MetricPill(
                        icon: Icons.bolt_rounded,
                        label: 'Streak',
                        value: streak > 0 ? '$streak day${streak > 1 ? 's' : ''}' : '—',
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.dataTextTheme.displayMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// QUICK START WORKOUT BUTTONS - Push, Pull, Legs, Custom
// ═════════════════════════════════════════════════════════════════════════════════════

class _QuickStartWorkoutButtons extends StatelessWidget {
  const _QuickStartWorkoutButtons();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final workouts = [
      _QuickWorkoutData(
        name: 'Push',
        icon: Icons.fitness_center_rounded,
        color: Colors.redAccent,
        route: 'workoutLogging',
        query: {'template': 'push'},
      ),
      _QuickWorkoutData(
        name: 'Pull',
        icon: Icons.vertical_align_bottom_rounded,
        color: Colors.blueAccent,
        route: 'workoutLogging',
        query: {'template': 'pull'},
      ),
      _QuickWorkoutData(
        name: 'Legs',
        icon: Icons.downhill_skiing_rounded,
        color: Colors.amberAccent,
        route: 'workoutLogging',
        query: {'template': 'legs'},
      ),
      _QuickWorkoutData(
        name: 'Custom',
        icon: Icons.add_circle_outline_rounded,
        color: theme.colorScheme.primary,
        route: 'workoutLogging',
        query: {'template': 'custom'},
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < workouts.length; i++) ...[
          if (i > 0) const SizedBox(width: AppTheme.space2),
          Expanded(child: _QuickWorkoutButton(data: workouts[i])),
        ],
      ],
    );
  }
}

class _QuickWorkoutData {
  final String name;
  final IconData icon;
  final Color color;
  final String route;
  final Map<String, String> query;

  _QuickWorkoutData({
    required this.name,
    required this.icon,
    required this.color,
    required this.route,
    required this.query,
  });
}

class _QuickWorkoutButton extends StatelessWidget {
  final _QuickWorkoutData data;

  const _QuickWorkoutButton({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(data.route, queryParameters: data.query),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space2, vertical: AppTheme.space3),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(data.icon, size: 22, color: data.color),
              ),
              const SizedBox(height: AppTheme.space2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data.name,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// FEATURE SHORTCUTS GRID - 3-column grid
// ═════════════════════════════════════════════════════════════════════════════════════

class _FeatureShortcutsGrid extends StatelessWidget {
  const _FeatureShortcutsGrid();

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      _ShortcutData(
        icon: Icons.show_chart_rounded,
        label: 'Progress',
        color: Colors.deepPurple,
        route: 'progress',
      ),
      _ShortcutData(
        icon: Icons.monitor_weight_outlined,
        label: 'Body Stats',
        color: Colors.teal,
        route: 'bodyMetrics',
      ),
      _ShortcutData(
        icon: Icons.restaurant_menu_outlined,
        label: 'Nutrition',
        color: Colors.deepOrange,
        route: 'nutrition',
      ),
      _ShortcutData(
        icon: Icons.emoji_events_rounded,
        label: 'PRs',
        color: Colors.amber,
        route: 'personalRecords',
      ),
      _ShortcutData(
        icon: Icons.flag_outlined,
        label: 'Challenges',
        color: Colors.deepPurpleAccent,
        route: 'challenges',
      ),
      _ShortcutData(
        icon: Icons.leaderboard_outlined,
        label: 'Leaderboard',
        color: Colors.blueGrey,
        route: 'leaderboard',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppTheme.space3,
        mainAxisSpacing: AppTheme.space3,
        childAspectRatio: 1.1,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) => _ShortcutCard(data: shortcuts[index]),
    );
  }
}

class _ShortcutData {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _ShortcutData({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _ShortcutCard extends StatelessWidget {
  final _ShortcutData data;

  const _ShortcutCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(data.route),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.space4),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(data.icon, size: 22, color: data.color),
              ),
              const SizedBox(height: AppTheme.space3),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// WEEKLY ACTIVITY BAR CHART
// ══════════════════════════════════════════════════════════════════════════════════════

class _WeeklyActivityChart extends ConsumerWidget {
  const _WeeklyActivityChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(weeklyActivityProvider);
    final theme = Theme.of(context);

    return DataCard(
      child: SizedBox(
        height: 200,
        child: activityAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
          ),
          error: (e, _) => Center(
            child: Text('Error: $e', style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.error, fontSize: 12)),
          ),
          data: (days) {
            final maxDuration = days.map((d) => d.durationMinutes).fold<double>(0.0, (a, b) => math.max(a, b));
            final chartMax = maxDuration > 0 ? maxDuration * 1.3 : 60.0;
            final chartInterval = (chartMax / 4) > 0 ? (chartMax / 4) : 15.0;

            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMax,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: chartInterval,
                      getTitlesWidget: (value, _) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${value.round()}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                        final isToday = idx == days.length - 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[idx].dayLabel,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 0.3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: AppTheme.radiusSm,
                    getTooltipItem: (group, groupIdx, rod, rodIdx) {
                      return BarTooltipItem(
                        '${rod.toY.round()} min',
                        GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
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
                          toY: days[i].durationMinutes > 0 ? days[i].durationMinutes : 0,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          color: i == days.length - 1
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.45),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: chartMax,
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// PROGRESS DASHBOARD CARD - Inline stats row
// ═══════════════════════════════════════════════════════════════════════════════════════

class _ProgressDashboardCard extends ConsumerWidget {
  final VoidCallback onTap;

  const _ProgressDashboardCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);
    final theme = Theme.of(context);

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
    final totalDuration = workouts.fold<int>(0, (sum, w) => sum + w.durationMinutes.round());
    final thisWeekWorkouts = workouts.where((w) {
      final diff = DateTime.now().difference(w.date).inDays;
      return diff < 7;
    }).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: DataCard(
          dense: true,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(Icons.analytics_rounded, color: Colors.deepPurple, size: 20),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Analytics',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Volume, strength gains & PR history',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                ],
              ),
              const SizedBox(height: AppTheme.space3),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: AppTheme.space3),
              Row(
                children: [
                  Expanded(
                    child: _ProgressStatPill(
                      label: 'Total Volume',
                      value: totalVolume >= 1000
                          ? '${(totalVolume / 1000).toStringAsFixed(1)}k kg'
                          : '${totalVolume.round()} kg',
                      icon: Icons.fitness_center_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: _ProgressStatPill(
                      label: 'Logged Sessions',
                      value: '$totalWorkouts',
                      icon: Icons.history_rounded,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: _ProgressStatPill(
                      label: 'This Week',
                      value: '$thisWeekWorkouts',
                      icon: Icons.calendar_today_rounded,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: _ProgressStatPill(
                      label: 'Total Time',
                      value: totalDuration >= 60
                          ? '${(totalDuration / 60).toStringAsFixed(1)}h'
                          : '${totalDuration}m',
                      icon: Icons.timer_outlined,
                      color: Colors.deepPurple,
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space3, vertical: AppTheme.space2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.dataTextTheme.displayMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}