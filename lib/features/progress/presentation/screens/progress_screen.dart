import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../workouts/domain/entities/workout_entity.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';


class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress 📊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.monitor_weight_outlined),
            tooltip: 'Body Metrics',
            onPressed: () => context.pushNamed('bodyMetrics'),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Volume'),
            Tab(text: 'Strength'),
            Tab(text: 'PRs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _VolumeTab(),
          _StrengthTab(),
          _PRTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Volume tab
// ─────────────────────────────────────────────────────────────────────────────

class _VolumeTab extends ConsumerWidget {
  const _VolumeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);

    return workoutsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (workouts) {
        if (workouts.isEmpty) {
          return _emptyState(
            icon: Icons.show_chart_rounded,
            message: 'No workout data yet',
            hint: 'Log workouts to see your volume trends',
          );
        }

        // Build weekly volume (total kg × reps summed)
        final weeklyData = _buildWeeklyVolume(workouts);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ChartCard(
              title: 'Weekly Volume (kg)',
              subtitle: 'Total weight × reps per week',
              child: _VolumeBarChart(data: weeklyData),
            ),
            const SizedBox(height: 16),
            _StatSummaryRow(workouts: workouts),
            const SizedBox(height: 16),
            _WorkoutFrequencyChart(workouts: workouts),
          ],
        );
      },
    );
  }

  List<({DateTime weekStart, double volume})> _buildWeeklyVolume(
      List<WorkoutEntity> workouts) {
    final Map<DateTime, double> weekly = {};
    for (final w in workouts) {
      final weekStart = _startOfWeek(w.date);
      final volume = w.exercises.fold<double>(
        0,
        (sum, ex) => sum + (ex.weight ?? 0) * ex.reps * ex.sets,
      );
      weekly[weekStart] = (weekly[weekStart] ?? 0) + volume;
    }
    final entries = weekly.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map((e) => (weekStart: e.key, volume: e.value))
        .take(12)
        .toList();
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }
}

class _VolumeBarChart extends StatelessWidget {
  final List<({DateTime weekStart, double volume})> data;

