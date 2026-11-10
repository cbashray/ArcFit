import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/workout_template_entity.dart';
import '../../domain/repos/workout_template_repository.dart';

class LocalWorkoutTemplateRepository implements WorkoutTemplateRepository {
  final SharedPreferences _prefs;
  static const String _templatesKey = 'arcfit_workout_templates';

  LocalWorkoutTemplateRepository(this._prefs);

  @override
  Future<List<WorkoutTemplateEntity>> getTemplates() async {
    await seedDefaultTemplatesIfEmpty();
    final rawList = _prefs.getStringList(_templatesKey) ?? [];
    final templates = rawList
        .map((e) =>
            WorkoutTemplateEntity.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    // Auto-migrate templates that had null target weights
    bool needsUpdate = false;
    for (var i = 0; i < templates.length; i++) {
      final t = templates[i];
      if (t.exercises.any((e) => e.targetWeight == null)) {
        final updatedExercises = t.exercises.map((e) {
          if (e.targetWeight != null) return e;
          return TemplateExerciseEntity(
            exerciseId: e.exerciseId,
            exerciseName: e.exerciseName,
            muscleGroup: e.muscleGroup,
            defaultSets: e.defaultSets,
            defaultReps: e.defaultReps,
            targetWeight: _fallbackWeight(e.exerciseName),
          );
        }).toList();
        templates[i] = t.copyWith(exercises: updatedExercises);
        needsUpdate = true;
      }
    }
    if (needsUpdate) {
      final updatedList = templates.map((t) => jsonEncode(t.toJson())).toList();
      await _prefs.setStringList(_templatesKey, updatedList);
    }

    return templates;
  }

  static double _fallbackWeight(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('deadlift')) return 100.0;
    if (lower.contains('squat') && !lower.contains('split')) return 80.0;
    if (lower.contains('bench') || lower.contains('chest press')) return 60.0;
    if (lower.contains('leg press')) return 120.0;
    if (lower.contains('row')) return 50.0;
    if (lower.contains('pulldown')) return 50.0;
    if (lower.contains('shoulder press') || lower.contains('overhead')) return 40.0;
    if (lower.contains('curl')) return 14.0;
    if (lower.contains('lateral')) return 10.0;
    if (lower.contains('tricep')) return 25.0;
    if (lower.contains('leg curl')) return 45.0;
    if (lower.contains('calf')) return 40.0;
    if (lower.contains('plank') || lower.contains('pull-up') || lower.contains('push-up')) return 10.0;
    return 20.0;
  }

