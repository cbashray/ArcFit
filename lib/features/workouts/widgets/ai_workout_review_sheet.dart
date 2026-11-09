import 'package:flutter/material.dart' hide ActionChip, Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../../../../features/shared/presentation/widgets/ui_components_export.dart';
import '../domain/entities/workout_entity.dart'
    show WorkoutEntity;
import '../domain/entities/personal_record_entity.dart'
    show PersonalRecordEntity;

/// AI Workout Review Modal
Future<void> showAiWorkoutReviewModal(
  BuildContext context,
  WorkoutEntity workout, {
  List<PersonalRecordEntity> newPRs = const [],
  required VoidCallback onDismissed,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AiWorkoutReviewSheet(
      workout: workout,
      newPRs: newPRs,
      onDismissed: onDismissed,
    ),
  );
}

class _AiWorkoutReviewSheet extends ConsumerWidget {
  final WorkoutEntity workout;
  final List<PersonalRecordEntity> newPRs;
  final VoidCallback onDismissed;

  const _AiWorkoutReviewSheet({
    required this.workout,
    required this.newPRs,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Calculate metrics
    final totalSets = workout.exercises.fold(0, (sum, e) => sum + e.sets);
    final totalReps = workout.exercises.fold(0, (sum, e) => sum + (e.sets * e.reps));
    final totalVolume = workout.exercises.fold<double>(
      0,
      (sum, e) => sum + ((e.weight ?? 0) * e.sets * e.reps),
    );
    final duration = workout.durationMinutes;

    // Muscle balance
    final muscleVolume = <String, double>{};
    for (final ex in workout.exercises) {
      muscleVolume[ex.muscleGroup] = (muscleVolume[ex.muscleGroup] ?? 0) + ((ex.weight ?? 0) * ex.sets * ex.reps);
    }
    final totalMuscleVolume = muscleVolume.values.fold(0.0, (a, b) => a + b);
    final balanceScore = _calculateBalanceScore(muscleVolume);

    // AI Score (0-10)
    final aiScore = _calculateAiScore(totalSets, totalVolume, duration, balanceScore);

    // Recovery estimate
    final recoveryHours = _estimateRecovery(totalVolume, duration);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppTheme.space3),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space6),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Icon(Icons.auto_awesome_rounded, size: 24, color: Colors.deepPurple),
                      ),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Workout Review',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              workout.title,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${aiScore.toStringAsFixed(1)}/10',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _getScoreColor(aiScore),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),

                  // Score Breakdown
                  Row(
                    children: [
                      Expanded(child: _ScoreBreakdownCard(
                        label: 'Volume',
                        score: _scoreVolume(totalVolume),
                        color: theme.colorScheme.primary,
                      )),
                      const SizedBox(width: AppTheme.space2),
                      Expanded(child: _ScoreBreakdownCard(
                        label: 'Balance',
                        score: balanceScore,
                        color: theme.colorScheme.secondary,
                      )),
                      const SizedBox(width: AppTheme.space2),
                      Expanded(child: _ScoreBreakdownCard(
                        label: 'Intensity',
                        score: _scoreIntensity(duration, totalVolume),
                        color: theme.colorScheme.tertiary,
                      )),
                      const SizedBox(width: AppTheme.space2),
                      Expanded(child: _ScoreBreakdownCard(
                        label: 'Consistency',
                        score: _scoreConsistency(workout.exercises.length),
                        color: Colors.deepPurple,
                      )),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),

                  // Key Metrics Row
                  Row(
                    children: [
                      Expanded(child: MetricPill(
                        icon: Icons.fitness_center_rounded,
                        label: 'Volume',
                        value: totalVolume >= 1000 ? '${(totalVolume / 1000).toStringAsFixed(1)}k kg' : '${totalVolume.round()} kg',
                        color: theme.colorScheme.primary,
                      )),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(child: MetricPill(
                        icon: Icons.repeat_rounded,
                        label: 'Sets',
                        value: '$totalSets',
                        color: theme.colorScheme.secondary,
                      )),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(child: MetricPill(
                        icon: Icons.repeat_on_rounded,
                        label: 'Reps',
                        value: '$totalReps',
                        color: theme.colorScheme.tertiary,
                      )),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(child: MetricPill(
                        icon: Icons.timer_outlined,
                        label: 'Time',
                        value: '$duration min',
                        color: Colors.deepPurple,
                      )),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),

                  // New PRs
                  if (newPRs.isNotEmpty) ...[
                    SectionHeader(title: '🎉 New Personal Records'),
                    const SizedBox(height: AppTheme.space3),
                    ...newPRs.map((pr) => _PrCard(pr: pr)),
                    const SizedBox(height: AppTheme.space4),
                  ],

                  // Muscle Balance
                  SectionHeader(
                    title: 'Muscle Balance',
                    subtitle: 'Volume distribution across muscle groups',
                  ),
                  const SizedBox(height: AppTheme.space3),
                  DataCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Balance Score',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${balanceScore.round()}%',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: _getBalanceColor(balanceScore),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.space4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Recovery Estimate',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.schedule_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${recoveryHours}h',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space4),
                        // Muscle volume bars
                        ...(muscleVolume.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value)))
                            .map((entry) => _MuscleVolumeBar(
                                  muscle: entry.key,
                                  volume: entry.value,
                                  percentage: totalMuscleVolume > 0 ? (entry.value / totalMuscleVolume) : 0,
                                  color: _getMuscleColor(entry.key),
                                )),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),

                  // Volume Overload Check
                  SectionHeader(
                    title: 'Volume Overload Check',
                    subtitle: 'Week-over-week comparison',
                  ),
                  const SizedBox(height: AppTheme.space3),
                  _VolumeOverloadCard(),
                  const SizedBox(height: AppTheme.space4),

                  // AI Insights
                  SectionHeader(
                    title: 'AI Insights',
                    subtitle: 'Personalized recommendations',
                  ),
                  const SizedBox(height: AppTheme.space3),
                  _AiInsightsCard(),
                  const SizedBox(height: AppTheme.space4),

                  // Dismiss Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDismissed();
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  double _calculateAiScore(int sets, double volume, num duration, int balance) {
    var score = 5.0;
    score += (sets / 20).clamp(0, 1.5);
    score += (volume / 10000).clamp(0, 1.5);
    score += (duration / 90).clamp(0, 1);
    score += (balance / 100).clamp(0, 1);
    return score.clamp(0.0, 10.0);
  }

  int _scoreVolume(double volume) => (volume / 15000 * 100).clamp(0, 100).round();
  int _scoreIntensity(num duration, double volume) {
    if (duration == 0) return 0;
    final volPerMin = volume / duration;
    return (volPerMin / 200 * 100).clamp(0, 100).round();
  }
  int _scoreConsistency(int exerciseCount) => (exerciseCount / 8 * 100).clamp(0, 100).round();

  int _calculateBalanceScore(Map<String, double> muscleVolume) {
    if (muscleVolume.isEmpty) return 100;
    final values = muscleVolume.values.toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    if (max == 0) return 100;
    return ((1 - (max - min) / max) * 100).round();
  }

  int _estimateRecovery(double volume, num duration) {
    var hours = 24;
    hours += (volume / 1000).round() * 2;
    hours += (duration / 30).round() * 4;
    return hours.clamp(12, 72);
  }

  Color _getScoreColor(num score) {
    if (score >= 8) return const Color(0xFF007A33);
    if (score >= 6) return const Color(0xFFB8860B);
    return const Color(0xFFC62828);
  }

  Color _getBalanceColor(int balance) {
    if (balance >= 70) return const Color(0xFF007A33);
    if (balance >= 40) return const Color(0xFFB8860B);
    return const Color(0xFFC62828);
  }

  Color _getMuscleColor(String muscle) {
    final normalized = muscle.trim().toLowerCase();
    final colors = <String, Color>{
      'chest': Colors.redAccent,
      'back': Colors.blueAccent,
      'lats': Colors.blueAccent,
      'legs': Colors.amberAccent,
      'quads': Colors.amberAccent,
      'hamstrings': Colors.orangeAccent,
      'calves': Colors.yellowAccent,
      'shoulders': Colors.deepOrangeAccent,
      'arms': Colors.purpleAccent,
      'biceps': Colors.purpleAccent,
      'triceps': Colors.cyanAccent,
      'core': Colors.tealAccent,
      'glutes': Colors.pinkAccent,
      'cardio': Colors.greenAccent,
    };
    return colors[normalized] ?? Colors.grey;
  }
}

