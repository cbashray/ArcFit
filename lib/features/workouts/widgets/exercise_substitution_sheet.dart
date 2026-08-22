import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../presentation/providers/workout_providers.dart';

class ExerciseSubstitutionSheet extends ConsumerStatefulWidget {
  final String originalExerciseName;
  final String muscleGroup;
  final int exerciseIndex;

  const ExerciseSubstitutionSheet({
    super.key,
    required this.originalExerciseName,
    required this.muscleGroup,
    required this.exerciseIndex,
  });

  @override
  ConsumerState<ExerciseSubstitutionSheet> createState() =>
      _ExerciseSubstitutionSheetState();
}

class _ExerciseSubstitutionSheetState
    extends ConsumerState<ExerciseSubstitutionSheet> {
  late final List<_SubstitutionOption> _substitutes;

  @override
  void initState() {
    super.initState();
    _substitutes = _getSubstitutions(
      widget.originalExerciseName,
      widget.muscleGroup,
    );
  }

  List<_SubstitutionOption> _getSubstitutions(String name, String muscle) {
    final lower = name.toLowerCase();

    if (lower.contains('bench') || lower.contains('chest')) {
      return [
        const _SubstitutionOption(
          name: 'Dumbbell Bench Press',
          muscleGroup: 'Chest',
          equipment: 'Dumbbells',
          rationale: 'Greater range of motion, easier on shoulders & wrists.',
          difficulty: 'Intermediate',
        ),
        const _SubstitutionOption(
          name: 'Incline Dumbbell Press',
          muscleGroup: 'Upper Chest',
          equipment: 'Dumbbells + Bench',
          rationale: 'Targets clavicular head with joint-friendly path.',
          difficulty: 'Intermediate',
        ),
        const _SubstitutionOption(
          name: 'Chest Press Machine',
          muscleGroup: 'Chest',
          equipment: 'Machine',
          rationale: 'Fixed plane of motion, excellent for hypertrophy & safety.',
          difficulty: 'Beginner',
        ),
        const _SubstitutionOption(
          name: 'Weighted Push-Ups / Dips',
          muscleGroup: 'Chest / Triceps',
          equipment: 'Bodyweight',
          rationale: 'Great functional compound pressing movement.',
          difficulty: 'All Levels',
        ),
      ];
    } else if (lower.contains('squat') || lower.contains('leg')) {
      return [
        const _SubstitutionOption(
          name: 'Leg Press',
          muscleGroup: 'Quads / Glutes',
          equipment: 'Machine',
          rationale: 'Removes spinal loading while overloading the quads heavily.',
          difficulty: 'Beginner',
        ),
        const _SubstitutionOption(
          name: 'Bulgarian Split Squat',
          muscleGroup: 'Quads / Glutes',
          equipment: 'Dumbbells',
          rationale: 'Fixes muscular imbalances, heavy quad stimulus with less weight.',
          difficulty: 'Intermediate',
        ),
        const _SubstitutionOption(
          name: 'Goblet Squat',
          muscleGroup: 'Quads / Core',
          equipment: 'Dumbbell / Kettlebell',
          rationale: 'Encourages upright torso posture and deep hip flexion.',
          difficulty: 'Beginner',
        ),
        const _SubstitutionOption(
          name: 'Hack Squat',
          muscleGroup: 'Quads',
          equipment: 'Machine',
          rationale: 'Isolates the knee extensors directly with back support.',
          difficulty: 'Intermediate',
        ),
      ];
    } else if (lower.contains('deadlift') || lower.contains('hamstring')) {
      return [
        const _SubstitutionOption(
          name: 'Romanian Deadlift (RDL)',
          muscleGroup: 'Hamstrings / Glutes',
          equipment: 'Barbell / Dumbbells',
          rationale: 'Pure posterior chain stretch with maximum hamstring recruitment.',
          difficulty: 'Intermediate',
        ),
        const _SubstitutionOption(
          name: 'Lying Leg Curl',
          muscleGroup: 'Hamstrings',
          equipment: 'Machine',
          rationale: 'Isolates knee flexion without lower back fatigue.',
          difficulty: 'Beginner',
        ),
        const _SubstitutionOption(
          name: 'Back Hyperextensions',
          muscleGroup: 'Lower Back / Hamstrings',
          equipment: 'Roman Chair',
          rationale: 'Strengthens posterior chain with lower axial fatigue.',
          difficulty: 'Beginner',
        ),
      ];
    } else if (lower.contains('pull') || lower.contains('row') || lower.contains('lat')) {
      return [
        const _SubstitutionOption(
          name: 'Seated Cable Row',
          muscleGroup: 'Mid-Back / Lats',
          equipment: 'Cable',
          rationale: 'Constant tension throughout the entire pull and squeeze.',
          difficulty: 'Beginner',
        ),
        const _SubstitutionOption(
          name: 'Single-Arm Dumbbell Row',
          muscleGroup: 'Lats',
          equipment: 'Dumbbell',
          rationale: 'Allows natural rotation and deep lat stretch at bottom.',
          difficulty: 'Intermediate',
        ),
        const _SubstitutionOption(
          name: 'Lat Pulldown',
          muscleGroup: 'Lats',
          equipment: 'Cable Machine',
          rationale: 'Vertical pulling alternative when pull-up bar is occupied.',
          difficulty: 'Beginner',
        ),
        const _SubstitutionOption(
          name: 'Chest-Supported T-Bar Row',
          muscleGroup: 'Upper Back',
          equipment: 'Machine / Barbell',
          rationale: 'Eliminates lower back strain completely.',
          difficulty: 'Intermediate',
        ),
      ];
    } else if (lower.contains('shoulder') || lower.contains('press') || lower.contains('delt')) {
      return [
        const _SubstitutionOption(
          name: 'Seated Dumbbell Shoulder Press',
          muscleGroup: 'Shoulders',
          equipment: 'Dumbbells',
          rationale: 'Independent arm movement with comfortable wrist angle.',
          difficulty: 'Intermediate',
        ),
        const _SubstitutionOption(
          name: 'Cable Lateral Raise',
          muscleGroup: 'Side Delts',
          equipment: 'Cable',
          rationale: 'Constant lateral delt tension even at the bottom position.',
          difficulty: 'Beginner',
        ),
        const _SubstitutionOption(
          name: 'Machine Shoulder Press',
          muscleGroup: 'Front / Side Delts',
          equipment: 'Machine',
          rationale: 'High stability for pushing to absolute failure.',
          difficulty: 'Beginner',
        ),
      ];
    } else {
      return [
        _SubstitutionOption(
          name: 'Dumbbell $name Alternative',
          muscleGroup: widget.muscleGroup,
          equipment: 'Dumbbells',
          rationale: 'Allows unilateral balance and natural joint path.',
          difficulty: 'All Levels',
        ),
        _SubstitutionOption(
          name: 'Cable $name Variation',
          muscleGroup: widget.muscleGroup,
          equipment: 'Cable Machine',
          rationale: 'Smooth constant resistance profile throughout the rep.',
          difficulty: 'All Levels',
        ),
        _SubstitutionOption(
          name: 'Bodyweight $name Progression',
          muscleGroup: widget.muscleGroup,
          equipment: 'Bodyweight',
          rationale: 'Low joint impact and great mind-muscle connection.',
          difficulty: 'All Levels',
        ),
      ];
    }
  }

  void _applySubstitution(_SubstitutionOption sub) {
    // Update the exercise in active draft workout
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final active = ref.read(activeWorkoutProvider);
    if (active == null) return;

    if (widget.exerciseIndex < active.exercises.length) {
      final old = active.exercises[widget.exerciseIndex];
      final newExercise = DraftExercise(
        exerciseId: sub.name.toLowerCase().replaceAll(' ', '_'),
        name: sub.name,
        muscleGroup: sub.muscleGroup,
        sets: old.sets,
        reps: old.reps,
        weight: old.weight,
        isWarmup: old.isWarmup,
      );

      notifier.updateExercise(widget.exerciseIndex, newExercise);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Replaced with ${sub.name} ✨'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, AppTheme.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('✨', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Exercise Substitution',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Alternatives for "${widget.originalExerciseName}"',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Substitutes list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _substitutes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final sub = _substitutes[index];
                return InkWell(
                  onTap: () => _applySubstitution(sub),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF252525)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333333)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sub.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryBlue
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sub.equipment,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sub.rationale,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🎯 ${sub.muscleGroup}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const Text(
                              'Tap to replace ➔',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubstitutionOption {
  final String name;
  final String muscleGroup;
  final String equipment;
  final String rationale;
  final String difficulty;

  const _SubstitutionOption({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.rationale,
    required this.difficulty,
  });
}

/// Helper function to show substitution modal
void showExerciseSubstitutionModal({
  required BuildContext context,
  required String exerciseName,
  required String muscleGroup,
  required int exerciseIndex,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ExerciseSubstitutionSheet(
      originalExerciseName: exerciseName,
      muscleGroup: muscleGroup,
      exerciseIndex: exerciseIndex,
    ),
  );
}
