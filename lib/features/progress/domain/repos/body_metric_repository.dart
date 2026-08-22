import '../entities/body_metric_entity.dart';

abstract class BodyMetricRepository {
  Future<List<BodyMetricEntity>> getAll();
  Future<List<BodyMetricEntity>> getByDateRange(
      DateTime start, DateTime end);
  Future<BodyMetricEntity> save(BodyMetricEntity metric);
  Future<void> delete(String id);
  Future<BodyMetricEntity?> getLatest();
}
