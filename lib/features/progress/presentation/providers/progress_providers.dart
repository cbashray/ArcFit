import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/providers/app_providers.dart';
import '../../../progress/data/repos/local_body_metric_repository.dart';
import '../../../progress/domain/entities/body_metric_entity.dart';
import '../../../progress/domain/repos/body_metric_repository.dart';

final bodyMetricRepositoryProvider = Provider<BodyMetricRepository>((ref) {
  return LocalBodyMetricRepository(ref.watch(sharedPreferencesProvider));
});

final bodyMetricsProvider =
    AsyncNotifierProvider<BodyMetricsNotifier, List<BodyMetricEntity>>(
        BodyMetricsNotifier.new);

class BodyMetricsNotifier extends AsyncNotifier<List<BodyMetricEntity>> {
  @override
  Future<List<BodyMetricEntity>> build() {
    return ref.watch(bodyMetricRepositoryProvider).getAll();
  }

  Future<void> add(BodyMetricEntity metric) async {
    await ref.read(bodyMetricRepositoryProvider).save(metric);
    await _refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(bodyMetricRepositoryProvider).delete(id);
    await _refresh();
  }

  Future<void> _refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(bodyMetricRepositoryProvider).getAll());
  }
}
