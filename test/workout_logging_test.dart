import 'package:arcfit/features/workouts/presentation/providers/workout_providers.dart';
import 'package:arcfit/features/workouts/presentation/screens/workout_logging_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ActiveWorkout and DraftExercise getters and copyWith work without error', () {
    final draft = DraftExercise(
      exerciseId: 'bench',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      sets: 3,
      reps: 10,
      weight: 60,
    );

    expect(draft.name, 'Bench Press');
    expect(draft.sets, 3);
    expect(draft.exercise, isNull); // Defensive dynamic getter

    final updatedDraft = draft.copyWith(sets: 4, weight: 65);
    expect(updatedDraft.sets, 4);
    expect(updatedDraft.weight, 65);

    final workout = ActiveWorkout(
      title: 'Chest Day',
      startedAt: DateTime.now(),
      exercises: [draft],
    );

    expect(workout.title, 'Chest Day');
    expect(workout.exercises.length, 1);
    expect(workout.template, isNull); // Defensive dynamic getter prevents NoSuchMethodError
  });

  testWidgets('WorkoutLoggingScreen renders EmptyState when no active workout', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorkoutLoggingScreen(),
        ),
      ),
    );

    expect(find.text('No Active Workout'), findsOneWidget);
    expect(find.text('Browse Workouts'), findsOneWidget);
  });

  testWidgets('WorkoutLoggingScreen renders active workout exercises and sets without NoSuchMethodError', (tester) async {
    final container = ProviderContainer();
    final notifier = container.read(activeWorkoutProvider.notifier);
    notifier.start(title: 'Upper Body Power');
    notifier.addDraftExercise(
      DraftExercise(
        exerciseId: 'bench_1',
        name: 'Incline Bench Press',
        muscleGroup: 'Chest',
        sets: 3,
        reps: 8,
        weight: 70,
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: WorkoutLoggingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Upper Body Power'), findsOneWidget);
    expect(find.text('Incline Bench Press'), findsOneWidget);
    expect(find.text('3 sets'), findsOneWidget);
    expect(find.text('Complete Workout'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}

