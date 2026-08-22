import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/water_log_entity.dart';
import '../../domain/repos/water_repository.dart';

class LocalWaterRepository implements WaterRepository {
  final SharedPreferences _prefs;
  static const String _waterLogsKey = 'fitx_water_logs';
  static const String _waterTargetKey = 'fitx_water_target_ml';

  LocalWaterRepository(this._prefs);

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Future<int> getTarget() async {
    return _prefs.getInt(_waterTargetKey) ?? 2500;
  }

  @override
  Future<void> setTarget(int targetMl) async {
    await _prefs.setInt(_waterTargetKey, targetMl);
  }

  @override
  Future<WaterLogEntity> getLogForDate(DateTime date) async {
    final key = _dateKey(date);
    final target = await getTarget();
    final raw = _prefs.getString('${_waterLogsKey}_$key');

    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return WaterLogEntity.fromJson(json);
    }

    return WaterLogEntity(
      id: const Uuid().v4(),
      date: date,
      amountMl: 0,
      targetMl: target,
    );
  }

  @override
  Future<void> addWater(DateTime date, int deltaMl) async {
    final current = await getLogForDate(date);
    final newAmount = (current.amountMl + deltaMl).clamp(0, 10000);
    final updated = current.copyWith(amountMl: newAmount);
    final key = _dateKey(date);
    await _prefs.setString('${_waterLogsKey}_$key', jsonEncode(updated.toJson()));
  }

  @override
  Future<List<WaterLogEntity>> getHistory({int days = 7}) async {
    final list = <WaterLogEntity>[];
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final day = now.subtract(Duration(days: i));
      list.add(await getLogForDate(day));
    }
    return list;
  }
}
