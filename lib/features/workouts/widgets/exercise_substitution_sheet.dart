import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';

/// Exercise Substitution Modal
Future<void> showExerciseSubstitutionModal({
  required BuildContext context,
  required String exerciseName,
  required String muscleGroup,
  required int exerciseIndex,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ExerciseSubstitutionSheet(
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      exerciseIndex: exerciseIndex,
    ),
  );
}

class _ExerciseSubstitutionSheet extends ConsumerWidget {
  final String exerciseName;
  final String muscleGroup;
  final int exerciseIndex;

  const _ExerciseSubstitutionSheet({
    required this.exerciseName,
    required this.muscleGroup,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock substitution data - in real app would come from AI/provider
    final substitutions = _getSubstitutions(exerciseName, muscleGroup);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
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

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space2),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.deepPurple),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exercise Substitution',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          exerciseName,
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
                    '${substitutions.length} alternatives',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Equipment filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Equipment',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space2),
                  _EquipmentFilterChips(),
                  const SizedBox(height: AppTheme.space3),
                ],
              ),
            ),

            // Substitution list
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
                children: [
                  ...substitutions.map((sub) => _SubstitutionCard(
                    substitution: sub,
                    onTap: () {
                      Navigator.pop(context);
                      // In real app: ref.read(activeWorkoutProvider.notifier).substituteExercise(exerciseIndex, sub);
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentFilterChips extends ConsumerStatefulWidget {
  @override
  ConsumerState<_EquipmentFilterChips> createState() => _EquipmentFilterChipsState();
}

class _EquipmentFilterChipsState extends ConsumerState<_EquipmentFilterChips> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Dumbbells',
    'Barbell',
    'Cable',
    'Machine',
    'Bodyweight',
    'Kettlebells',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) => Padding(
          padding: const EdgeInsets.only(right: AppTheme.space2),
          child: DataChip(
            label: filter,
            selected: _selectedFilter == filter,
            color: theme.colorScheme.primary,
            onTap: () => setState(() => _selectedFilter = filter),
          ),
        )).toList(),
      ),
    );
  }
}

class _SubstitutionCard extends StatelessWidget {
  final _Substitution substitution;
  final VoidCallback onTap;

  const _SubstitutionCard({
    required this.substitution,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchPercent = substitution.matchPercent;

    return DataCard(
      margin: const EdgeInsets.only(bottom: AppTheme.space3),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              _getEquipmentIcon(substitution.equipment),
              size: 26,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      substitution.name,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space2),
                    _MatchBadge(percent: matchPercent),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        substitution.equipment,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        substitution.difficulty,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _getDifficultyColor(substitution.difficulty),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space2),
                    if (substitution.isCompound)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          'Compound',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (substitution.notes != null)
                  Text(
                    substitution.notes!,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'dumbbells': return Icons.fitness_center_outlined;
      case 'barbell': return Icons.view_module_outlined;
      case 'cable': return Icons.cable_outlined;
      case 'machine': return Icons.precision_manufacturing_outlined;
      case 'bodyweight': return Icons.accessibility_outlined;
      case 'kettlebells': return Icons.circle_outlined;
      case 'bands': return Icons.linear_scale_outlined;
      default: return Icons.fitness_center_outlined;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner': return const Color(0xFF007A33);
      case 'intermediate': return const Color(0xFFB8860B);
      case 'advanced': return const Color(0xFFC62828);
      default: return Colors.grey;
    }
  }
}

class _MatchBadge extends StatelessWidget {
  final int percent;

