import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/body_metric_entity.dart';
import '../../domain/repos/body_metric_repository.dart';

class LocalBodyMetricRepository implements BodyMetricRepository {
  static const _key = 'fitx_body_metrics';
  final SharedPreferences _prefs;

  LocalBodyMetricRepository(this._prefs);

  List<BodyMetricEntity> _readAll() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) =>
            BodyMetricEntity.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _writeAll(List<BodyMetricEntity> list) async {
    await _prefs.setString(
        _key, jsonEncode(list.map((m) => m.toMap()).toList()));
  }

  @override
  Future<List<BodyMetricEntity>> getAll() async => _readAll();

  @override
  Future<List<BodyMetricEntity>> getByDateRange(
      DateTime start, DateTime end) async {
    return _readAll()
        .where((m) => !m.date.isBefore(start) && !m.date.isAfter(end))
        .toList();
  }

  @override
  Future<BodyMetricEntity> save(BodyMetricEntity metric) async {
    final all = _readAll();
    final idx = all.indexWhere((m) => m.id == metric.id);
    if (idx >= 0) {
      all[idx] = metric;
    } else {
      final withId = BodyMetricEntity(
        id: metric.id.isEmpty
            ? const Uuid().v4()
            : metric.id,
        userId: metric.userId,
        date: metric.date,
        weightKg: metric.weightKg,
        bodyFatPct: metric.bodyFatPct,
        chestCm: metric.chestCm,
        waistCm: metric.waistCm,
        hipsCm: metric.hipsCm,
        armCm: metric.armCm,
        thighCm: metric.thighCm,
        notes: metric.notes,
      );
      all.add(withId);
    }
    await _writeAll(all);
    return metric;
  }

  @override
  Future<void> delete(String id) async {
    final all = _readAll()..removeWhere((m) => m.id == id);
    await _writeAll(all);
  }

  @override
  Future<BodyMetricEntity?> getLatest() async {
    final all = _readAll();
    return all.isEmpty ? null : all.first;
  }
}
