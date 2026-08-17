// Local adaptive workout generator.
//
// Uses a template engine: each muscle focus maps to a set of movement
// "slots" (squat pattern, horizontal push, vertical pull, ...), each slot
// is filled from the exercise library filtered by available equipment,
// and the goal determines the sets/reps/rest scheme.
//
// This stands in for a real AI service — swap [generateWorkoutPlan]'s
// internals for an LLM call later without touching the UI.
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../exercise_library/domain/entities/exercise_entity.dart';
import '../../../../exercise_library/domain/repos/exercise_repository.dart';
import '../../domain/entities/workout_plan_entity.dart';
import '../../domain/repos/adaptive_workout_repository.dart';

class LocalAdaptiveWorkoutRepository implements AdaptiveWorkoutRepository {
  static const _plansKey = 'fitx_workout_plans';

  final SharedPreferences _prefs;
  final ExerciseRepository _exerciseRepository;
  final Random _random;

  LocalAdaptiveWorkoutRepository(
    this._prefs,
    this._exerciseRepository, {
    Random? random,
  }) : _random = random ?? Random();

  // ---------------------------------------------------------------------
  // Generation
  // ---------------------------------------------------------------------

  @override
  Future<WorkoutPlanEntity> generateWorkoutPlan({
    required String goals,
    required String restrictions,
    required List<String> availableEquipment,
    required String targetMuscleFocus,
    required int estimatedDuration,
  }) async {
    final allExercises = await _exerciseRepository.getAllExercises();
    final equipmentSet =
        availableEquipment.map((e) => e.toLowerCase()).toSet();

    final slots = _slotsForFocus(targetMuscleFocus);
    final scheme = _schemeForGoal(goals);

    // How many exercises fit the requested duration (~10-12 min each).
    final maxExercises = (estimatedDuration / 11).round().clamp(3, 7);

    final picked = <ExerciseEntity>[];
    final usedIds = <String>{};

    for (final slot in slots) {
      if (picked.length >= maxExercises) break;

      final candidates = allExercises.where((exercise) {
        if (usedIds.contains(exercise.id)) return false;
        if (!slot.matches(exercise)) return false;
        // Equipment filter — bodyweight is always allowed as a fallback.
        return equipmentSet.isEmpty ||
            equipmentSet.contains(exercise.equipment.toLowerCase());
      }).toList();

      if (candidates.isEmpty) continue;
      final choice = candidates[_random.nextInt(candidates.length)];
      picked.add(choice);
      usedIds.add(choice.id);
    }

    final now = DateTime.now();
    final planExercises = <WorkoutPlanExerciseEntity>[
      for (var i = 0; i < picked.length; i++)
        WorkoutPlanExerciseEntity(
          id: 'plan_ex_${now.millisecondsSinceEpoch}_$i',
          exerciseId: picked[i].id,
          exerciseName: picked[i].name,
          exerciseVideoUrl: picked[i].videoUrl,
          muscleGroup: picked[i].muscleGroup,
          equipment: picked[i].equipment,
          sets: scheme.sets,
          reps: scheme.reps,
          weight: picked[i].defaultWeight,
          duration: scheme.minutesPerExercise,
          restTime: scheme.restSeconds,
        ),
    ];

    final plan = WorkoutPlanEntity(
      id: 'plan_${now.millisecondsSinceEpoch}',
      userId: 'local',
      title: _titleForFocus(targetMuscleFocus),
      description: _descriptionFor(goals, targetMuscleFocus, scheme),
      generatedAt: now,
      validUntil: now.add(const Duration(days: 7)),
      exercises: planExercises,
      goals: goals,
      restrictions: restrictions,
      availableEquipment: availableEquipment.join(', '),
      estimatedDuration: estimatedDuration,
      targetMuscleFocus: targetMuscleFocus,
      createdAt: now,
      updatedAt: now,
    );

    await _savePlan(plan);
    return plan;
  }

  // ---------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------

