// Seed exercise data for FitX.
//
// This is the built-in exercise library used when running locally.
// When a backend is connected, this becomes the fallback/seed source.
import '../../domain/entities/exercise_entity.dart';

class ExerciseSeedData {
  static const List<ExerciseEntity> exercises = [
    // ---------------- Chest ----------------
    ExerciseEntity(
      id: 'ex_bench_press',
      name: 'Barbell Bench Press',
      nameLocalization: 'Barbell Bench Press',
      muscleGroup: 'chest',
      equipment: 'barbell',
      difficultyLevel: 'intermediate',
      description:
          'The classic horizontal press for building chest, shoulder and '
          'triceps strength. Lie on a flat bench, lower the bar to your '
          'mid-chest and press it back up.',
      formCue: 'Keep your shoulder blades pinched and feet planted. '
          'Lower the bar under control to your mid-chest.',
      defaultWeight: 40,
      defaultSets: 4,
      defaultReps: 8,
      videoUrl: '',
      targetMuscles: ['triceps', 'front delts'],
      alternativeExercises: ['ex_db_bench_press', 'ex_machine_chest_press'],
    ),
    ExerciseEntity(
      id: 'ex_db_bench_press',
      name: 'Dumbbell Bench Press',
      nameLocalization: 'Dumbbell Bench Press',
      muscleGroup: 'chest',
      equipment: 'dumbbell',
      difficultyLevel: 'beginner',
      description:
          'Press dumbbells from your chest while lying on a flat bench. '
          'Allows a deeper stretch and more natural range of motion than '
          'the barbell version.',
      formCue: 'Keep wrists stacked over elbows and press up and slightly in.',
      defaultWeight: 14,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['triceps', 'front delts'],
      alternativeExercises: ['ex_bench_press'],
    ),
    ExerciseEntity(
      id: 'ex_incline_db_press',
      name: 'Incline Dumbbell Press',
      nameLocalization: 'Incline Dumbbell Press',
      muscleGroup: 'chest',
      equipment: 'dumbbell',
      difficultyLevel: 'intermediate',
      description:
          'Press dumbbells on a bench set to 30-45 degrees to emphasize '
          'the upper chest.',
      formCue: 'Set the bench to 30-45 degrees. Lower until you feel a '
          'stretch in your upper chest.',
      defaultWeight: 12,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['upper chest', 'front delts'],
    ),
    ExerciseEntity(
      id: 'ex_push_up',
      name: 'Push-Up',
      nameLocalization: 'Push-Up',
      muscleGroup: 'chest',
      equipment: 'bodyweight',
      difficultyLevel: 'beginner',
      description:
          'The fundamental bodyweight pressing movement. Great anywhere, '
          'no equipment needed.',
      formCue: 'Keep your body in a straight line from head to heels. '
          'Lower your chest to just above the floor.',
      defaultWeight: 0,
      defaultSets: 3,
      defaultReps: 15,
      videoUrl: '',
      targetMuscles: ['triceps', 'core'],
    ),
    ExerciseEntity(
      id: 'ex_machine_chest_press',
      name: 'Machine Chest Press',
      nameLocalization: 'Machine Chest Press',
      muscleGroup: 'chest',
      equipment: 'machine',
      difficultyLevel: 'beginner',
      description:
          'A guided pressing movement on a chest press machine. Ideal for '
          'learning the pressing pattern safely.',
      formCue: 'Adjust the seat so the handles are at mid-chest height.',
      defaultWeight: 30,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['triceps', 'front delts'],
    ),
    ExerciseEntity(
      id: 'ex_cable_fly',
      name: 'Cable Chest Fly',
      nameLocalization: 'Cable Chest Fly',
      muscleGroup: 'chest',
      equipment: 'cable',
      difficultyLevel: 'intermediate',
      description:
          'An isolation movement that squeezes the chest through a full '
          'range of motion using cable resistance.',
      formCue: 'Keep a soft bend in your elbows and hug a big tree as you '
          'bring your hands together.',
      defaultWeight: 10,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['inner chest'],
    ),

    // ---------------- Back ----------------
    ExerciseEntity(
      id: 'ex_deadlift',
      name: 'Conventional Deadlift',
      nameLocalization: 'Conventional Deadlift',
      muscleGroup: 'back',
      equipment: 'barbell',
      difficultyLevel: 'advanced',
      description:
          'The king of posterior-chain lifts. Works the entire back, glutes '
          'and hamstrings while building total-body strength.',
      formCue: 'Keep the bar close to your shins and your back neutral. '
          'Push the floor away with your legs.',
      defaultWeight: 60,
      defaultSets: 4,
      defaultReps: 5,
      videoUrl: '',
      targetMuscles: ['glutes', 'hamstrings', 'traps'],
    ),
    ExerciseEntity(
      id: 'ex_pull_up',
      name: 'Pull-Up',
      nameLocalization: 'Pull-Up',
      muscleGroup: 'back',
      equipment: 'bodyweight',
      difficultyLevel: 'intermediate',
      description:
          'The classic vertical pull. Hang from a bar with an overhand grip '
          'and pull your chin above the bar.',
      formCue: 'Start from a dead hang and pull your chest toward the bar. '
          'Avoid swinging.',
      defaultWeight: 0,
      defaultSets: 3,
      defaultReps: 8,
      videoUrl: '',
      targetMuscles: ['biceps', 'lats'],
      alternativeExercises: ['ex_lat_pulldown'],
    ),
    ExerciseEntity(
      id: 'ex_lat_pulldown',
      name: 'Lat Pulldown',
      nameLocalization: 'Lat Pulldown',
      muscleGroup: 'back',
      equipment: 'cable',
      difficultyLevel: 'beginner',
      description:
          'A machine-based vertical pull that builds the lats and is easier '
          'to scale than pull-ups.',
      formCue: 'Pull the bar to your upper chest and squeeze your lats at '
          'the bottom.',
      defaultWeight: 35,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['biceps', 'lats'],
    ),
    ExerciseEntity(
      id: 'ex_barbell_row',
      name: 'Barbell Bent-Over Row',
      nameLocalization: 'Barbell Bent-Over Row',
      muscleGroup: 'back',
      equipment: 'barbell',
      difficultyLevel: 'intermediate',
      description:
          'A horizontal pull that thickens the mid-back. Hinge at the hips '
          'and row the bar to your lower ribs.',
      formCue: 'Keep your torso at about 45 degrees and pull the bar to '
          'your belly button.',
      defaultWeight: 40,
      defaultSets: 4,
      defaultReps: 8,
      videoUrl: '',
      targetMuscles: ['rhomboids', 'biceps'],
    ),
    ExerciseEntity(
      id: 'ex_db_row',
      name: 'One-Arm Dumbbell Row',
      nameLocalization: 'One-Arm Dumbbell Row',
      muscleGroup: 'back',
      equipment: 'dumbbell',
      difficultyLevel: 'beginner',
      description:
          'A unilateral row performed with one knee and hand on a bench. '
          'Great for fixing side-to-side imbalances.',
      formCue: 'Keep your back flat and pull the dumbbell toward your hip, '
          'not your shoulder.',
      defaultWeight: 14,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['lats', 'biceps'],
    ),
    ExerciseEntity(
      id: 'ex_seated_cable_row',
      name: 'Seated Cable Row',
      nameLocalization: 'Seated Cable Row',
      muscleGroup: 'back',
      equipment: 'cable',
      difficultyLevel: 'beginner',
      description:
          'A seated horizontal pull using a cable machine with a V-handle.',
      formCue: 'Sit tall, keep your chest up and pull the handle to your '
          'stomach.',
      defaultWeight: 35,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['rhomboids', 'biceps'],
    ),

    // ---------------- Legs ----------------
    ExerciseEntity(
      id: 'ex_back_squat',
      name: 'Barbell Back Squat',
      nameLocalization: 'Barbell Back Squat',
      muscleGroup: 'legs',
      equipment: 'barbell',
      difficultyLevel: 'intermediate',
      description:
          'The foundational lower-body lift. Bar on your upper back, squat '
          'down until your thighs are at least parallel, then drive back up.',
      formCue: 'Keep your chest up and knees tracking over your toes. '
          'Sit down between your hips, not over your knees.',
      defaultWeight: 50,
      defaultSets: 4,
      defaultReps: 8,
      videoUrl: '',
      targetMuscles: ['glutes', 'quads', 'core'],
      alternativeExercises: ['ex_goblet_squat', 'ex_leg_press'],
    ),
    ExerciseEntity(
      id: 'ex_goblet_squat',
      name: 'Goblet Squat',
      nameLocalization: 'Goblet Squat',
      muscleGroup: 'legs',
      equipment: 'dumbbell',
      difficultyLevel: 'beginner',
      description:
          'Hold a dumbbell at your chest and squat. An excellent way to '
          'learn squat mechanics with a counterbalance.',
      formCue: 'Hold the dumbbell close to your chest and keep your elbows '
          'inside your knees at the bottom.',
      defaultWeight: 16,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['glutes', 'quads'],
    ),
    ExerciseEntity(
      id: 'ex_leg_press',
      name: 'Leg Press',
      nameLocalization: 'Leg Press',
      muscleGroup: 'legs',
      equipment: 'machine',
      difficultyLevel: 'beginner',
      description:
          'A machine-based squat alternative that loads the legs without '
          'stressing the lower back.',
      formCue: 'Lower until your knees reach about 90 degrees. Do not let '
          'your lower back round off the pad.',
      defaultWeight: 80,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['glutes', 'quads'],
    ),
    ExerciseEntity(
      id: 'ex_romanian_deadlift',
      name: 'Romanian Deadlift',
      nameLocalization: 'Romanian Deadlift',
      muscleGroup: 'legs',
      equipment: 'barbell',
      difficultyLevel: 'intermediate',
      description:
          'A hip-hinge movement that targets the hamstrings and glutes. '
          'Lower the bar along your thighs with a slight knee bend.',
      formCue: 'Push your hips back and feel the stretch in your hamstrings. '
          'Keep the bar close to your legs.',
      defaultWeight: 40,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['hamstrings', 'glutes'],
    ),
    ExerciseEntity(
      id: 'ex_walking_lunge',
      name: 'Walking Lunge',
      nameLocalization: 'Walking Lunge',
      muscleGroup: 'legs',
      equipment: 'dumbbell',
      difficultyLevel: 'beginner',
      description:
          'Step forward into a lunge, drop your back knee toward the floor, '
          'then drive through the front leg into the next step.',
      formCue: 'Keep your torso upright and take long enough steps that '
          'your front knee stays over your ankle.',
      defaultWeight: 10,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['glutes', 'quads'],
    ),
    ExerciseEntity(
      id: 'ex_leg_curl',
      name: 'Lying Leg Curl',
      nameLocalization: 'Lying Leg Curl',
      muscleGroup: 'legs',
      equipment: 'machine',
      difficultyLevel: 'beginner',
      description:
          'Isolates the hamstrings by curling a padded lever toward your '
          'glutes while lying face down.',
      formCue: 'Keep your hips pressed into the pad throughout the curl.',
      defaultWeight: 25,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['hamstrings'],
    ),
    ExerciseEntity(
      id: 'ex_calf_raise',
      name: 'Standing Calf Raise',
      nameLocalization: 'Standing Calf Raise',
      muscleGroup: 'legs',
      equipment: 'machine',
      difficultyLevel: 'beginner',
      description:
          'Raises onto your toes against resistance to build the calves.',
      formCue: 'Pause at the top and stretch fully at the bottom. Move '
          'slowly — no bouncing.',
      defaultWeight: 40,
      defaultSets: 4,
      defaultReps: 15,
      videoUrl: '',
      targetMuscles: ['calves'],
    ),

    // ---------------- Shoulders ----------------
    ExerciseEntity(
      id: 'ex_overhead_press',
      name: 'Barbell Overhead Press',
      nameLocalization: 'Barbell Overhead Press',
      muscleGroup: 'shoulders',
      equipment: 'barbell',
      difficultyLevel: 'intermediate',
      description:
          'Press a barbell from your shoulders to overhead while standing. '
          'Builds strong shoulders and a stable core.',
      formCue: 'Squeeze your glutes and brace your core. Press the bar in a '
          'straight line and move your head through at the top.',
      defaultWeight: 30,
      defaultSets: 4,
      defaultReps: 8,
      videoUrl: '',
      targetMuscles: ['triceps', 'upper chest'],
      alternativeExercises: ['ex_db_shoulder_press'],
    ),
    ExerciseEntity(
      id: 'ex_db_shoulder_press',
      name: 'Dumbbell Shoulder Press',
      nameLocalization: 'Dumbbell Shoulder Press',
      muscleGroup: 'shoulders',
      equipment: 'dumbbell',
      difficultyLevel: 'beginner',
      description:
          'Press dumbbells overhead from shoulder height, seated or standing.',
      formCue: 'Start with palms facing forward and press up without '
          'arching your lower back.',
      defaultWeight: 10,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['triceps'],
    ),
    ExerciseEntity(
      id: 'ex_lateral_raise',
      name: 'Dumbbell Lateral Raise',
      nameLocalization: 'Dumbbell Lateral Raise',
      muscleGroup: 'shoulders',
      equipment: 'dumbbell',
      difficultyLevel: 'beginner',
      description:
          'Raises dumbbells out to the sides to isolate the side delts for '
          'wider-looking shoulders.',
      formCue: 'Lead with your elbows and stop at shoulder height. Use a '
          'weight you can control — no swinging.',
      defaultWeight: 6,
      defaultSets: 3,
      defaultReps: 15,
      videoUrl: '',
      targetMuscles: ['side delts'],
    ),
    ExerciseEntity(
      id: 'ex_face_pull',
      name: 'Cable Face Pull',
      nameLocalization: 'Cable Face Pull',
      muscleGroup: 'shoulders',
      equipment: 'cable',
      difficultyLevel: 'beginner',
      description:
          'Pull a rope attachment toward your face to strengthen the rear '
          'delts and improve shoulder health.',
      formCue: 'Pull the rope apart as it reaches your face and keep your '
          'elbows high.',
      defaultWeight: 15,
      defaultSets: 3,
      defaultReps: 15,
      videoUrl: '',
      targetMuscles: ['rear delts', 'traps'],
    ),

    // ---------------- Arms ----------------
    ExerciseEntity(
      id: 'ex_barbell_curl',
      name: 'Barbell Bicep Curl',
      nameLocalization: 'Barbell Bicep Curl',
      muscleGroup: 'arms',
      equipment: 'barbell',
      difficultyLevel: 'beginner',
      description:
          'The classic biceps builder. Curl a straight or EZ bar from your '
          'thighs to shoulder height.',
      formCue: 'Pin your elbows to your sides and curl without swinging '
          'your torso.',
      defaultWeight: 20,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['biceps'],
    ),
    ExerciseEntity(
      id: 'ex_hammer_curl',
      name: 'Dumbbell Hammer Curl',
      nameLocalization: 'Dumbbell Hammer Curl',
      muscleGroup: 'arms',
      equipment: 'dumbbell',
      difficultyLevel: 'beginner',
      description:
          'Curl dumbbells with a neutral (palms-in) grip to hit the '
          'biceps and forearms.',
      formCue: 'Keep palms facing each other the whole way through.',
      defaultWeight: 10,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['biceps', 'forearms'],
    ),
    ExerciseEntity(
      id: 'ex_tricep_pushdown',
      name: 'Cable Tricep Pushdown',
      nameLocalization: 'Cable Tricep Pushdown',
      muscleGroup: 'arms',
      equipment: 'cable',
      difficultyLevel: 'beginner',
      description:
          'Push a cable attachment down until your arms are fully extended '
          'to isolate the triceps.',
      formCue: 'Keep your elbows glued to your sides and lock out at the '
          'bottom.',
      defaultWeight: 20,
      defaultSets: 3,
      defaultReps: 12,
      videoUrl: '',
      targetMuscles: ['triceps'],
    ),
    ExerciseEntity(
      id: 'ex_skull_crusher',
      name: 'EZ-Bar Skull Crusher',
      nameLocalization: 'EZ-Bar Skull Crusher',
      muscleGroup: 'arms',
      equipment: 'barbell',
      difficultyLevel: 'intermediate',
      description:
          'A lying triceps extension. Lower the bar toward your forehead '
          'and extend back up.',
      formCue: 'Keep your elbows pointing at the ceiling and lower the bar '
          'to just above your hairline.',
      defaultWeight: 15,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['triceps'],
    ),

    // ---------------- Core ----------------
    ExerciseEntity(
      id: 'ex_plank',
      name: 'Plank',
      nameLocalization: 'Plank',
      muscleGroup: 'core',
      equipment: 'bodyweight',
      difficultyLevel: 'beginner',
      description:
          'Hold a straight-arm or forearm plank to build core stability.',
      formCue: 'Squeeze your glutes and brace your abs. Do not let your '
          'hips sag.',
      defaultWeight: 0,
      defaultSets: 3,
      defaultReps: 1,
      videoUrl: '',
      targetMuscles: ['abs', 'lower back'],
    ),
    ExerciseEntity(
      id: 'ex_hanging_leg_raise',
      name: 'Hanging Leg Raise',
      nameLocalization: 'Hanging Leg Raise',
      muscleGroup: 'core',
      equipment: 'bodyweight',
      difficultyLevel: 'intermediate',
      description:
          'Hang from a pull-up bar and raise your legs to parallel (or '
          'higher) to target the lower abs.',
      formCue: 'Curl your pelvis up at the top and lower slowly. Avoid '
          'swinging.',
      defaultWeight: 0,
      defaultSets: 3,
      defaultReps: 10,
      videoUrl: '',
      targetMuscles: ['abs', 'hip flexors'],
    ),
    ExerciseEntity(
      id: 'ex_cable_crunch',
      name: 'Cable Crunch',
      nameLocalization: 'Cable Crunch',
      muscleGroup: 'core',
      equipment: 'cable',
      difficultyLevel: 'beginner',
      description:
          'Kneel below a high cable and crunch your elbows toward your '
          'thighs against resistance.',
      formCue: 'Round your spine as you crunch — think of bringing your '
          'ribs to your hips.',
      defaultWeight: 25,
      defaultSets: 3,
      defaultReps: 15,
      videoUrl: '',
      targetMuscles: ['abs'],
    ),

    // ---------------- Cardio / Conditioning ----------------
    ExerciseEntity(
      id: 'ex_treadmill_run',
      name: 'Treadmill Run',
      nameLocalization: 'Treadmill Run',
      muscleGroup: 'cardio',
      equipment: 'machine',
      difficultyLevel: 'beginner',
      description:
          'Steady-state or interval running on the treadmill for '
          'conditioning and calorie burn.',
      formCue: 'Land mid-foot, keep a tall posture and relaxed shoulders.',
      defaultWeight: 0,
      defaultSets: 1,
      defaultReps: 1,
      videoUrl: '',
      targetMuscles: ['legs', 'cardio'],
    ),
    ExerciseEntity(
      id: 'ex_rowing_machine',
      name: 'Rowing Machine',
      nameLocalization: 'Rowing Machine',
      muscleGroup: 'cardio',
      equipment: 'machine',
      difficultyLevel: 'beginner',
      description:
          'Full-body conditioning on the erg. Legs, core, then arms on the '
          'drive; reverse on the return.',
      formCue: 'Sequence: legs → body → arms, then arms → body → legs on '
          'the way back.',
      defaultWeight: 0,
      defaultSets: 1,
      defaultReps: 1,
      videoUrl: '',
      targetMuscles: ['back', 'legs', 'cardio'],
    ),
    ExerciseEntity(
      id: 'ex_kettlebell_swing',
      name: 'Kettlebell Swing',
      nameLocalization: 'Kettlebell Swing',
      muscleGroup: 'cardio',
      equipment: 'kettlebell',
      difficultyLevel: 'intermediate',
      description:
          'A ballistic hip hinge that builds explosive power and '
          'conditioning.',
      formCue: 'Hike the bell back and snap your hips forward. The arms '
          'stay relaxed — power comes from the hips.',
      defaultWeight: 16,
      defaultSets: 4,
      defaultReps: 15,
      videoUrl: '',
      targetMuscles: ['glutes', 'hamstrings', 'core'],
    ),
  ];

  /// Distinct muscle groups present in the seed data.
  static List<String> get muscleGroups => exercises
      .map((e) => e.muscleGroup)
      .toSet()
      .toList()
    ..sort();

  /// Distinct equipment types present in the seed data.
  static List<String> get equipmentTypes => exercises
      .map((e) => e.equipment)
      .toSet()
      .toList()
    ..sort();
}
