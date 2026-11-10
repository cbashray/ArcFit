import 'dart:async';
import 'package:flutter/material.dart' hide ActionChip, Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routers/app_router.dart' show AppRoutes;
import '../../../../core/theme/app_theme.dart' show AppTheme;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';
import '../../../exercise_library/data/seed/exercise_seed_data.dart'
    show ExerciseSeedData;
import '../../domain/entities/workout_template_entity.dart'
    show WorkoutTemplateEntity;
import '../../widgets/ai_workout_review_sheet.dart'
    show showAiWorkoutReviewModal;
import '../../widgets/rest_timer_widget.dart' show showRestTimer;
import '../providers/workout_providers.dart'
    show activeWorkoutProvider, ActiveWorkout, DraftExercise;
import '../providers/workout_template_providers.dart'
    show workoutTemplatesProvider;

class WorkoutLoggingScreen extends ConsumerStatefulWidget {
  const WorkoutLoggingScreen({super.key});

  @override
  ConsumerState<WorkoutLoggingScreen> createState() =>
      _WorkoutLoggingScreenState();
}

class _WorkoutLoggingScreenState extends ConsumerState<WorkoutLoggingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAutoStart());
  }

  void _checkAutoStart() {
    if (!mounted) return;
    final active = ref.read(activeWorkoutProvider);
    if (active != null) return;

    // Check query params to auto-populate if launched via template link
    Uri? uri;
    try {
      uri = GoRouterState.of(context).uri;
    } catch (_) {}
    final templateParam = uri?.queryParameters['template']?.toLowerCase();
    if (templateParam == null || templateParam.isEmpty) return;

    final templates = ref.read(workoutTemplatesProvider).valueOrNull ?? [];
    final match = templates.cast<WorkoutTemplateEntity?>().firstWhere(
          (t) =>
              t != null &&
              (t.name.toLowerCase().contains(templateParam) ||
                  t.title.toLowerCase().contains(templateParam)),
          orElse: () => null,
        );

    final notifier = ref.read(activeWorkoutProvider.notifier);
    if (match != null) {
      notifier.start(title: match.title);
      for (final ex in match.exercises) {
        final defWeight = ex.targetWeight ?? _defaultWeightFor(ex.exerciseName);
        notifier.addDraftExercise(
          DraftExercise(
            exerciseId: ex.exerciseId,
            name: ex.exerciseName,
            muscleGroup: ex.muscleGroup,
            sets: ex.defaultSets,
            reps: ex.defaultReps,
            weight: defWeight,
          ),
        );
      }
    } else {
      final title =
          '${templateParam[0].toUpperCase()}${templateParam.substring(1)} Workout';
      notifier.start(title: title);
      if (templateParam.contains('push')) {
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'bench',
            name: 'Barbell Bench Press',
            muscleGroup: 'Chest',
            sets: 4,
            reps: 8,
            weight: 60));
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'ohp',
            name: 'Overhead Press',
            muscleGroup: 'Shoulders',
            sets: 3,
            reps: 10,
            weight: 40));
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'tri',
            name: 'Tricep Pushdown',
            muscleGroup: 'Arms',
            sets: 3,
            reps: 12,
            weight: 25));
      } else if (templateParam.contains('pull')) {
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'row',
            name: 'Bent-Over Row',
            muscleGroup: 'Back',
            sets: 4,
            reps: 8,
            weight: 50));
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'lat',
            name: 'Lat Pulldown',
            muscleGroup: 'Back',
            sets: 3,
            reps: 10,
            weight: 45));
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'curl',
            name: 'Bicep Curl',
            muscleGroup: 'Arms',
            sets: 3,
            reps: 12,
            weight: 14));
      } else if (templateParam.contains('leg')) {
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'squat',
            name: 'Barbell Squat',
            muscleGroup: 'Legs',
            sets: 4,
            reps: 8,
            weight: 80));
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'rdl',
            name: 'Romanian Deadlift',
            muscleGroup: 'Hamstrings',
            sets: 3,
            reps: 10,
            weight: 70));
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'calf',
            name: 'Calf Raise',
            muscleGroup: 'Calves',
            sets: 4,
            reps: 15,
            weight: 40));
      } else {
        notifier.addDraftExercise(DraftExercise(
            exerciseId: 'ex_1',
            name: 'Bench Press',
            muscleGroup: 'Chest',
            sets: 3,
            reps: 10,
            weight: 50));
      }
    }
  }

  static double _defaultWeightFor(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('deadlift')) return 100.0;
    if (lower.contains('squat') && !lower.contains('split')) return 80.0;
    if (lower.contains('bench') || lower.contains('chest press')) return 60.0;
    if (lower.contains('leg press')) return 120.0;
    if (lower.contains('row')) return 50.0;
    if (lower.contains('pulldown') || lower.contains('pull down')) return 50.0;
    if (lower.contains('overhead') || lower.contains('shoulder press')) return 40.0;
    if (lower.contains('curl') || lower.contains('lateral')) return 12.0;
    if (lower.contains('tricep') || lower.contains('pushdown')) return 25.0;
    if (lower.contains('push-up') || lower.contains('pull-up') || lower.contains('chin-up') || lower.contains('dip')) return 0.0;
    return 20.0;
  }

  Future<void> _completeWorkout() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = GoRouter.of(context);
    final result = await ref.read(activeWorkoutProvider.notifier).finish();
    if (!mounted) return;

    if (result.workout != null) {
      await showAiWorkoutReviewModal(
        context,
        result.workout!,
        onDismissed: () => nav.go(AppRoutes.workoutTemplates),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.newPRs.isNotEmpty
                ? 'Workout completed! New PRs: ${result.newPRs.join(", ")} 🎉'
                : 'Workout completed and saved! 💪',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      nav.go(AppRoutes.workoutTemplates);
    }
  }

  void _confirmDiscard() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Discard Workout?',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: const Text('All unlogged exercises and sets will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Logging')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).discard();
              Navigator.pop(ctx);
              context.go(AppRoutes.workoutTemplates);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog() {
    final nameCtrl = TextEditingController();
    String selectedMuscle = 'Chest';
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController(text: '20');

    final exerciseNames = ExerciseSeedData.exercises.map((e) => e.name).toList();
    const muscleGroups = [
      'Chest',
      'Back',
      'Biceps',
      'Triceps',
      'Shoulders',
      'Legs',
      'Core',
      'Full Body',
    ];

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add Exercise',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: nameCtrl.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return exerciseNames.take(8);
                    }
                    return exerciseNames.where((option) => option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    nameCtrl.text = selection;
                    final match = ExerciseSeedData.exercises.firstWhere(
                      (e) => e.name.toLowerCase() == selection.toLowerCase(),
                      orElse: () => ExerciseSeedData.exercises.first,
                    );
                    final group = match.muscleGroup;
                    final mapped = muscleGroups.firstWhere(
                      (m) => m.toLowerCase() == group.toLowerCase(),
                      orElse: () => 'Chest',
                    );
                    setDialogState(() {
                      selectedMuscle = mapped;
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    nameCtrl.text = controller.text;
                    controller.addListener(() {
                      nameCtrl.text = controller.text;
                    });
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Exercise Name',
                        hintText: 'e.g. Bench Press or select from library',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMuscle,
                  decoration: const InputDecoration(
                    labelText: 'Muscle Group',
                  ),
                  items: muscleGroups
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedMuscle = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Sets'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: repsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reps'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final sets = int.tryParse(setsCtrl.text) ?? 3;
                final reps = int.tryParse(repsCtrl.text) ?? 10;
                final weight = double.tryParse(weightCtrl.text) ?? 20.0;
                ref.read(activeWorkoutProvider.notifier).addDraftExercise(
                      DraftExercise(
                        exerciseId: 'ex_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        muscleGroup: selectedMuscle,
                        sets: sets > 0 ? sets : 1,
                        reps: reps > 0 ? reps : 1,
                        weight: weight >= 0 ? weight : 0,
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = ref.watch(activeWorkoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          if (activeWorkout != null) ...[
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error),
              onPressed: _confirmDiscard,
              tooltip: 'Discard Workout',
            ),
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _completeWorkout,
              tooltip: 'Complete Workout',
            ),
          ],
        ],
      ),
      body: activeWorkout == null
          ? EmptyState(
              icon: Icons.fitness_center_rounded,
              title: 'No Active Workout',
              message:
                  'Start a workout from the Workouts tab to begin logging.',
              actionLabel: 'Browse Workouts',
              onAction: () => context.go(AppRoutes.workoutTemplates),
            )
          : _buildWorkoutContent(activeWorkout),
    );
  }

  Widget _buildWorkoutContent(ActiveWorkout workout) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.space4),
      children: [
        DataCard(
          padding: const EdgeInsets.all(AppTheme.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.title.isNotEmpty
                          ? workout.title
                          : 'Custom Workout',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showAddExerciseDialog,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Exercise'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space2),
              Row(
                children: [
                  Icon(Icons.fitness_center_outlined,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.exercises.length} exercises',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space4),
                  Icon(Icons.timer_outlined,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  _ElapsedTimer(startedAt: workout.startedAt),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        for (var i = 0; i < workout.exercises.length; i++)
          _ExerciseCard(
            index: i,
            exercise: workout.exercises[i],
          ),
        const SizedBox(height: AppTheme.space4),
        FilledButton.icon(
          onPressed: _completeWorkout,
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Complete Workout'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        OutlinedButton.icon(
          onPressed: _showAddExerciseDialog,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Another Exercise'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
          ),
        ),
        const SizedBox(height: AppTheme.space6),
      ],
    );
  }
}

class _ElapsedTimer extends StatefulWidget {
  final DateTime startedAt;

  const _ElapsedTimer({required this.startedAt});

  @override
  State<_ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<_ElapsedTimer> {
  late final StreamSubscription<int> _subscription;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startedAt);
    _subscription = Stream.periodic(const Duration(seconds: 1), (i) => i).listen((_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.startedAt);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsed.inMinutes;
    final seconds = _elapsed.inSeconds % 60;
    final formatted =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return Text(
      formatted,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ExerciseCard extends ConsumerWidget {
  final int index;
  final DraftExercise exercise;

  const _ExerciseCard({
    required this.index,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DataCard(
      margin: const EdgeInsets.only(bottom: AppTheme.space3),
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name.isNotEmpty
                          ? exercise.name
                          : 'Unknown Exercise',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (exercise.muscleGroup.isNotEmpty)
                      Text(
                        exercise.muscleGroup,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Badge(
                label: '${exercise.sets} sets',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppTheme.space2),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 20, color: theme.colorScheme.error),
                tooltip: 'Remove Exercise',
                onPressed: () => ref
                    .read(activeWorkoutProvider.notifier)
                    .removeExercise(index),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          for (var s = 0; s < exercise.sets; s++)
            _SetRow(
              key: ValueKey('${exercise.exerciseId}_set_$s'),
              setNumber: s + 1,
              reps: exercise.reps,
              weight: exercise.weight,
              onUpdate: (reps, weight) {
                final updated =
                    exercise.copyWith(reps: reps, weight: weight);
                ref
                    .read(activeWorkoutProvider.notifier)
                    .updateExercise(index, updated);
              },
              onDelete: () {
                if (exercise.sets > 1) {
                  final updated =
                      exercise.copyWith(sets: exercise.sets - 1);
                  ref
                      .read(activeWorkoutProvider.notifier)
                      .updateExercise(index, updated);
                } else {
                  ref
                      .read(activeWorkoutProvider.notifier)
                      .removeExercise(index);
                }
              },
            ),
          const SizedBox(height: AppTheme.space2),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final updated =
                      exercise.copyWith(sets: exercise.sets + 1);
                  ref
                      .read(activeWorkoutProvider.notifier)
                      .updateExercise(index, updated);
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Set'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              OutlinedButton.icon(
                onPressed: () => showRestTimer(context),
                icon: const Icon(Icons.timer_rounded, size: 18),
                label: const Text('Rest Timer'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setNumber;
  final int reps;
  final double weight;
  final Function(int reps, double weight) onUpdate;
  final VoidCallback onDelete;

  const _SetRow({
    super.key,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$setNumber',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            child: TextFormField(
              initialValue: reps > 0 ? reps.toString() : '',
              decoration: InputDecoration(
                labelText: 'Reps',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final newReps = int.tryParse(value) ?? reps;
                onUpdate(newReps, weight);
              },
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            child: TextFormField(
              initialValue: weight > 0
                  ? (weight % 1 == 0
                      ? weight.toInt().toString()
                      : weight.toString())
                  : '',
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final newWeight = double.tryParse(value) ?? weight;
                onUpdate(reps, newWeight);
              },
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: theme.colorScheme.error, size: 20),
            tooltip: 'Delete set',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
