import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/exercise_entity.dart';
import '../providers/exercise_providers.dart';

class ExerciseBrowseScreen extends ConsumerStatefulWidget {
  const ExerciseBrowseScreen({super.key});

  @override
  ConsumerState<ExerciseBrowseScreen> createState() =>
      _ExerciseBrowseScreenState();
}

class _ExerciseBrowseScreenState extends ConsumerState<ExerciseBrowseScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedMuscleGroup = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(filteredExercisesProvider(
      ExerciseFilter(query: _query, muscleGroup: _selectedMuscleGroup),
    ));
    final muscleGroups = ref.watch(muscleGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (query) => setState(() => _query = query),
            ),
          ),

          // Muscle group filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedMuscleGroup == 'All',
                  onSelected: () =>
                      setState(() => _selectedMuscleGroup = 'All'),
                ),
                ...muscleGroups.map((group) => _FilterChip(
                      label: group,
                      isSelected: _selectedMuscleGroup == group,
                      onSelected: () =>
                          setState(() => _selectedMuscleGroup = group),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error loading exercises: $error',
                  style: const TextStyle(color: AppTheme.errorRed),
                ),
              ),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No exercises match your search',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) =>
                      _ExerciseCard(exercise: exercises[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: AppTheme.primaryGreen,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryGreen
              : Colors.grey.shade300,
        ),
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final color = muscleGroupColor(exercise.muscleGroup);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            muscleGroupIcon(exercise.muscleGroup),
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${exercise.muscleGroup} • ${exercise.equipment} • '
            '${exercise.difficultyLevel}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        trailing:
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        onTap: () => context.pushNamed('exerciseDetail', extra: exercise),
      ),
    );
  }
}

/// Shared muscle-group → color mapping.
Color muscleGroupColor(String muscleGroup) {
  switch (muscleGroup.toLowerCase()) {
    case 'chest':
      return const Color(0xFFE5484D);
    case 'back':
      return const Color(0xFF3E63DD);
    case 'legs':
      return const Color(0xFF30A46C);
    case 'shoulders':
      return const Color(0xFFF76B15);
    case 'arms':
      return const Color(0xFF8E4EC6);
    case 'core':
      return const Color(0xFFFFC53D);
    case 'cardio':
      return const Color(0xFF00A2C7);
    default:
      return Colors.grey;
  }
}

/// Shared muscle-group → icon mapping.
IconData muscleGroupIcon(String muscleGroup) {
  switch (muscleGroup.toLowerCase()) {
    case 'chest':
      return Icons.fitness_center;
    case 'back':
      return Icons.accessibility_new;
    case 'legs':
      return Icons.directions_walk;
    case 'shoulders':
      return Icons.sports_gymnastics;
    case 'arms':
      return Icons.sports_martial_arts;
    case 'core':
      return Icons.self_improvement;
    case 'cardio':
      return Icons.favorite;
    default:
      return Icons.fitness_center;
  }
}
