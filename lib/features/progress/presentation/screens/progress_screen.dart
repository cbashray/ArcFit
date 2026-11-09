import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../../workouts/presentation/providers/workout_providers.dart'
    show workoutsProvider, personalRecordsProvider, streakProvider;
import '../../../workouts/domain/entities/personal_record_entity.dart'
    show PersonalRecordEntity;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);
    final prsAsync = ref.watch(personalRecordsProvider);
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined, size: 22, color: theme.colorScheme.onSurfaceVariant),
            tooltip: 'Export Report',
            onPressed: () => context.pushNamed('summaryReport'),
          ),
        ],
      ),
      body: workoutsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.error))),
        data: (workouts) {
          final streak = streakAsync.valueOrNull ?? 0;
          final prs = prsAsync.valueOrNull ?? [];

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space6),
            children: [
              // ── Hero Stats Row ──────────────────────────────────────────────
              SectionHeader(title: 'Overview'),
              const SizedBox(height: AppTheme.space3),
              _OverviewStatsRow(workouts: workouts, streak: streak, prsCount: prs.length),
              const SizedBox(height: AppTheme.space6),

              // ── Weight & Volume Line Charts ─────────────────────────────────
              SectionHeader(title: 'Volume Trend'),
              const SizedBox(height: AppTheme.space3),
              _VolumeLineChart(workouts: workouts),
              const SizedBox(height: AppTheme.space6),

              SectionHeader(title: 'Body Weight Trend'),
              const SizedBox(height: AppTheme.space3),
              _WeightLineChart(),
              const SizedBox(height: AppTheme.space6),

              // ── Personal Records ─────────────────────────────────────────────
              SectionHeader(
                title: 'Personal Records (1RM)',
                trailing: TextButton(
                  onPressed: () => context.pushNamed('personalRecords'),
                  child: Text('View all'),
                ),
              ),
              const SizedBox(height: AppTheme.space3),
              _PrList(prs: prs),
              const SizedBox(height: AppTheme.space6),

              // ── Muscle Volume Breakdown ──────────────────────────────────────
              SectionHeader(title: 'Muscle Volume Distribution'),
              const SizedBox(height: AppTheme.space3),
              _MuscleVolumeChart(workouts: workouts),
              const SizedBox(height: AppTheme.space6),

              // ── Consistency Score ────────────────────────────────────────────
              SectionHeader(title: 'Consistency'),
              const SizedBox(height: AppTheme.space3),
              _ConsistencyCard(workouts: workouts, streak: streak),
              const SizedBox(height: AppTheme.space6),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// OVERVIEW STATS ROW
// ═══════════════════════════════════════════════════════════════════════════════════════

class _OverviewStatsRow extends StatelessWidget {
  final List<dynamic> workouts;
  final int streak;
  final int prsCount;

  const _OverviewStatsRow({
    required this.workouts,
    required this.streak,
    required this.prsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
    final totalDuration = workouts.fold<int>(0, (sum, w) => (sum + w.durationMinutes.round()).toInt());
    final thisWeekWorkouts = workouts.where((w) {
      final diff = DateTime.now().difference(w.date).inDays;
      return diff < 7;
    }).length;

    return Row(
      children: [
        Expanded(child: _OverviewStatCard(
          label: 'Total Volume',
          value: totalVolume >= 1000 ? '${(totalVolume / 1000).toStringAsFixed(1)}k kg' : '${totalVolume.round()} kg',
          icon: Icons.fitness_center_rounded,
          color: theme.colorScheme.primary,
        )),
        const SizedBox(width: AppTheme.space3),
        Expanded(child: _OverviewStatCard(
          label: 'Workouts',
          value: '$totalWorkouts',
          icon: Icons.history_rounded,
          color: theme.colorScheme.secondary,
        )),
        const SizedBox(width: AppTheme.space3),
        Expanded(child: _OverviewStatCard(
          label: 'This Week',
          value: '$thisWeekWorkouts',
          icon: Icons.calendar_today_rounded,
          color: theme.colorScheme.tertiary,
        )),
        const SizedBox(width: AppTheme.space3),
        Expanded(child: _OverviewStatCard(
          label: 'Streak',
          value: '$streak d',
          icon: Icons.local_fire_department_rounded,
          color: Colors.deepOrange,
        )),
        const SizedBox(width: AppTheme.space3),
        Expanded(child: _OverviewStatCard(
          label: 'PRs',
          value: '$prsCount',
          icon: Icons.emoji_events_rounded,
          color: Colors.amber,
        )),
        const SizedBox(width: AppTheme.space3),
        Expanded(child: _OverviewStatCard(
          label: 'Total Time',
          value: totalDuration >= 60 ? '${(totalDuration / 60).toStringAsFixed(1)}h' : '${totalDuration}m',
          icon: Icons.timer_outlined,
          color: Colors.deepPurple,
        )),
      ],
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
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
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// VOLUME LINE CHART
// ═══════════════════════════════════════════════════════════════════════════════════════

class _VolumeLineChart extends StatelessWidget {
  final List<dynamic> workouts;

  const _VolumeLineChart({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group workouts by week for last 12 weeks
    final weeklyData = _getWeeklyVolume(workouts);

    if (weeklyData.isEmpty || weeklyData.every((e) => e.volume <= 0)) {
      return DataCard(
        child: EmptyState(
          icon: Icons.show_chart_outlined,
          title: 'No volume data yet',
          message: 'Complete workouts to see volume trends',
        ),
      );
    }

    final rawMax = weeklyData.map((e) => e.volume).fold<double>(0.0, (a, b) => a > b ? a : b);
    final rawMin = weeklyData.map((e) => e.volume).fold<double>(double.infinity, (a, b) => a < b ? a : b);
    final maxVolume = rawMax > 0 ? rawMax : 1000.0;
    final minVolume = rawMin.isFinite ? rawMin : 0.0;
    final interval = (maxVolume / 4) > 0 ? (maxVolume / 4) : 250.0;

    return DataCard(
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (weeklyData.length - 1).toDouble(),
            minY: minVolume > 0 ? minVolume * 0.8 : 0,
            maxY: maxVolume * 1.2,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
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
                  reservedSize: 48,
                  interval: interval,
                  getTitlesWidget: (value, _) {
                    if (value <= 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value >= 1000
                            ? '${(value / 1000).toStringAsFixed(1)}k'
                            : value.round().toString(),
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
                    if (idx < 0 || idx >= weeklyData.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        weeklyData[idx].label,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: AppTheme.radiusSm,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final idx = spot.x.toInt();
                    if (idx < 0 || idx >= weeklyData.length) return null;
                    return LineTooltipItem(
                      '${(weeklyData[idx].volume / 1000).toStringAsFixed(1)}k kg',
                      GoogleFonts.ibmPlexSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: weeklyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.volume)).toList(),
                isCurved: true,
                curveSmoothness: 0.35,
                color: theme.colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: theme.colorScheme.surface,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_WeeklyVolumePoint> _getWeeklyVolume(List<dynamic> workouts) {
    final now = DateTime.now();
    final result = <_WeeklyVolumePoint>[];

    for (int i = 11; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekWorkouts = workouts.where((w) {
        return !w.date.isBefore(weekStart) && !w.date.isAfter(weekEnd);
      }).toList();

      final volume = weekWorkouts.fold<double>(
        0,
        (sum, w) =>
            sum +
            w.exercises.fold<double>(
              0,
              (eSum, e) => eSum + ((e.weight ?? 0) * e.reps * e.sets),
            ),
      );

      result.add(_WeeklyVolumePoint(
        label: DateFormat('MMM d').format(weekStart),
        volume: volume,
      ));
    }

    return result;
  }
}

class _WeeklyVolumePoint {
  final String label;
  final double volume;

  _WeeklyVolumePoint({required this.label, required this.volume});
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// WEIGHT LINE CHART (Mock - would come from body metrics provider)
// ═══════════════════════════════════════════════════════════════════════════════════════

class _WeightLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock weight data - in real app would come from body metrics provider
    final weightData = [
      _WeightPoint(label: 'Jan', weight: 78.5),
      _WeightPoint(label: 'Feb', weight: 78.2),
      _WeightPoint(label: 'Mar', weight: 77.8),
      _WeightPoint(label: 'Apr', weight: 77.5),
      _WeightPoint(label: 'May', weight: 77.3),
      _WeightPoint(label: 'Jun', weight: 77.0),
      _WeightPoint(label: 'Jul', weight: 76.8),
      _WeightPoint(label: 'Aug', weight: 76.5),
      _WeightPoint(label: 'Sep', weight: 76.2),
      _WeightPoint(label: 'Oct', weight: 76.0),
      _WeightPoint(label: 'Nov', weight: 75.8),
      _WeightPoint(label: 'Dec', weight: 75.5),
    ];

    final rawMaxWeight = weightData.map((e) => e.weight).fold<double>(0.0, (a, b) => a > b ? a : b);
    final rawMinWeight = weightData.map((e) => e.weight).fold<double>(double.infinity, (a, b) => a < b ? a : b);
    final minWeight = rawMinWeight.isFinite ? (rawMinWeight - 1.0).clamp(0.0, double.infinity) : 70.0;
    final maxWeight = (rawMaxWeight > minWeight) ? rawMaxWeight + 1.0 : minWeight + 5.0;
    final weightInterval = ((maxWeight - minWeight) / 4) > 0 ? ((maxWeight - minWeight) / 4) : 1.0;

    return DataCard(
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (weightData.length - 1).toDouble(),
            minY: minWeight,
            maxY: maxWeight,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: weightInterval,
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
                  reservedSize: 42,
                  interval: weightInterval,
                  getTitlesWidget: (value, _) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${value.toStringAsFixed(1)}kg',
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
                    if (idx < 0 || idx >= weightData.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        weightData[idx].label,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: AppTheme.radiusSm,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final idx = spot.x.toInt();
                    if (idx < 0 || idx >= weightData.length) return null;
                    return LineTooltipItem(
                      '${weightData[idx].weight.toStringAsFixed(1)} kg',
                      GoogleFonts.ibmPlexSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: weightData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                isCurved: true,
                curveSmoothness: 0.35,
                color: Colors.teal,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: Colors.teal,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.teal.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightPoint {
  final String label;
  final double weight;

  _WeightPoint({required this.label, required this.weight});
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// PERSONAL RECORDS LIST
// ═══════════════════════════════════════════════════════════════════════════════════════

class _PrList extends StatelessWidget {
  final List<dynamic> prs;

  const _PrList({required this.prs});

  @override
  Widget build(BuildContext context) {
    if (prs.isEmpty) {
      return DataCard(
        child: EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'No PRs yet',
          message: 'Complete workouts to set personal records',
        ),
      );
    }

    // Group by exercise
    final grouped = <String, List<dynamic>>{};
    for (final pr in prs) {
      grouped.putIfAbsent(pr.exerciseName, () => []).add(pr);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final bestPr = entry.value.reduce((a, b) => a.value > b.value ? a : b);
        return _PrCard(pr: bestPr);
      }).toList(),
    );
  }
}

class _PrCard extends StatelessWidget {
  final PersonalRecordEntity pr;

  const _PrCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DataCard(
      margin: const EdgeInsets.only(bottom: AppTheme.space2),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.exerciseName,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${pr.recordType}: ${pr.value.toStringAsFixed(1)} ${pr.unit}',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              '${pr.value.toStringAsFixed(1)} ${pr.unit}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// MUSCLE VOLUME CHART
// ═══════════════════════════════════════════════════════════════════════════════════════

class _MuscleVolumeChart extends StatelessWidget {
  final List<dynamic> workouts;

  const _MuscleVolumeChart({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate muscle volume
    final muscleVolume = <String, double>{};
    for (final w in workouts) {
      for (final ex in w.exercises) {
        muscleVolume[ex.muscleGroup] = (muscleVolume[ex.muscleGroup] ?? 0) + ((ex.weight ?? 0) * ex.sets * ex.reps);
      }
    }

    if (muscleVolume.isEmpty) {
      return DataCard(
        child: EmptyState(
          icon: Icons.accessibility_new_outlined,
          title: 'No muscle data yet',
          message: 'Complete workouts to see muscle distribution',
        ),
      );
    }

    final sortedEntries = muscleVolume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalVolume = muscleVolume.values.fold(0.0, (a, b) => a + b);

    return DataCard(
      child: Column(
        children: sortedEntries.map((entry) {
          final pct = totalVolume > 0 ? (entry.value / totalVolume) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: _getMuscleColor(entry.key), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: AppTheme.space2),
                        Text(
                          entry.key,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${entry.value >= 1000 ? (entry.value / 1000).toStringAsFixed(1) : entry.value.round()} kg (${(pct * 100).toInt()}%)',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(_getMuscleColor(entry.key)),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getMuscleColor(String muscle) {
    final normalized = muscle.trim().toLowerCase();
    final colors = <String, Color>{
      'chest': Colors.redAccent,
      'back': Colors.blueAccent,
      'lats': Colors.blueAccent,
      'legs': Colors.amberAccent,
      'quads': Colors.amberAccent,
      'hamstrings': Colors.orangeAccent,
      'calves': Colors.yellowAccent,
      'shoulders': Colors.deepOrangeAccent,
      'arms': Colors.purpleAccent,
      'biceps': Colors.purpleAccent,
      'triceps': Colors.cyanAccent,
      'core': Colors.tealAccent,
      'glutes': Colors.pinkAccent,
      'cardio': Colors.greenAccent,
    };
    return colors[normalized] ?? Colors.grey;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// CONSISTENCY CARD
// ═══════════════════════════════════════════════════════════════════════════════════════

class _ConsistencyCard extends StatelessWidget {
  final List<dynamic> workouts;
  final int streak;

  const _ConsistencyCard({required this.workouts, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate consistency metrics
    final now = DateTime.now();
    final last30Days = workouts.where((w) {
      return now.difference(w.date).inDays <= 30;
    }).length;

    final last7Days = workouts.where((w) {
      return now.difference(w.date).inDays <= 7;
    }).length;

    final consistencyScore = _calculateConsistency(workouts);

    return DataCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ConsistencyMetric(
                  label: '30-Day Consistency',
                  value: '$last30Days / 30',
                  subtitle: '${(last30Days / 30 * 100).round()}%',
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: _ConsistencyMetric(
                  label: '7-Day Consistency',
                  value: '$last7Days / 7',
                  subtitle: '${(last7Days / 7 * 100).round()}%',
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: _ConsistencyMetric(
                  label: 'Current Streak',
                  value: '$streak days',
                  subtitle: streak > 0 ? 'Active' : 'Start today!',
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: AppTheme.space4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consistency Score',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$consistencyScore%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _getConsistencyColor(consistencyScore),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getConsistencyLabel(consistencyScore),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getConsistencyColor(consistencyScore),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getConsistencyDescription(consistencyScore),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateConsistency(List<dynamic> workouts) {
    if (workouts.isEmpty) return 0;

    final now = DateTime.now();
    final last90Days = workouts.where((w) => now.difference(w.date).inDays <= 90).length;
    final expected = 90 / 7 * 4; // 4 workouts per week
    return ((last90Days / expected) * 100).clamp(0, 100).round();
  }

  Color _getConsistencyColor(int score) {
    if (score >= 80) return const Color(0xFF007A33);
    if (score >= 60) return const Color(0xFFB8860B);
    if (score >= 40) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  String _getConsistencyLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Work';
  }

  String _getConsistencyDescription(int score) {
    if (score >= 80) return 'You\'re building a lifelong habit';
    if (score >= 60) return 'Solid foundation, keep pushing';
    if (score >= 40) return 'Inconsistent, aim for 3+/week';
    return 'Start with 2 workouts this week';
  }
}

class _ConsistencyMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _ConsistencyMetric({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}