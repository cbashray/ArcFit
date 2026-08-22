import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/personal_record_entity.dart';
import '../../domain/repos/personal_record_repository.dart';

/// SharedPreferences-backed personal record repository.
class LocalPersonalRecordRepository implements PersonalRecordRepository {
  static const _key = 'fitx_personal_records';

  final SharedPreferences _prefs;

  LocalPersonalRecordRepository(this._prefs);

  Map<String, PersonalRecordEntity> _readAll() {
    final raw = _prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (exerciseId, value) => MapEntry(
        exerciseId,
        PersonalRecordEntity.fromMap(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  Future<void> _writeAll(Map<String, PersonalRecordEntity> records) async {
    final encoded = jsonEncode(
      records.map((key, value) => MapEntry(key, value.toMap())),
    );
    await _prefs.setString(_key, encoded);
  }

  @override
  Future<List<PersonalRecordEntity>> getAll() async {
    return _readAll().values.toList()
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
  }

  @override
  Future<PersonalRecordEntity?> getForExercise(String exerciseId) async {
    return _readAll()[exerciseId];
  }

  @override
  Future<bool> upsert(PersonalRecordEntity pr) async {
    final all = _readAll();
    final existing = all[pr.exerciseId];

    // Only save if this is a genuinely better 1RM
    if (existing != null &&
        existing.estimatedOneRepMax >= pr.estimatedOneRepMax) {
      return false; // Not a new PR
    }

    all[pr.exerciseId] = pr;
    await _writeAll(all);
    return true; // New PR!
  }

  @override
  Future<void> delete(String exerciseId) async {
    final all = _readAll()..remove(exerciseId);
    await _writeAll(all);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
