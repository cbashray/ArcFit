import 'package:arcfit/features/exercise_library/data/repos/local_exercise_repository.dart';
import 'package:arcfit/features/exercise_library/data/seed/exercise_seed_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = LocalExerciseRepository();

  test('ExerciseSeedData contains all 120 requested exercises across Chest, Back, Biceps, Triceps, Shoulders, and Legs', () async {
    final exercises = await repo.getAllExercises();
    expect(exercises.length, greaterThanOrEqualTo(120));

    final chest = await repo.getExercisesByMuscleGroup('Chest');
    expect(chest.length, greaterThanOrEqualTo(20));

    final back = await repo.getExercisesByMuscleGroup('Back');
    expect(back.length, greaterThanOrEqualTo(20));

    final biceps = await repo.getExercisesByMuscleGroup('Biceps');
    expect(biceps.length, greaterThanOrEqualTo(20));

    final triceps = await repo.getExercisesByMuscleGroup('Triceps');
    expect(triceps.length, greaterThanOrEqualTo(20));

    final shoulders = await repo.getExercisesByMuscleGroup('Shoulders');
    expect(shoulders.length, greaterThanOrEqualTo(20));

    final legs = await repo.getExercisesByMuscleGroup('Legs');
    expect(legs.length, greaterThanOrEqualTo(20));
  });

  test('Specific requested exercises are present and searchable', () async {
    final sampleNames = [
      'Flat Barbell Bench Press',
      'Incline Barbell Bench Press',
      'Weighted Push-Up',
      'Chest-Leaning Parallel Bar Dips',
      'High-to-Low Cable Crossover',
      'Wide-Grip Lat Pulldown',
      'Wide-Grip Seated Cable Row',
      'Meadows Row',
      'Inverted (Bodyweight) Row',
      'Machine Preacher Curl',
      'Bayesian Cable Curl',
      '21s',
      'Floor Press',
      'JM Press',
      'Tate Press',
      'Arnold Press',
      'Push Press',
      'Half-Kneeling Single-Arm Press',
      'Cable Lateral Raise',
      'Reverse Pec Deck',
      'Hack Squat',
      'Nordic Curl',
      'Barbell Hip Thrust',
    ];

    for (final name in sampleNames) {
      final matches = await repo.searchExercises(name);
      expect(matches, isNotEmpty, reason: 'Exercise "$name" should be found');
      expect(matches.first.formCue, isNotEmpty);
      expect(matches.first.description, isNotEmpty);
      expect(matches.first.equipment, isNotEmpty);
    }
  });

  test('Muscle groups list includes Chest, Back, Biceps, Triceps, Shoulders, and Legs', () {
    final groups = ExerciseSeedData.muscleGroups;
    expect(groups, containsAll(['Chest', 'Back', 'Biceps', 'Triceps', 'Shoulders', 'Legs']));
  });
}
