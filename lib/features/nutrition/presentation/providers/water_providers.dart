import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/repos/local_water_repository.dart';
import '../../domain/entities/water_log_entity.dart';
import '../../domain/repos/water_repository.dart';
import 'nutrition_providers.dart';

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalWaterRepository(prefs);
});

class DailyWaterNotifier extends AsyncNotifier<WaterLogEntity> {
  @override
  Future<WaterLogEntity> build() async {
    final date = ref.watch(selectedDateProvider);
    final repo = ref.watch(waterRepositoryProvider);
    return repo.getLogForDate(date);
  }

  Future<void> addWater(int amountMl) async {
    final date = ref.read(selectedDateProvider);
    final repo = ref.read(waterRepositoryProvider);
    await repo.addWater(date, amountMl);
    ref.invalidateSelf();
  }

  Future<void> setTarget(int targetMl) async {
    final repo = ref.read(waterRepositoryProvider);
    await repo.setTarget(targetMl);
    ref.invalidateSelf();
  }
}

final dailyWaterProvider =
    AsyncNotifierProvider<DailyWaterNotifier, WaterLogEntity>(
  DailyWaterNotifier.new,
);

final waterHistoryProvider = FutureProvider<List<WaterLogEntity>>((ref) async {
  final repo = ref.watch(waterRepositoryProvider);
  ref.watch(dailyWaterProvider); // reload when daily water changes
  return repo.getHistory(days: 7);
});
