import '../entities/water_log_entity.dart';

abstract class WaterRepository {
  Future<WaterLogEntity> getLogForDate(DateTime date);
  Future<void> addWater(DateTime date, int deltaMl);
  Future<void> setTarget(int targetMl);
  Future<int> getTarget();
  Future<List<WaterLogEntity>> getHistory({int days = 7});
}