  const _MatchBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (percent >= 90) {
      color = const Color(0xFF007A33);
    } else if (percent >= 75) {
      color = const Color(0xFFB8860B);
    } else {
      color = const Color(0xFFC62828);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        '$percent% match',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// MOCK SUBSTITUTION DATA
// ═══════════════════════════════════════════════════════════════════════════════════════

class _Substitution {
  final String name;
  final String equipment;
  final String difficulty;
  final bool isCompound;
  final int matchPercent;
  final String? notes;

  _Substitution({
    required this.name,
    required this.equipment,
    required this.difficulty,
    required this.isCompound,
    required this.matchPercent,
    this.notes,
  });
}

List<_Substitution> _getSubstitutions(String exerciseName, String muscleGroup) {
  final lower = exerciseName.toLowerCase();

  if (lower.contains('bench press') || lower.contains('chest press')) {
    return [
      _Substitution(name: 'Incline Dumbbell Press', equipment: 'Dumbbells', difficulty: 'Intermediate', isCompound: true, matchPercent: 95, notes: 'Targets upper chest more'),
      _Substitution(name: 'Push-Ups', equipment: 'Bodyweight', difficulty: 'Beginner', isCompound: true, matchPercent: 88, notes: 'Great for home workouts'),
      _Substitution(name: 'Cable Chest Fly', equipment: 'Cable', difficulty: 'Beginner', isCompound: false, matchPercent: 82, notes: 'Constant tension throughout'),
      _Substitution(name: 'Machine Chest Press', equipment: 'Machine', difficulty: 'Beginner', isCompound: true, matchPercent: 90, notes: 'Fixed path, safer for heavy loads'),
      _Substitution(name: 'Dumbbell Floor Press', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 85, notes: 'Reduces shoulder strain'),
      _Substitution(name: 'Landmine Press', equipment: 'Barbell', difficulty: 'Intermediate', isCompound: true, matchPercent: 78, notes: 'Unilateral, core engagement'),
      _Substitution(name: 'Band Chest Press', equipment: 'Bands', difficulty: 'Beginner', isCompound: true, matchPercent: 72, notes: 'Accommodating resistance'),
    ];
  }

  if (lower.contains('squat') && !lower.contains('deadlift')) {
    return [
      _Substitution(name: 'Goblet Squat', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 93, notes: 'Easier on lower back'),
      _Substitution(name: 'Front Squat', equipment: 'Barbell', difficulty: 'Advanced', isCompound: true, matchPercent: 95, notes: 'More quad emphasis'),
      _Substitution(name: 'Leg Press', equipment: 'Machine', difficulty: 'Beginner', isCompound: true, matchPercent: 88, notes: 'Removes spinal loading'),
      _Substitution(name: 'Bulgarian Split Squat', equipment: 'Dumbbells', difficulty: 'Intermediate', isCompound: true, matchPercent: 90, notes: 'Unilateral, fixes imbalances'),
      _Substitution(name: 'Hack Squat', equipment: 'Machine', difficulty: 'Beginner', isCompound: true, matchPercent: 87, notes: 'Fixed path, heavy loads'),
      _Substitution(name: 'Box Squat', equipment: 'Barbell', difficulty: 'Intermediate', isCompound: true, matchPercent: 85, notes: 'Teaches hip hinge pattern'),
      _Substitution(name: 'Goblet Box Squat', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 82, notes: 'Depth control, mobility'),
    ];
  }

  if (lower.contains('deadlift')) {
    return [
      _Substitution(name: 'Romanian Deadlift', equipment: 'Barbell', difficulty: 'Intermediate', isCompound: true, matchPercent: 95, notes: 'More hamstring focus'),
      _Substitution(name: 'Trap Bar Deadlift', equipment: 'Barbell', difficulty: 'Beginner', isCompound: true, matchPercent: 90, notes: 'Neutral grip, less back stress'),
      _Substitution(name: 'Dumbbell RDL', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 88, notes: 'Greater range of motion'),
      _Substitution(name: 'Single-Leg RDL', equipment: 'Dumbbells', difficulty: 'Advanced', isCompound: false, matchPercent: 82, notes: 'Unilateral, balance'),
      _Substitution(name: 'Cable Pull-Through', equipment: 'Cable', difficulty: 'Beginner', isCompound: false, matchPercent: 78, notes: 'Constant tension on glutes'),
      _Substitution(name: 'Kettlebell Swing', equipment: 'Kettlebells', difficulty: 'Intermediate', isCompound: true, matchPercent: 85, notes: 'Explosive hip hinge'),
    ];
  }

  if (lower.contains('pull-up') || lower.contains('chin-up')) {
    return [
      _Substitution(name: 'Lat Pulldown', equipment: 'Cable', difficulty: 'Beginner', isCompound: true, matchPercent: 92, notes: 'Adjustable weight'),
      _Substitution(name: 'Assisted Pull-Up', equipment: 'Machine', difficulty: 'Beginner', isCompound: true, matchPercent: 90, notes: 'Builds toward bodyweight'),
      _Substitution(name: 'Inverted Row', equipment: 'Bodyweight', difficulty: 'Beginner', isCompound: true, matchPercent: 85, notes: 'Horizontal pulling pattern'),
      _Substitution(name: 'Band-Assisted Pull-Up', equipment: 'Bands', difficulty: 'Beginner', isCompound: true, matchPercent: 88, notes: 'Variable assistance'),
      _Substitution(name: 'Negative Pull-Up', equipment: 'Bodyweight', difficulty: 'Intermediate', isCompound: true, matchPercent: 80, notes: 'Eccentric strength'),
      _Substitution(name: 'Single-Arm Cable Pulldown', equipment: 'Cable', difficulty: 'Intermediate', isCompound: false, matchPercent: 78, notes: 'Unilateral lat focus'),
    ];
  }

  if (lower.contains('row')) {
    return [
      _Substitution(name: 'Seated Cable Row', equipment: 'Cable', difficulty: 'Beginner', isCompound: true, matchPercent: 95, notes: 'Constant tension'),
      _Substitution(name: 'Chest-Supported Row', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 90, notes: 'Removes lower back'),
      _Substitution(name: 'T-Bar Row', equipment: 'Barbell', difficulty: 'Intermediate', isCompound: true, matchPercent: 88, notes: 'Heavy loading possible'),
      _Substitution(name: 'Single-Arm Dumbbell Row', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 87, notes: 'Unilateral, fixes imbalances'),
      _Substitution(name: 'Machine Row', equipment: 'Machine', difficulty: 'Beginner', isCompound: true, matchPercent: 85, notes: 'Fixed path, stable'),
      _Substitution(name: 'Face Pull', equipment: 'Cable', difficulty: 'Beginner', isCompound: false, matchPercent: 75, notes: 'Rear delt + rotator cuff'),
    ];
  }

  if (lower.contains('overhead press') || lower.contains('shoulder press')) {
    return [
      _Substitution(name: 'Dumbbell Shoulder Press', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 95, notes: 'Greater ROM, fixes imbalances'),
      _Substitution(name: 'Seated Dumbbell Press', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 90, notes: 'Removes leg drive'),
      _Substitution(name: 'Machine Shoulder Press', equipment: 'Machine', difficulty: 'Beginner', isCompound: true, matchPercent: 85, notes: 'Fixed path, stable'),
      _Substitution(name: 'Landmine Press', equipment: 'Barbell', difficulty: 'Intermediate', isCompound: true, matchPercent: 82, notes: 'Unilateral, core engagement'),
      _Substitution(name: 'Pike Push-Up', equipment: 'Bodyweight', difficulty: 'Intermediate', isCompound: true, matchPercent: 78, notes: 'No equipment needed'),
      _Substitution(name: 'Cable Overhead Press', equipment: 'Cable', difficulty: 'Intermediate', isCompound: true, matchPercent: 75, notes: 'Constant tension'),
    ];
  }

  // Default generic substitutions
  return [
    _Substitution(name: 'Dumbbell Alternative', equipment: 'Dumbbells', difficulty: 'Beginner', isCompound: true, matchPercent: 85),
    _Substitution(name: 'Cable Alternative', equipment: 'Cable', difficulty: 'Beginner', isCompound: false, matchPercent: 80),
    _Substitution(name: 'Machine Alternative', equipment: 'Machine', difficulty: 'Beginner', isCompound: true, matchPercent: 82),
    _Substitution(name: 'Bodyweight Alternative', equipment: 'Bodyweight', difficulty: 'Beginner', isCompound: true, matchPercent: 75),
    _Substitution(name: 'Band Alternative', equipment: 'Bands', difficulty: 'Beginner', isCompound: false, matchPercent: 70),
  ];
}