class _ScoreBreakdownCard extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreBreakdownCard({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrCard extends StatelessWidget {
  final PersonalRecordEntity pr;

  const _PrCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DataCard(
      margin: const EdgeInsets.only(bottom: AppTheme.space2),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New ${pr.recordType} PR!',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${pr.exerciseName}: ${pr.value.toStringAsFixed(1)} ${pr.unit}',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              '+${pr.improvementPct.toStringAsFixed(1)}%',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleVolumeBar extends StatelessWidget {
  final String muscle;
  final double volume;
  final double percentage;
  final Color color;

  const _MuscleVolumeBar({
    required this.muscle,
    required this.volume,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppTheme.space2),
                  Text(
                    muscle,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${volume >= 1000 ? (volume / 1000).toStringAsFixed(1) : volume.round()} kg (${(percentage * 100).toInt()}%)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeOverloadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Mock data - in real app would come from provider
    final thisWeek = 12500.0;
    final lastWeek = 11200.0;
    final change = ((thisWeek - lastWeek) / lastWeek * 100);

    return DataCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _WeekVolumeCard(
                  label: 'This Week',
                  volume: thisWeek,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: _WeekVolumeCard(
                  label: 'Last Week',
                  volume: lastWeek,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          Row(
            children: [
              Icon(
                change >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 20,
                color: change >= 0 ? const Color(0xFF007A33) : const Color(0xFFC62828),
              ),
              const SizedBox(width: AppTheme.space2),
              Text(
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs last week',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: change >= 0 ? const Color(0xFF007A33) : const Color(0xFFC62828),
                ),
              ),
              const Spacer(),
              if (change > 20)
                Badge(
                  label: '⚠️ High Overload',
                  color: const Color(0xFFC62828),
                  backgroundColor: const Color(0xFFFDEDEC),
                )
              else if (change > 10)
                Badge(
                  label: 'Moderate Increase',
                  color: const Color(0xFFB8860B),
                  backgroundColor: const Color(0xFFFFF8E1),
                )
              else
                Badge(
                  label: 'Safe Progression',
                  color: const Color(0xFF007A33),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekVolumeCard extends StatelessWidget {
  final String label;
  final double volume;
  final Color color;

  const _WeekVolumeCard({
    required this.label,
    required this.volume,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(volume / 1000).toStringAsFixed(1)}k kg',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = [
      ('Your push volume is 23% higher than pull. Add more rows/pull-ups.', Icons.warning_amber_rounded, Colors.amber),
      ('Chest volume increased 15% this week. Consider deload next week.', Icons.trending_up_rounded, Colors.blue),
      ('Leg volume is only 18% of total. Add squats/deadlifts.', Icons.fitness_center_rounded, Colors.red),
      ('Great consistency! 5 workouts this week.', Icons.check_circle_rounded, Colors.green),
    ];

    return DataCard(
      child: Column(
        children: insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.space3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: insight.$3.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(insight.$2, size: 16, color: insight.$3),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Text(
                  insight.$1,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}