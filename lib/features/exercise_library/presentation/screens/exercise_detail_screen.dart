import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/exercise_entity.dart';
import 'exercise_browse_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseEntity exercise;

  const ExerciseDetailScreen({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    final color = muscleGroupColor(exercise.muscleGroup);

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with muscle group badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(muscleGroupIcon(exercise.muscleGroup),
                            color: color, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              children: [
                                _Badge(
                                  label: exercise.muscleGroup,
                                  color: color,
                                ),
                                _Badge(
                                  label: exercise.equipment,
                                  color: Colors.grey,
                                ),
                                _Badge(
                                  label: exercise.difficultyLevel,
                                  color: AppTheme.secondaryBlue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Default parameters
            const _SectionTitle('Default Parameters'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ParamTile(
                    icon: Icons.repeat_rounded,
                    label: 'Sets',
                    value: '${exercise.defaultSets}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ParamTile(
                    icon: Icons.numbers_rounded,
                    label: 'Reps',
                    value: '${exercise.defaultReps}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ParamTile(
                    icon: Icons.fitness_center_rounded,
                    label: 'Weight',
                    value: exercise.defaultWeight > 0
                        ? '${exercise.defaultWeight.toStringAsFixed(0)} kg'
                        : 'BW',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            const _SectionTitle('Description'),
            const SizedBox(height: 8),
            Text(
              exercise.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),

            // Target muscles
            if (exercise.targetMuscles.isNotEmpty) ...[
              const _SectionTitle('Target Muscles'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: exercise.targetMuscles
                    .map((muscle) => Chip(
                          label: Text(
                            muscle,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide(color: Colors.grey.shade300),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Form cue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left:
                      const BorderSide(color: AppTheme.primaryGreen, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Form Cue',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.formCue,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Alternatives
            if (exercise.alternativeExercises != null &&
                exercise.alternativeExercises!.isNotEmpty) ...[
              const _SectionTitle('Alternatives'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: exercise.alternativeExercises!
                    .map((alt) => Chip(
                          label: Text(
                            alt.replaceAll('ex_', '').replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color.withValues(alpha: 1),
        ),
      ),
    );
  }
}

class _ParamTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ParamTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
