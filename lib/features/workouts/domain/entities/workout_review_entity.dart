import 'package:equatable/equatable.dart';

import 'workout_entity.dart';

class WorkoutReviewEntity extends Equatable {
  final double scoreOutOfTen;
  final String performanceVerdict;
  final String volumeAssessment;
  final String muscleBalanceAnalysis;
  final int estimatedRecoveryHours;
  final List<String> strengthHighlights;
  final List<String> actionableTips;

  const WorkoutReviewEntity({
    required this.scoreOutOfTen,
    required this.performanceVerdict,
    required this.volumeAssessment,
    required this.muscleBalanceAnalysis,
    required this.estimatedRecoveryHours,
    required this.strengthHighlights,
    required this.actionableTips,
  });

  factory WorkoutReviewEntity.fromWorkout(
    WorkoutEntity workout, {
    List<String> newPRs = const [],
  }) {
    final totalVolume = workout.totalVolume;
    final totalSets = workout.totalSets;
    final exCount = workout.exercises.length;

    // Calculate score based on volume and sets
    double baseScore = 7.5;
    if (totalSets >= 12) baseScore += 1.0;
    if (totalSets >= 18) baseScore += 0.5;
    if (newPRs.isNotEmpty) baseScore += 1.0;
    final score = baseScore.clamp(5.0, 10.0);

    // Performance Verdict
    final verdict = score >= 9.0
        ? 'Elite Performance 🔥'
        : score >= 8.0
            ? 'Solid Hypertrophy Session 💪'
            : 'Good Consistency Day 👍';

    // Volume Assessment
    final volumeText = totalVolume > 5000
        ? 'High total tonnage ($totalVolume kg) across $totalSets sets — excellent progressive overload.'
        : totalVolume > 2000
            ? 'Moderate volume ($totalVolume kg) with $totalSets focused sets.'
            : 'Light maintenance volume ($totalVolume kg).';

    // Muscle analysis
    final muscleCounts = <String, int>{};
    for (final ex in workout.exercises) {
      final name = ex.exerciseName.toLowerCase();
      String grp = 'General';
      if (name.contains('bench') || name.contains('chest') || name.contains('push')) {
        grp = 'Chest';
      } else if (name.contains('squat') || name.contains('leg') || name.contains('lunge')) {
        grp = 'Quads/Legs';
      } else if (name.contains('deadlift') || name.contains('hamstring') || name.contains('curl')) {
        grp = 'Hamstrings/Posterior';
      } else if (name.contains('pull') || name.contains('row') || name.contains('lat')) {
        grp = 'Back';
      } else if (name.contains('press') || name.contains('delt') || name.contains('raise')) {
        grp = 'Shoulders';
      }
      muscleCounts[grp] = (muscleCounts[grp] ?? 0) + ex.sets;
    }

    final topMuscle = muscleCounts.entries.isEmpty
        ? 'Full Body'
        : (muscleCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    final balanceText =
        'Primary focus was on $topMuscle ($exCount movements). Effective stimulus for target motor units.';

    // Recovery estimation
    final recovery = totalSets > 16 ? 48 : (totalSets > 10 ? 36 : 24);

    // Highlights
    final highlights = <String>[];
    if (newPRs.isNotEmpty) {
      highlights.add('🎉 Set ${newPRs.length} new Personal Record(s)!');
    }
    highlights.add('Completed $totalSets working sets with sustained intensity.');
    highlights.add('Total training volume accumulated: ${(totalVolume / 1000).toStringAsFixed(1)}k kg.');

    // Tips
    final tips = <String>[
      'Aim for 25-40g fast-digesting protein within 2 hours post-workout.',
      'Rehydrate with at least 500-750ml electrolyte-rich fluids today.',
      'Allow $recovery hours before training $topMuscle again at high intensity.',
    ];

    return WorkoutReviewEntity(
      scoreOutOfTen: score,
      performanceVerdict: verdict,
      volumeAssessment: volumeText,
      muscleBalanceAnalysis: balanceText,
      estimatedRecoveryHours: recovery,
      strengthHighlights: highlights,
      actionableTips: tips,
    );
  }

  @override
  List<Object?> get props => [
        scoreOutOfTen,
        performanceVerdict,
        volumeAssessment,
        muscleBalanceAnalysis,
        estimatedRecoveryHours,
        strengthHighlights,
        actionableTips,
      ];
}
