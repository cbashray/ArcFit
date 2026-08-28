import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/personal_record_entity.dart';
import '../../domain/repos/personal_record_repository.dart';
import 'local_personal_record_repository.dart';

/// Supabase implementation of [PersonalRecordRepository] with local fallback.
class SupabasePersonalRecordRepository implements PersonalRecordRepository {
  final sb.SupabaseClient _client;
  final LocalPersonalRecordRepository? _fallback;

  SupabasePersonalRecordRepository(this._client,
      {LocalPersonalRecordRepository? fallback})
      : _fallback = fallback;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<List<PersonalRecordEntity>> getAll() async {
    final uid = _userId;
    if (uid == null) {
      return await _fallback?.getAll() ?? [];
    }

    try {
      final response = await _client
          .from('personal_records')
          .select()
          .eq('user_id', uid)
          .order('achieved_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((row) => _mapToEntity(row as Map<String, dynamic>))
          .toList();

      if (list.isEmpty && _fallback != null) {
        return await _fallback.getAll();
      }
      return list;
    } catch (_) {
      return await _fallback?.getAll() ?? [];
    }
  }

  @override
  Future<PersonalRecordEntity?> getForExercise(String exerciseId) async {
    final uid = _userId;
    if (uid == null) {
      return await _fallback?.getForExercise(exerciseId);
    }

    try {
      final response = await _client
          .from('personal_records')
          .select()
          .eq('user_id', uid)
          .eq('exercise_id', exerciseId)
          .maybeSingle();

      if (response == null) {
        return await _fallback?.getForExercise(exerciseId);
      }
      return _mapToEntity(response);
    } catch (_) {
      return await _fallback?.getForExercise(exerciseId);
    }
  }

  @override
  Future<bool> upsert(PersonalRecordEntity pr) async {
    bool isNewLocal = false;
    if (_fallback != null) {
      isNewLocal = await _fallback.upsert(pr);
    }

    final uid = _userId;
    if (uid == null) return isNewLocal;

    try {
      final existing = await getForExercise(pr.exerciseId);
      if (existing != null &&
          existing.estimatedOneRepMax >= pr.estimatedOneRepMax) {
        return false; // Not a new PR
      }

      await _client.from('personal_records').upsert({
        'user_id': uid,
        'exercise_id': pr.exerciseId,
        'exercise_name': pr.exerciseName,
        'weight_kg': pr.maxWeight,
        'reps': pr.repsAtMaxWeight,
        'achieved_at': pr.achievedAt.toIso8601String(),
      });

      return true;
    } catch (_) {
      return isNewLocal;
    }
  }

  @override
  Future<void> delete(String exerciseId) async {
    await _fallback?.delete(exerciseId);
    final uid = _userId;
    if (uid != null) {
      try {
        await _client
            .from('personal_records')
            .delete()
            .eq('user_id', uid)
            .eq('exercise_id', exerciseId);
      } catch (_) {}
    }
  }

  @override
  Future<void> clear() async {
    await _fallback?.clear();
    final uid = _userId;
    if (uid != null) {
      try {
        await _client.from('personal_records').delete().eq('user_id', uid);
      } catch (_) {}
    }
  }

  PersonalRecordEntity _mapToEntity(Map<String, dynamic> row) {
    final weight = (row['weight_kg'] as num?)?.toDouble() ?? 0.0;
    final reps = (row['reps'] as num?)?.toInt() ?? 1;

    return PersonalRecordEntity(
      exerciseId: row['exercise_id'] as String,
      exerciseName: row['exercise_name'] as String,
      maxWeight: weight,
      repsAtMaxWeight: reps,
      estimatedOneRepMax: PersonalRecordEntity.calculateOneRepMax(weight, reps),
      achievedAt:
          DateTime.tryParse(row['achieved_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
