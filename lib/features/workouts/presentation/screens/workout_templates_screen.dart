import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/workout_template_entity.dart';
import '../providers/workout_providers.dart';
import '../providers/workout_template_providers.dart';

class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() =>
      _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState
    extends ConsumerState<WorkoutTemplatesScreen> {
  TemplateCategory? _selectedCategory;

  void _startWorkoutFromTemplate(WorkoutTemplateEntity template) {
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

  void _showCreateTemplateDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TemplateCategory selectedCat = TemplateCategory.custom;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Create Workout Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'e.g. Arms & Abs Blast',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Quick 45 min pump',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Category:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: TemplateCategory.values.map((cat) {
                    final isSel = selectedCat == cat;
                    return ChoiceChip(
                      label: Text(cat.name.toUpperCase(),
                          style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setModalState(() => selectedCat = cat);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final template = WorkoutTemplateEntity(
                    id: const Uuid().v4(),
                    title: title,
                    description: descController.text.trim(),
                    category: selectedCat,
                    isCustom: true,
                    createdAt: DateTime.now(),
                    exercises: const [
                      TemplateExerciseEntity(
                        exerciseId: 'custom_ex_1',
                        exerciseName: 'Bench Press',
                        muscleGroup: 'Chest',
                        defaultSets: 3,
                        defaultReps: 10,
                      ),
                      TemplateExerciseEntity(
                        exerciseId: 'custom_ex_2',
                        exerciseName: 'Bicep Curl',
                        muscleGroup: 'Biceps',
                        defaultSets: 3,
                        defaultReps: 12,
                      ),
                    ],
                  );
                  ref
                      .read(workoutTemplatesProvider.notifier)
                      .saveTemplate(template);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Save Template'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(workoutTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Templates 📋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Template',
            onPressed: _showCreateTemplateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (val) =>
                      setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ...TemplateCategory.values.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name.toUpperCase()),
                      selected: isSel,
                      onSelected: (val) => setState(
                          () => _selectedCategory = val ? cat : null),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Templates list
          Expanded(
            child: templatesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (templates) {
                final filtered = _selectedCategory == null
                    ? templates
                    : templates
                        .where((t) => t.category == _selectedCategory)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center_rounded,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No templates found in this category'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _showCreateTemplateDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Template'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final template = filtered[index];
                    return _TemplateCard(
                      template: template,
                      onStart: () => _startWorkoutFromTemplate(template),
                      onDelete: template.isCustom
                          ? () => ref
                              .read(workoutTemplatesProvider.notifier)
                              .deleteTemplate(template.id)
                          : null,
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

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplateEntity template;
  final VoidCallback onStart;
  final VoidCallback? onDelete;

  const _TemplateCard({
    required this.template,
    required this.onStart,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              template.category.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          if (template.isCustom) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CUSTOM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        template.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.errorRed, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
            if (template.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                template.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),

            // Exercise Pills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: template.exercises.map((ex) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ex.exerciseName} (${ex.defaultSets}×${ex.defaultReps})',
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Bottom CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${template.exercises.length} exercises · ${template.totalSets} total sets',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start Workout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