  const _VolumeBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 160);

    final maxY = data.map((d) => d.volume).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                final label = value >= 1000
                    ? '${(value / 1000).toStringAsFixed(1)}k'
                    : value.round().toString();
                return Text(label,
                    style:
                        const TextStyle(fontSize: 10, color: Colors.grey));
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                final date = data[idx].weekStart;
                return Text(
                  DateFormat('MMd').format(date),
                  style:
                      const TextStyle(fontSize: 9, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.volume,
                width: 14,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.secondaryBlue],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StatSummaryRow extends StatelessWidget {
  final List<WorkoutEntity> workouts;
  const _StatSummaryRow({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final totalVolume = workouts.fold<double>(
      0,
      (sum, w) => sum + w.exercises.fold<double>(
            0,
            (s, ex) => s + (ex.weight ?? 0) * ex.reps * ex.sets,
          ),
    );
    final totalSets =
        workouts.fold<int>(0, (sum, w) => sum + w.totalSets);
    final avgDuration =
        workouts.isEmpty
            ? 0.0
            : workouts.fold<double>(
                    0, (sum, w) => sum + w.durationMinutes) /
                workouts.length;

    return Row(
      children: [
        Expanded(
            child: _MiniStat(
                label: 'Total Volume',
                value: totalVolume >= 1000
                    ? '${(totalVolume / 1000).toStringAsFixed(1)}k kg'
                    : '${totalVolume.round()} kg',
                color: AppTheme.primaryGreen)),
        const SizedBox(width: 10),
        Expanded(
            child: _MiniStat(
                label: 'Total Sets',
                value: '$totalSets',
                color: AppTheme.secondaryBlue)),
        const SizedBox(width: 10),
        Expanded(
            child: _MiniStat(
                label: 'Avg Duration',
                value: '${avgDuration.round()} min',
                color: AppTheme.accentOrange)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _WorkoutFrequencyChart extends StatelessWidget {
  final List<WorkoutEntity> workouts;

  const _WorkoutFrequencyChart({required this.workouts});

  @override
  Widget build(BuildContext context) {
    // Count workouts per day-of-week
    final dayCount = List.filled(7, 0);
    for (final w in workouts) {
      dayCount[w.date.weekday - 1]++;
    }
    final maxY = dayCount.reduce((a, b) => a > b ? a : b).toDouble();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _ChartCard(
      title: 'Workout Days',
      subtitle: 'Most active day of the week',
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 5 : maxY * 1.3,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                  return Text(days[idx],
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey));
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: dayCount[i].toDouble(),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                  color: dayCount[i] == maxY && maxY > 0
                      ? AppTheme.accentOrange
                      : AppTheme.primaryGreen.withValues(alpha: 0.7),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strength tab
// ─────────────────────────────────────────────────────────────────────────────

class _StrengthTab extends ConsumerStatefulWidget {
  const _StrengthTab();

  @override
  ConsumerState<_StrengthTab> createState() => _StrengthTabState();
}

class _StrengthTabState extends ConsumerState<_StrengthTab> {
  String? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsProvider);

    return workoutsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (workouts) {
        // Build exercise set
        final exerciseNames = workouts
            .expand((w) => w.exercises.map((e) => e.exerciseName))
            .where((name) => workouts.any((w) => w.exercises.any(
                (e) => e.exerciseName == name && (e.weight ?? 0) > 0)))
            .toSet()
            .toList()
          ..sort();

        if (exerciseNames.isEmpty) {
          return _emptyState(
            icon: Icons.trending_up_rounded,
            message: 'Log weighted exercises',
            hint: 'Strength trends appear once you have exercise history',
          );
        }

        _selectedExercise ??= exerciseNames.first;

        // Get weight-over-time data for selected exercise
        final data = workouts
            .where((w) => w.exercises
                .any((e) => e.exerciseName == _selectedExercise))
            .map((w) {
          final ex = w.exercises.firstWhere(
              (e) => e.exerciseName == _selectedExercise);
          return (date: w.date, weight: ex.weight ?? 0.0);
        })
            .where((d) => d.weight > 0)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Exercise selector
            DropdownButtonFormField<String>(
              initialValue: _selectedExercise,
              decoration: const InputDecoration(
                labelText: 'Exercise',
                isDense: true,
              ),
              items: exerciseNames
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name,
                            style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedExercise = value),
            ),
            const SizedBox(height: 16),

            if (data.length >= 2)
              _ChartCard(
                title: '$_selectedExercise — Weight',
                subtitle: 'Weight lifted over time (kg)',
                child: _LineChart(data: data),
              )
            else
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Log more sessions with $_selectedExercise to see a trend',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<({DateTime date, double weight})> data;

  const _LineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY =
        data.map((d) => d.weight).reduce((a, b) => a > b ? a : b);
    final minY =
        data.map((d) => d.weight).reduce((a, b) => a < b ? a : b);

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    return LineChart(
      LineChartData(
        minY: (minY * 0.9).floorToDouble(),
        maxY: (maxY * 1.1).ceilToDouble(),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                '${value.round()}',
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  DateFormat('M/d').format(data[idx].date),
                  style: const TextStyle(
                      fontSize: 9, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppTheme.secondaryBlue, AppTheme.primaryGreen],
            ),
            barWidth: 3,
            dotData: FlDotData(
              getDotPainter: (spot, pct, barData, idx) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primaryGreen,
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.2),
                  AppTheme.primaryGreen.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PR Tab
// ─────────────────────────────────────────────────────────────────────────────

class _PRTab extends ConsumerWidget {
  const _PRTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prsAsync = ref.watch(personalRecordsProvider);

    return prsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (prs) {
        if (prs.isEmpty) {
          return _emptyState(
            icon: Icons.emoji_events_outlined,
            message: 'No personal records yet',
            hint: 'Beat your previous best weight to set a PR',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: prs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final pr = prs[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pr.exerciseName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text(
                          '${pr.maxWeight.round()} kg × ${pr.repsAtMaxWeight} reps',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${pr.estimatedOneRepMax.round()} kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const Text('est. 1RM',
                          style: TextStyle(
                              fontSize: 10, color: AppTheme.primaryGreen)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _emptyState({
  required IconData icon,
  required String message,
  required String hint,
}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(message,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(hint,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600)),
      ],
    ),
  );
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: child),
        ],
      ),
    );
  }
}
