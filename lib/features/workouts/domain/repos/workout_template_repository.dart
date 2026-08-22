import '../entities/workout_template_entity.dart';

abstract class WorkoutTemplateRepository {
  Future<List<WorkoutTemplateEntity>> getTemplates();
  Future<WorkoutTemplateEntity?> getTemplateById(String id);
  Future<void> saveTemplate(WorkoutTemplateEntity template);
  Future<void> deleteTemplate(String id);
  Future<void> seedDefaultTemplatesIfEmpty();
}