  List<WorkoutPlanEntity> _readPlans() {
    final raw = _prefs.getString(_plansKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) =>
            WorkoutPlanEntity.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _writePlans(List<WorkoutPlanEntity> plans) => _prefs.setString(
      _plansKey, jsonEncode(plans.map((p) => p.toMap()).toList()));

  Future<void> _savePlan(WorkoutPlanEntity plan) async {
    final all = _readPlans()..add(plan);
    // Keep only the 20 most recent plans.
    all.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    await _writePlans(all.take(20).toList());
  }

  @override
  Future<List<WorkoutPlanEntity>> getRecentPlans({int limit = 10}) async {
    final all = _readPlans()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return all.take(limit).toList();
  }

  @override
  Future<void> deletePlan({required String planId}) async {
    final all = _readPlans()..removeWhere((p) => p.id == planId);
    await _writePlans(all);
  }

  // ---------------------------------------------------------------------
  // Template engine
  // ---------------------------------------------------------------------

  List<_Slot> _slotsForFocus(String focus) {
    switch (focus.toLowerCase()) {
      case 'upper body':
        return const [
          _Slot('Chest press', _isChestPress),
          _Slot('Back row', _isRow),
          _Slot('Shoulder press', _isShoulderPress),
          _Slot('Vertical pull', _isVerticalPull),
          _Slot('Side delts', _isLateralRaise),
          _Slot('Arms', _isArmWork),
        ];
      case 'lower body':
        return const [
          _Slot('Squat pattern', _isSquatPattern),
          _Slot('Hip hinge', _isHinge),
          _Slot('Lunge', _isLunge),
          _Slot('Hamstring isolation', _isLegCurl),
          _Slot('Calves', _isCalfWork),
          _Slot('Core', _isCore),
        ];
      case 'push':
        return const [
          _Slot('Flat press', _isChestPress),
          _Slot('Incline press', _isInclinePress),
          _Slot('Shoulder press', _isShoulderPress),
          _Slot('Side delts', _isLateralRaise),
          _Slot('Triceps', _isTricepWork),
        ];
      case 'pull':
        return const [
          _Slot('Vertical pull', _isVerticalPull),
          _Slot('Back row', _isRow),
          _Slot('Rear delts', _isFacePull),
          _Slot('Biceps', _isBicepWork),
          _Slot('Core', _isCore),
        ];
      case 'full body':
      default:
        return const [
          _Slot('Squat pattern', _isSquatPattern),
          _Slot('Push', _isChestPress),
          _Slot('Pull', _isRow),
          _Slot('Hip hinge', _isHinge),
          _Slot('Shoulders', _isShoulderPress),
          _Slot('Core', _isCore),
          _Slot('Conditioning', _isConditioning),
        ];
    }
  }

  _Scheme _schemeForGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'get strong':
        return const _Scheme(
            sets: 5, reps: 5, restSeconds: 120, minutesPerExercise: 6,
            label: '5×5 strength scheme with long rests');
      case 'lose weight':
        return const _Scheme(
            sets: 3, reps: 15, restSeconds: 45, minutesPerExercise: 4,
            label: 'Higher reps with short rests to keep the heart rate up');
      case 'increase endurance':
        return const _Scheme(
            sets: 3, reps: 20, restSeconds: 30, minutesPerExercise: 4,
            label: 'Light loads, high reps, minimal rest');
      case 'build muscle':
      default:
        return const _Scheme(
            sets: 4, reps: 10, restSeconds: 75, minutesPerExercise: 5,
            label: 'Classic hypertrophy: 4×10 with moderate rests');
    }
  }

  String _titleForFocus(String focus) {
    switch (focus.toLowerCase()) {
      case 'upper body':
        return 'Upper Body Builder';
      case 'lower body':
        return 'Lower Body Blast';
      case 'push':
        return 'Push Day';
      case 'pull':
        return 'Pull Day';
      case 'full body':
      default:
        return 'Full Body Session';
    }
  }

  String _descriptionFor(String goal, String focus, _Scheme scheme) {
    return 'A ${focus.toLowerCase()} plan for "$goal". ${scheme.label}.';
  }

  // Slot predicates -------------------------------------------------------

  static bool _nameContains(ExerciseEntity e, String needle) =>
      e.name.toLowerCase().contains(needle);

  static bool _isChestPress(ExerciseEntity e) =>
      e.muscleGroup == 'chest' && _nameContains(e, 'press');

  static bool _isInclinePress(ExerciseEntity e) =>
      e.muscleGroup == 'chest' && _nameContains(e, 'incline');

  static bool _isRow(ExerciseEntity e) =>
      e.muscleGroup == 'back' &&
      (_nameContains(e, 'row') || _nameContains(e, 'deadlift'));

  static bool _isVerticalPull(ExerciseEntity e) =>
      _nameContains(e, 'pull-up') || _nameContains(e, 'pulldown');

  static bool _isShoulderPress(ExerciseEntity e) =>
      e.muscleGroup == 'shoulders' && _nameContains(e, 'press');

  static bool _isLateralRaise(ExerciseEntity e) =>
      _nameContains(e, 'lateral raise');

  static bool _isFacePull(ExerciseEntity e) => _nameContains(e, 'face pull');

  static bool _isSquatPattern(ExerciseEntity e) =>
      _nameContains(e, 'squat') || _nameContains(e, 'leg press');

  static bool _isHinge(ExerciseEntity e) =>
      _nameContains(e, 'romanian deadlift') ||
      _nameContains(e, 'kettlebell swing') ||
      _nameContains(e, 'conventional deadlift');

  static bool _isLunge(ExerciseEntity e) => _nameContains(e, 'lunge');

  static bool _isLegCurl(ExerciseEntity e) => _nameContains(e, 'leg curl');

  static bool _isCalfWork(ExerciseEntity e) => _nameContains(e, 'calf');

  static bool _isArmWork(ExerciseEntity e) => e.muscleGroup == 'arms';

  static bool _isBicepWork(ExerciseEntity e) =>
      e.muscleGroup == 'arms' && _nameContains(e, 'curl');

  static bool _isTricepWork(ExerciseEntity e) =>
      e.muscleGroup == 'arms' &&
      (_nameContains(e, 'pushdown') || _nameContains(e, 'skull'));

  static bool _isCore(ExerciseEntity e) => e.muscleGroup == 'core';

  static bool _isConditioning(ExerciseEntity e) =>
      e.muscleGroup == 'cardio' || _nameContains(e, 'kettlebell');
}

/// A movement slot in a workout template.
class _Slot {
  final String label;
  final bool Function(ExerciseEntity) matches;

  const _Slot(this.label, this.matches);
}

/// Sets/reps/rest prescription for a training goal.
class _Scheme {
  final int sets;
  final int reps;
  final int restSeconds;
  final int minutesPerExercise;
  final String label;

  const _Scheme({
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.minutesPerExercise,
    required this.label,
  });
}