  @override
  Future<WorkoutTemplateEntity?> getTemplateById(String id) async {
    final templates = await getTemplates();
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveTemplate(WorkoutTemplateEntity template) async {
    final templates = await getTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
    } else {
      templates.insert(0, template);
    }
    final rawList = templates.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_templatesKey, rawList);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final templates = await getTemplates();
    templates.removeWhere((t) => t.id == id);
    final rawList = templates.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_templatesKey, rawList);
  }

  @override
  Future<void> seedDefaultTemplatesIfEmpty() async {
    final rawList = _prefs.getStringList(_templatesKey);
    if (rawList != null && rawList.isNotEmpty) return;

    final defaults = <WorkoutTemplateEntity>[
      WorkoutTemplateEntity(
        id: 'template_push_hypertrophy',
        title: 'Push Day — Hypertrophy',
        description: 'Target chest, front delts, and triceps for maximum growth.',
        category: TemplateCategory.push,
        createdAt: DateTime.now(),
        exercises: const [
          TemplateExerciseEntity(
            exerciseId: 'bench_press',
            exerciseName: 'Barbell Bench Press',
            muscleGroup: 'Chest',
            defaultSets: 4,
            defaultReps: 8,
            targetWeight: 60.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'incline_dumbbell_press',
            exerciseName: 'Incline Dumbbell Press',
            muscleGroup: 'Chest',
            defaultSets: 3,
            defaultReps: 10,
            targetWeight: 22.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'overhead_press',
            exerciseName: 'Overhead Shoulder Press',
            muscleGroup: 'Shoulders',
            defaultSets: 3,
            defaultReps: 10,
            targetWeight: 40.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'lateral_raise',
            exerciseName: 'Dumbbell Lateral Raise',
            muscleGroup: 'Shoulders',
            defaultSets: 4,
            defaultReps: 15,
            targetWeight: 10.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'tricep_pushdown',
            exerciseName: 'Tricep Rope Pushdown',
            muscleGroup: 'Triceps',
            defaultSets: 3,
            defaultReps: 12,
            targetWeight: 25.0,
          ),
        ],
      ),
      WorkoutTemplateEntity(
        id: 'template_pull_strength',
        title: 'Pull Day — Back & Biceps',
        description: 'Build a wide V-taper and powerful bicep strength.',
        category: TemplateCategory.pull,
        createdAt: DateTime.now(),
        exercises: const [
          TemplateExerciseEntity(
            exerciseId: 'deadlift',
            exerciseName: 'Conventional Deadlift',
            muscleGroup: 'Back',
            defaultSets: 4,
            defaultReps: 6,
            targetWeight: 100.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'barbell_row',
            exerciseName: 'Bent-Over Barbell Row',
            muscleGroup: 'Back',
            defaultSets: 4,
            defaultReps: 8,
            targetWeight: 50.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'lat_pulldown',
            exerciseName: 'Lat Pulldown',
            muscleGroup: 'Back',
            defaultSets: 3,
            defaultReps: 10,
            targetWeight: 50.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'face_pull',
            exerciseName: 'Cable Face Pull',
            muscleGroup: 'Shoulders',
            defaultSets: 3,
            defaultReps: 15,
            targetWeight: 20.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'bicep_curl',
            exerciseName: 'Dumbbell Bicep Curl',
            muscleGroup: 'Biceps',
            defaultSets: 3,
            defaultReps: 12,
            targetWeight: 14.0,
          ),
        ],
      ),
      WorkoutTemplateEntity(
        id: 'template_legs_destroyer',
        title: 'Legs — Quad & Hamstring Focus',
        description: 'Heavy compound leg training for lower body power.',
        category: TemplateCategory.legs,
        createdAt: DateTime.now(),
        exercises: const [
          TemplateExerciseEntity(
            exerciseId: 'barbell_squat',
            exerciseName: 'Barbell Back Squat',
            muscleGroup: 'Quads',
            defaultSets: 4,
            defaultReps: 8,
            targetWeight: 80.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'romanian_deadlift',
            exerciseName: 'Romanian Deadlift (RDL)',
            muscleGroup: 'Hamstrings',
            defaultSets: 3,
            defaultReps: 10,
            targetWeight: 70.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'leg_press',
            exerciseName: 'Leg Press',
            muscleGroup: 'Quads',
            defaultSets: 3,
            defaultReps: 12,
            targetWeight: 120.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'leg_curl',
            exerciseName: 'Lying Leg Curl',
            muscleGroup: 'Hamstrings',
            defaultSets: 3,
            defaultReps: 12,
            targetWeight: 45.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'calf_raise',
            exerciseName: 'Standing Calf Raise',
            muscleGroup: 'Calves',
            defaultSets: 4,
            defaultReps: 15,
            targetWeight: 40.0,
          ),
        ],
      ),
      WorkoutTemplateEntity(
        id: 'template_upper_power',
        title: 'Upper Body — Power & Tone',
        description: 'Complete upper body compound routine.',
        category: TemplateCategory.upper,
        createdAt: DateTime.now(),
        exercises: const [
          TemplateExerciseEntity(
            exerciseId: 'incline_bench',
            exerciseName: 'Incline Barbell Bench Press',
            muscleGroup: 'Chest',
            defaultSets: 4,
            defaultReps: 8,
            targetWeight: 50.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'pull_up',
            exerciseName: 'Weighted Pull-Ups',
            muscleGroup: 'Back',
            defaultSets: 3,
            defaultReps: 8,
            targetWeight: 10.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'seated_cable_row',
            exerciseName: 'Seated Cable Row',
            muscleGroup: 'Back',
            defaultSets: 3,
            defaultReps: 10,
            targetWeight: 50.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'dumbbell_shoulder_press',
            exerciseName: 'Seated Dumbbell Shoulder Press',
            muscleGroup: 'Shoulders',
            defaultSets: 3,
            defaultReps: 10,
            targetWeight: 18.0,
          ),
        ],
      ),
      WorkoutTemplateEntity(
        id: 'template_full_body',
        title: 'Full Body — Strength Circuit',
        description: 'Time-efficient full body workout hitting all major muscle groups.',
        category: TemplateCategory.fullBody,
        createdAt: DateTime.now(),
        exercises: const [
          TemplateExerciseEntity(
            exerciseId: 'barbell_squat',
            exerciseName: 'Barbell Back Squat',
            muscleGroup: 'Quads',
            defaultSets: 3,
            defaultReps: 8,
            targetWeight: 70.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'bench_press',
            exerciseName: 'Barbell Bench Press',
            muscleGroup: 'Chest',
            defaultSets: 3,
            defaultReps: 8,
            targetWeight: 60.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'lat_pulldown',
            exerciseName: 'Lat Pulldown',
            muscleGroup: 'Back',
            defaultSets: 3,
            defaultReps: 10,
            targetWeight: 50.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'dumbbell_lunge',
            exerciseName: 'Walking Dumbbell Lunges',
            muscleGroup: 'Legs',
            defaultSets: 3,
            defaultReps: 12,
            targetWeight: 16.0,
          ),
          TemplateExerciseEntity(
            exerciseId: 'plank',
            exerciseName: 'Weighted Plank',
            muscleGroup: 'Core',
            defaultSets: 3,
            defaultReps: 60,
            targetWeight: 10.0,
          ),
        ],
      ),
    ];

    final encoded = defaults.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_templatesKey, encoded);
  }
}
