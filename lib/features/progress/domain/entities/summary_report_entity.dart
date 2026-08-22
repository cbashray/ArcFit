import 'package:equatable/equatable.dart';

import '../../../workouts/domain/entities/workout_entity.dart';

enum ReportPeriod {
  weekly,
  monthly,
}

class SummaryReportEntity extends Equatable {
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalWorkouts;
  final int totalSets;
  final double totalVolumeKg;
  final double priorPeriodVolumeKg;
  final int avgDurationMinutes;
  final int prsCount;
  final int streakDays;
  final Map<String, int> muscleGroupDistribution;
  final int consistencyScore;

  const SummaryReportEntity({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalVolumeKg,
    required this.priorPeriodVolumeKg,
    required this.avgDurationMinutes,
    required this.prsCount,
    required this.streakDays,
    required this.muscleGroupDistribution,
    required this.consistencyScore,
  });

  double get volumeChangePct {
    if (priorPeriodVolumeKg <= 0) return 0.0;
    return ((totalVolumeKg - priorPeriodVolumeKg) / priorPeriodVolumeKg) * 100;
  }

  String get topMuscleGroup {
    if (muscleGroupDistribution.isEmpty) return 'Full Body';
    final sorted = muscleGroupDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  factory SummaryReportEntity.generate({
    required ReportPeriod period,
    required List<WorkoutEntity> allWorkouts,
    int prsCount = 0,
    int streakDays = 0,
  }) {
    final now = DateTime.now();
    final days = period == ReportPeriod.weekly ? 7 : 30;
    final startDate = now.subtract(Duration(days: days));
    final priorStartDate = startDate.subtract(Duration(days: days));

    // Filter current period workouts
    final currentWorkouts = allWorkouts.where((w) {
      return w.date.isAfter(startDate) && !w.date.isAfter(now);
    }).toList();

    // Filter prior period workouts
    final priorWorkouts = allWorkouts.where((w) {
      return w.date.isAfter(priorStartDate) && !w.date.isAfter(startDate);
    }).toList();

    final totalVolume =
        currentWorkouts.fold<double>(0, (sum, w) => sum + w.totalVolume);
    final priorVolume =
        priorWorkouts.fold<double>(0, (sum, w) => sum + w.totalVolume);
    final totalSets =
        currentWorkouts.fold<int>(0, (sum, w) => sum + w.totalSets);

    final totalDuration = currentWorkouts.fold<double>(
        0, (sum, w) => sum + w.durationMinutes);
    final avgDuration = currentWorkouts.isEmpty
        ? 0
        : (totalDuration / currentWorkouts.length).round();

    // Muscle group distribution
    final muscleCounts = <String, int>{};
    for (final w in currentWorkouts) {
      for (final ex in w.exercises) {
        final name = ex.exerciseName.toLowerCase();
        String grp = 'Other';
        if (name.contains('bench') || name.contains('chest')) {
          grp = 'Chest';
        } else if (name.contains('squat') || name.contains('leg') || name.contains('lunge')) {
          grp = 'Quads/Legs';
        } else if (name.contains('deadlift') || name.contains('hamstring') || name.contains('curl')) {
          grp = 'Hamstrings';
        } else if (name.contains('pull') || name.contains('row') || name.contains('lat')) {
          grp = 'Back';
        } else if (name.contains('press') || name.contains('delt') || name.contains('raise')) {
          grp = 'Shoulders';
        } else if (name.contains('bicep') || name.contains('tricep') || name.contains('arm')) {
          grp = 'Arms';
        }
        muscleCounts[grp] = (muscleCounts[grp] ?? 0) + ex.sets;
      }
    }

    // Consistency score (0-100) based on target workouts
    final targetWorkouts = period == ReportPeriod.weekly ? 4 : 16;
    final score = ((currentWorkouts.length / targetWorkouts) * 100)
        .clamp(0, 100)
        .toInt();

    return SummaryReportEntity(
      period: period,
      startDate: startDate,
      endDate: now,
      totalWorkouts: currentWorkouts.length,
      totalSets: totalSets,
      totalVolumeKg: totalVolume,
      priorPeriodVolumeKg: priorVolume,
      avgDurationMinutes: avgDuration,
      prsCount: prsCount,
      streakDays: streakDays,
      muscleGroupDistribution: muscleCounts,
      consistencyScore: score,
    );
  }

  @override
  List<Object?> get props => [
        period,
        startDate,
        endDate,
        totalWorkouts,
        totalSets,
        totalVolumeKg,
        priorPeriodVolumeKg,
        avgDurationMinutes,
        prsCount,
        streakDays,
        muscleGroupDistribution,
        consistencyScore,
      ];
}
