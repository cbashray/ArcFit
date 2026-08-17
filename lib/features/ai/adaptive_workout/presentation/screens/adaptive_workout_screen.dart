import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../workouts/presentation/providers/workout_providers.dart';
import '../../domain/entities/workout_plan_entity.dart';
import '../providers/adaptive_workout_providers.dart';

const _goals = ['Build Muscle', 'Lose Weight', 'Get Strong', 'Increase Endurance'];
const _focuses = ['Full Body', 'Upper Body', 'Lower Body', 'Push', 'Pull'];
const _equipmentOptions = [
  'bodyweight',
  'dumbbell',
  'barbell',
  'machine',
  'cable',
  'kettlebell',
];
const _restrictions = ['None', 'Injury / limited mobility', 'Limited time'];

class AdaptiveWorkoutScreen extends ConsumerStatefulWidget {
  const AdaptiveWorkoutScreen({super.key});

  @override
  ConsumerState<AdaptiveWorkoutScreen> createState() =>
      _AdaptiveWorkoutScreenState();
}

class _AdaptiveWorkoutScreenState extends ConsumerState<AdaptiveWorkoutScreen> {
  String _selectedGoal = _goals.first;
  String _selectedFocus = _focuses.first;
  final Set<String> _selectedEquipment = {'bodyweight', 'dumbbell'};
  String _selectedRestriction = _restrictions.first;
  double _duration = 45;

  Future<void> _generate() async {
    if (_selectedEquipment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one equipment type.'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    await ref.read(generatedPlanProvider.notifier).generate(
          goal: _selectedGoal,
          restrictions: _selectedRestriction,
          equipment: _selectedEquipment.toList(),
          muscleFocus: _selectedFocus,
          duration: _duration.round(),
        );
  }

  void _startPlanWorkout(WorkoutPlanEntity plan) {
    final notifier = ref.read(activeWorkoutProvider.notifier);
    notifier.start(title: plan.title);
    for (final exercise in plan.exercises) {
      notifier.addExerciseFromPlan(exercise);
    }
    context.goNamed('workoutLogging');
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(generatedPlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Workout Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Intro
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withValues(alpha: 0.12),
                  Colors.deepPurple.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.deepPurple, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tell FitX your goals and available equipment — '
                    'it builds a plan for you.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.deepPurple.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Goal
          const _SectionLabel('Your goal'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final goal in _goals)
                _ChoiceChip(
                  label: goal,
                  isSelected: _selectedGoal == goal,
                  onSelected: () => setState(() => _selectedGoal = goal),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Muscle focus
          const _SectionLabel('Muscle focus'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final focus in _focuses)
                _ChoiceChip(
                  label: focus,
                  isSelected: _selectedFocus == focus,
                  onSelected: () => setState(() => _selectedFocus = focus),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Equipment
          const _SectionLabel('Available equipment'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final equipment in _equipmentOptions)
                _ChoiceChip(
                  label: equipment,
                  isSelected: _selectedEquipment.contains(equipment),
                  onSelected: () {
                    setState(() {
                      if (_selectedEquipment.contains(equipment)) {
                        _selectedEquipment.remove(equipment);
                      } else {
                        _selectedEquipment.add(equipment);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Duration
          Row(
            children: [
              const _SectionLabel('Duration'),
              const Spacer(),
              Text(
                '${_duration.round()} min',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          Slider(
            value: _duration,
            min: 30,
            max: 90,
            divisions: 6,
            activeColor: AppTheme.primaryGreen,
            label: '${_duration.round()} min',
            onChanged: (value) => setState(() => _duration = value),
          ),
          const SizedBox(height: 8),

          // Restrictions
          const _SectionLabel('Restrictions'),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedRestriction,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.accessibility_new_rounded),
            ),
            items: [
              for (final restriction in _restrictions)
                DropdownMenuItem(value: restriction, child: Text(restriction)),
            ],
            onChanged: (value) =>
                setState(() => _selectedRestriction = value ?? _restrictions.first),
          ),
          const SizedBox(height: 24),

          // Generate button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: planAsync.isLoading ? null : _generate,
              icon: planAsync.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                planAsync.isLoading
                    ? 'Building your plan...'
                    : 'Generate My Workout',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Generated plan
          planAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Could not generate a plan: $error',
                style: const TextStyle(color: AppTheme.errorRed),
              ),
            ),
            data: (plan) => plan == null
                ? const SizedBox.shrink()
                : _GeneratedPlanCard(
                    plan: plan,
                    onStart: () => _startPlanWorkout(plan),
                    onRegenerate: _generate,
                  ),
          ),

          // History
          const _SectionLabel('Recent plans'),
          const SizedBox(height: 10),
          ref.watch(planHistoryProvider).when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text('Error: $error'),
                data: (plans) {
                  if (plans.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Plans you generate will appear here.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final plan in plans.take(5))
                        _PlanHistoryTile(
                          plan: plan,
                          onDelete: () => ref
                              .read(planHistoryProvider.notifier)
                              .delete(plan.id),
                        ),
                    ],
                  );
                },
              ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _GeneratedPlanCard extends StatelessWidget {
  final WorkoutPlanEntity plan;
  final VoidCallback onStart;
  final VoidCallback onRegenerate;

  const _GeneratedPlanCard({
    required this.plan,
    required this.onStart,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 20, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${plan.exercises.length} exercises • '
                      '~${plan.estimatedDuration} min',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Regenerate',
                onPressed: onRegenerate,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (final exercise in plan.exercises)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fitness_center,
                        size: 15, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${exercise.sets} sets × ${exercise.reps} reps'
                          '${exercise.restTime != null ? ' • ${exercise.restTime}s rest' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (exercise.weight > 0)
                    Text(
                      '${exercise.weight.toStringAsFixed(0)} kg',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start This Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanHistoryTile extends StatelessWidget {
  final WorkoutPlanEntity plan;
  final VoidCallback onDelete;

  const _PlanHistoryTile({required this.plan, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined,
              size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${DateFormat('MMM d').format(plan.generatedAt)} • '
                  '${plan.exercises.length} exercises • ${plan.goals ?? ''}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: Colors.grey.shade500),
            tooltip: 'Delete plan',
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
