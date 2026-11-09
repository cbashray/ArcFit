import 'package:flutter/material.dart' hide ActionChip, Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';
import '../providers/workout_template_providers.dart'
    show workoutTemplatesProvider;
import '../providers/workout_providers.dart'
    show activeWorkoutProvider, DraftExercise;
import '../../domain/entities/workout_template_entity.dart'
    show WorkoutTemplateEntity;

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(workoutTemplatesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, size: 22, color: theme.colorScheme.onSurfaceVariant),
            tooltip: 'Create Template',
            onPressed: () => _showCreateTemplateSheet(context),
          ),
        ],
      ),
      body: templatesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.error)),
        ),
        data: (templates) {
          final builtIn = templates.where((t) => t.isBuiltIn).toList();
          final custom = templates.where((t) => !t.isBuiltIn).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space6),
            children: [
              // ── Built-in Templates ─────────────────────────────────────────
              SectionHeader(
                title: 'Templates',
                subtitle: 'Start a workout from a template',
              ),
              const SizedBox(height: AppTheme.space3),
              _TemplateList(templates: builtIn, isBuiltIn: true),
              const SizedBox(height: AppTheme.space6),

              // ── Custom Templates ───────────────────────────────────────────
              if (custom.isNotEmpty) ...[
                SectionHeader(
                  title: 'My Templates',
                  subtitle: 'Your custom templates',
                ),
                const SizedBox(height: AppTheme.space3),
                _TemplateList(templates: custom, isBuiltIn: false),
                const SizedBox(height: AppTheme.space6),
              ] else ...[
                DataCard(
                  child: Column(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: AppTheme.space3),
                      Text(
                        'No custom templates yet',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space2),
                      Text(
                        'Create your own workout template',
                        style: GoogleFonts.ibmPlexSans(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space4),
                      FilledButton.icon(
                        onPressed: () => _showCreateTemplateSheet(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Create Template'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space6),
              ],

              // ── AI Workout Generator ───────────────────────────────────────
              SectionHeader(
                title: 'AI Workout Generator',
                subtitle: 'Get a personalized workout in seconds',
              ),
              const SizedBox(height: AppTheme.space3),
              const _AiWorkoutGenerator(),
              const SizedBox(height: AppTheme.space6),
            ],
          );
        },
      ),
    );
  }

  void _showCreateTemplateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateTemplateSheet(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// TEMPLATE LIST
// ══════════════════════════════════════════════════════════════════════════════════════

class _TemplateList extends StatelessWidget {
  final List<WorkoutTemplateEntity> templates;
  final bool isBuiltIn;

  const _TemplateList({
    required this.templates,
    required this.isBuiltIn,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space2),
      itemBuilder: (context, index) {
        final template = templates[index];
        return _TemplateCard(template: template, isBuiltIn: isBuiltIn);
      },
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final WorkoutTemplateEntity template;
  final bool isBuiltIn;

  const _TemplateCard({required this.template, required this.isBuiltIn});

  void _startWorkout(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(activeWorkoutProvider.notifier);
    notifier.start(title: template.title);
    for (final ex in template.exercises) {
      notifier.addDraftExercise(
        DraftExercise(
          exerciseId: ex.exerciseId,
          name: ex.exerciseName,
          muscleGroup: ex.muscleGroup,
          sets: ex.defaultSets,
          reps: ex.defaultReps,
          weight: ex.targetWeight ?? 0.0,
        ),
      );
    }
    context.pushNamed('workoutLogging');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DataCard(
      onTap: () => _startWorkout(context, ref),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              _getTemplateIcon(template.name),
              size: 24,
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
                      template.name,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isBuiltIn) ...[
                      const SizedBox(width: AppTheme.space2),
                      Badge(
                        label: 'Built-in',
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.fitness_center_outlined, size: 13, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${template.exerciseCount} exercises',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    Icon(Icons.timer_outlined, size: 13, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      template.estimatedDuration > 0
                          ? '${template.estimatedDuration} min'
                          : '— min',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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

  IconData _getTemplateIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('push')) return Icons.push_pin_outlined;
    if (lower.contains('pull')) return Icons.arrow_back_ios_new_outlined;
    if (lower.contains('leg')) return Icons.directions_run_outlined;
    if (lower.contains('upper')) return Icons.fitness_center_outlined;
    if (lower.contains('full')) return Icons.view_module_outlined;
    return Icons.fitness_center_outlined;
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// AI WORKOUT GENERATOR
// ══════════════════════════════════════════════════════════════════════════════════════

class _AiWorkoutGenerator extends ConsumerStatefulWidget {
  const _AiWorkoutGenerator();

  @override
  ConsumerState<_AiWorkoutGenerator> createState() => _AiWorkoutGeneratorState();
}

class _AiWorkoutGeneratorState extends ConsumerState<_AiWorkoutGenerator> {
  final _equipmentController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  final _goalController = TextEditingController();
  bool _isGenerating = false;

  final List<String> _equipmentOptions = [
    'Full Gym',
    'Dumbbells Only',
    'Barbell + Plates',
    'Bodyweight',
    'Cable Machine',
    'Kettlebells',
    'Resistance Bands',
  ];

  final List<String> _goalOptions = [
    'Build Muscle (Hypertrophy)',
    'Strength (Powerlifting)',
    'Fat Loss / Cutting',
    'Athletic Performance',
    'General Fitness',
    'Rehab / Prehab',
  ];

  String? _selectedEquipment;
  String? _selectedGoal;

  @override
  void dispose() {
    _equipmentController.dispose();
    _durationController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_selectedEquipment == null || _selectedGoal == null) return;

    setState(() => _isGenerating = true);

    // Simulate AI generation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isGenerating = false);

    context.pushNamed('workoutLogging', queryParameters: {
      'template': 'ai-generated',
      'equipment': _selectedEquipment!,
      'duration': _durationController.text,
      'goal': _selectedGoal!,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DataCard(
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
                  color: Colors.deepPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.deepPurple),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Custom Workout',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tell ArcFit your setup and goals — get a tailored workout instantly',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),

          // Equipment Selector
          Text(
            'Available Equipment',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Wrap(
            spacing: AppTheme.space2,
            runSpacing: AppTheme.space2,
            children: _equipmentOptions.map((e) => ActionChip(
              label: e,
              selected: _selectedEquipment == e,
              color: theme.colorScheme.primary,
              onTap: () => setState(() => _selectedEquipment = e),
            )).toList(),
          ),
          const SizedBox(height: AppTheme.space4),

          // Duration + Goal Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration (minutes)',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space2),
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '60',
                        prefixIcon: Icon(Icons.timer_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Goal',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space2),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGoal,
                      hint: Text('Select goal', style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.onSurfaceVariant)),
                      isExpanded: true,
                      items: _goalOptions.map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g, style: GoogleFonts.ibmPlexSans(fontSize: 13)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedGoal = v),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space5),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generate,
              icon: _isGenerating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded, size: 20),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Workout'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════════════
// CREATE TEMPLATE SHEET
// ═════════════════════════════════════════════════════════════════════════════════════

class _CreateTemplateSheet extends ConsumerStatefulWidget {
  const _CreateTemplateSheet();

  @override
  ConsumerState<_CreateTemplateSheet> createState() => _CreateTemplateSheetState();
}

class _CreateTemplateSheetState extends ConsumerState<_CreateTemplateSheet> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final List<_DraftExercise> _exercises = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _exercises.isEmpty) return;

    setState(() => _isSaving = true);

    // Save template via provider
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  void _addExercise() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AddExerciseToTemplateSheet(
        onAdd: (exercise) => setState(() => _exercises.add(exercise)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space2),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: AppTheme.space3),
                  Row(
                    children: [
                      Text('Create Template', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      IconButton(icon: Icon(Icons.close_rounded, size: 22, color: theme.colorScheme.onSurfaceVariant), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: 'Template Name', hintText: 'e.g. Push Day A', prefixIcon: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  const SizedBox(height: AppTheme.space3),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Estimated Duration (min)', hintText: '60', prefixIcon: Icon(Icons.timer_outlined, color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
                children: [
                  Row(
                    children: [
                      Text('Exercises', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      TextButton.icon(onPressed: _addExercise, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Exercise')),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space3),
                  if (_exercises.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.space6),
                        child: Column(
                          children: [
                            Icon(Icons.fitness_center_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: AppTheme.space3),
                            Text('No exercises yet', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w500)),
                            const SizedBox(height: AppTheme.space2),
                            Text('Tap "Add Exercise" to get started', style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...List.generate(_exercises.length, (index) {
                      final ex = _exercises[index];
                      return _DraftTemplateExerciseTile(
                        index: index,
                        exercise: ex,
                        onRemove: () => setState(() => _exercises.removeAt(index)),
                      );
                    }),
                  const SizedBox(height: AppTheme.space4),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                      child: Text(_isSaving ? 'Saving...' : 'Save Template'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftExercise {
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;

  _DraftExercise({required this.name, required this.muscleGroup, required this.sets, required this.reps});
}

class _AddExerciseToTemplateSheet extends ConsumerStatefulWidget {
  final void Function(_DraftExercise) onAdd;

  const _AddExerciseToTemplateSheet({required this.onAdd});

  @override
  ConsumerState<_AddExerciseToTemplateSheet> createState() => _AddExerciseToTemplateSheetState();
}

class _AddExerciseToTemplateSheetState extends ConsumerState<_AddExerciseToTemplateSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space2),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: AppTheme.space3),
                  Row(
                    children: [
                      Text('Add Exercise', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      IconButton(icon: Icon(Icons.close_rounded, size: 22, color: theme.colorScheme.onSurfaceVariant), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space3),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(hintText: 'Search exercises...', prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant), isDense: true),
                    onChanged: (q) => setState(() => _query = q.toLowerCase()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
                children: [
                  // Mock exercise list - in real app would come from provider
                  ..._mockExercises
                      .where((e) => e.name.toLowerCase().contains(_query))
                      .map((e) => ListTile(
                        leading: Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(AppTheme.radiusSm)), child: Icon(Icons.fitness_center_rounded, size: 20, color: theme.colorScheme.primary)),
                        title: Text(e.name, style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text('${e.muscleGroup} • ${e.equipment}', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        onTap: () {
                          widget.onAdd(_DraftExercise(name: e.name, muscleGroup: e.muscleGroup, sets: 3, reps: 10));
                          Navigator.pop(context);
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

class _MockExercise {
  final String name;
  final String muscleGroup;
  final String equipment;

  _MockExercise({required this.name, required this.muscleGroup, required this.equipment});
}

final _mockExercises = [
  _MockExercise(name: 'Bench Press', muscleGroup: 'Chest', equipment: 'Barbell'),
  _MockExercise(name: 'Incline Dumbbell Press', muscleGroup: 'Chest', equipment: 'Dumbbells'),
  _MockExercise(name: 'Push-Ups', muscleGroup: 'Chest', equipment: 'Bodyweight'),
  _MockExercise(name: 'Pull-Ups', muscleGroup: 'Back', equipment: 'Bodyweight'),
  _MockExercise(name: 'Barbell Row', muscleGroup: 'Back', equipment: 'Barbell'),
  _MockExercise(name: 'Lat Pulldown', muscleGroup: 'Back', equipment: 'Cable'),
  _MockExercise(name: 'Squat', muscleGroup: 'Legs', equipment: 'Barbell'),
  _MockExercise(name: 'Romanian Deadlift', muscleGroup: 'Legs', equipment: 'Barbell'),
  _MockExercise(name: 'Leg Press', muscleGroup: 'Legs', equipment: 'Machine'),
  _MockExercise(name: 'Overhead Press', muscleGroup: 'Shoulders', equipment: 'Barbell'),
  _MockExercise(name: 'Lateral Raise', muscleGroup: 'Shoulders', equipment: 'Dumbbells'),
  _MockExercise(name: 'Bicep Curl', muscleGroup: 'Arms', equipment: 'Dumbbells'),
  _MockExercise(name: 'Tricep Pushdown', muscleGroup: 'Arms', equipment: 'Cable'),
];

class _DraftTemplateExerciseTile extends StatelessWidget {
  final int index;
  final _DraftExercise exercise;
  final VoidCallback onRemove;

  const _DraftTemplateExerciseTile({required this.index, required this.exercise, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space2),
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: Text('${index + 1}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${exercise.sets}×${exercise.reps} • ${exercise.muscleGroup}', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}