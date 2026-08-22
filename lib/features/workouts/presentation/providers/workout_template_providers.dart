import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/repos/local_workout_template_repository.dart';
import '../../domain/entities/workout_template_entity.dart';
import '../../domain/repos/workout_template_repository.dart';

final workoutTemplateRepositoryProvider =
    Provider<WorkoutTemplateRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalWorkoutTemplateRepository(prefs);
});

class WorkoutTemplatesNotifier
    extends AsyncNotifier<List<WorkoutTemplateEntity>> {
  @override
  Future<List<WorkoutTemplateEntity>> build() async {
    final repo = ref.watch(workoutTemplateRepositoryProvider);
    return repo.getTemplates();
  }

  Future<void> saveTemplate(WorkoutTemplateEntity template) async {
    final repo = ref.read(workoutTemplateRepositoryProvider);
    await repo.saveTemplate(template);
    ref.invalidateSelf();
  }

  Future<void> deleteTemplate(String id) async {
    final repo = ref.read(workoutTemplateRepositoryProvider);
    await repo.deleteTemplate(id);
    ref.invalidateSelf();
  }
}

final workoutTemplatesProvider = AsyncNotifierProvider<
    WorkoutTemplatesNotifier, List<WorkoutTemplateEntity>>(
  WorkoutTemplatesNotifier.new,
);
