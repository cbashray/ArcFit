import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../exercise_library/presentation/providers/exercise_providers.dart';
import '../providers/workout_providers.dart';

class WorkoutLoggingScreen extends ConsumerStatefulWidget {
  const WorkoutLoggingScreen({super.key});

  @override
  ConsumerState<WorkoutLoggingScreen> createState() =>
      _WorkoutLoggingScreenState();
}

class _WorkoutLoggingScreenState extends ConsumerState<WorkoutLoggingScreen> {
  final _titleController = TextEditingController();
  Timer? _ticker;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    // Auto-start a new workout if none is active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(activeWorkoutProvider) == null) {
        ref.read(activeWorkoutProvider.notifier).start();
      }
      _syncTicker();
    });
  }

  void _syncTicker() {
    final active = ref.read(activeWorkoutProvider);
    if (active == null) {
      _ticker?.cancel();
      _ticker = null;
      _startedAt = null;
      return;
    }
    if (_startedAt != active.startedAt) {
      _startedAt = active.startedAt;
      _titleController.text = active.title;
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {}); // refresh elapsed time
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  String _elapsedLabel() {
    final startedAt = _startedAt;
    if (startedAt == null) return '00:00';
    final elapsed = DateTime.now().difference(startedAt);
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    final s = elapsed.inSeconds % 60;
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _finishWorkout() async {
    final active = ref.read(activeWorkoutProvider);
    if (active == null) return;

    if (active.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one exercise before finishing.'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    final saved = await ref.read(activeWorkoutProvider.notifier).finish();
    if (!mounted) return;

    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout saved: ${saved.title}'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
    context.goNamed('home');
  }

  void _discardWorkout() {
    final active = ref.read(activeWorkoutProvider);
    final hasContent =
        active != null && (active.exercises.isNotEmpty || active.title.isNotEmpty);

    if (!hasContent) {
      ref.read(activeWorkoutProvider.notifier).discard();
      context.goNamed('home');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text('Your current workout will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep logging'),
          ),
          TextButton(
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).discard();
              Navigator.of(context).pop();
              context.goNamed('home');
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _openExercisePicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _ExercisePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncTicker();
    final active = ref.watch(activeWorkoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          if (active != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 18, color: AppTheme.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    _elapsedLabel(),
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: active == null
          ? const Center(child: Text('No active workout'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Workout title
                      TextField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Workout title',
                          hintText: 'e.g. Push Day, Leg Day...',
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                        onChanged: (value) => ref
                            .read(activeWorkoutProvider.notifier)
                            .setTitle(value),
                      ),
                      const SizedBox(height: 20),

                      // Exercise list header
                      Row(
                        children: [
                          const Text(
                            'Exercises',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${active.exercises.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (active.exercises.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.fitness_center,
                                  size: 40, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text(
                                'No exercises yet',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "Add Exercise" to get started',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(active.exercises.length, (index) {
                          final draft = active.exercises[index];
                          return _DraftExerciseCard(
                            index: index,
                            draft: draft,
                            onChanged: (updated) => ref
                                .read(activeWorkoutProvider.notifier)
                                .updateExercise(index, updated),
                            onRemoved: () => ref
                                .read(activeWorkoutProvider.notifier)
                                .removeExercise(index),
                          );
                        }),
                      const SizedBox(height: 12),

                      // Add exercise button
                      OutlinedButton.icon(
                        onPressed: _openExercisePicker,
                        icon: const Icon(Icons.add),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('Add Exercise'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: BorderSide(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _discardWorkout,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _finishWorkout,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Finish Workout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// One exercise in the active workout with editable sets/reps/weight.
class _DraftExerciseCard extends StatelessWidget {
  final int index;
  final DraftExercise draft;
  final ValueChanged<DraftExercise> onChanged;
  final VoidCallback onRemoved;

  const _DraftExerciseCard({
    required this.index,
    required this.draft,
    required this.onChanged,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      draft.muscleGroup,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: Colors.grey.shade500),
                tooltip: 'Remove exercise',
                onPressed: onRemoved,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StepperField(
                  label: 'Sets',
                  value: draft.sets,
                  min: 1,
                  max: 12,
                  onChanged: (value) =>
                      onChanged(_copyDraft(draft, sets: value)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StepperField(
                  label: 'Reps',
                  value: draft.reps,
                  min: 1,
                  max: 50,
                  onChanged: (value) =>
                      onChanged(_copyDraft(draft, reps: value)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StepperField(
                  label: 'kg',
                  value: draft.weight.round(),
                  min: 0,
                  max: 500,
                  step: 5,
                  onChanged: (value) =>
                      onChanged(_copyDraft(draft, weight: value.toDouble())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DraftExercise _copyDraft(
    DraftExercise draft, {
    int? sets,
    int? reps,
    double? weight,
  }) {
    return DraftExercise(
      exerciseId: draft.exerciseId,
      name: draft.name,
      muscleGroup: draft.muscleGroup,
      sets: sets ?? draft.sets,
      reps: reps ?? draft.reps,
      weight: weight ?? draft.weight,
    );
  }
}

/// Compact - / value / + field.
class _StepperField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepButton(
                icon: Icons.remove,
                enabled: value > min,
                onTap: () => onChanged((value - step).clamp(min, max)),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _StepButton(
                icon: Icons.add,
                enabled: value < max,
                onTap: () => onChanged((value + step).clamp(min, max)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppTheme.primaryGreen : Colors.grey.shade300,
        ),
      ),
    );
  }
}

/// Bottom sheet to pick exercises from the library.
class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet();

  @override
  ConsumerState<_ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Add Exercise',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (query) => setState(() => _query = query),
                ),
              ],
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Error: $error')),
              data: (exercises) {
                final filtered = _query.isEmpty
                    ? exercises
                    : exercises
                        .where((e) =>
                            e.name.toLowerCase().contains(_query) ||
                            e.muscleGroup
                                .toLowerCase()
                                .contains(_query.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No exercises found'));
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return ListTile(
                      leading: const Icon(Icons.fitness_center,
                          color: AppTheme.primaryGreen),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${exercise.muscleGroup} • ${exercise.equipment}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        ref
                            .read(activeWorkoutProvider.notifier)
                            .addExercise(exercise);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
