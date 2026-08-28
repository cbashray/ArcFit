import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/personal_record_entity.dart';
import '../../domain/repos/personal_record_repository.dart';

/// Supabase implementation of [PersonalRecordRepository]
class SupabasePersonalRecordRepository implements PersonalRecordRepository {
  final sb.SupabaseClient _client;

  SupabasePersonalRecordRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<List<PersonalRecordEntity>> getAll() async {
    final uid = _userId;
    if (uid == null) return [];

    final response = await _client
        .from('personal_records')
        .select()
        .eq('user_id', uid)
        .order('achieved_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => _mapToEntity(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PersonalRecordEntity?> getForExercise(String exerciseId) async {
    final uid = _userId;
    if (uid == null) return null;

    final response = await _client
        .from('personal_records')
        .select()
        .eq('user_id', uid)
        .eq('exercise_id', exerciseId)
        .maybeSingle();

    if (response == null) return null;
    return _mapToEntity(response);
  }

  @override
  Future<bool> upsert(PersonalRecordEntity pr) async {
    final uid = _userId;
    if (uid == null) return false;

    final existing = await getForExercise(pr.exerciseId);
    if (existing != null && existing.estimatedOneRepMax >= pr.estimatedOneRepMax) {
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
  }

  @override
  Future<void> delete(String exerciseId) async {
    final uid = _userId;
    if (uid == null) return;

    await _client
        .from('personal_records')
        .delete()
        .eq('user_id', uid)
        .eq('exercise_id', exerciseId);
  }

  @override
  Future<void> clear() async {
    final uid = _userId;
    if (uid == null) return;

    await _client.from('personal_records').delete().eq('user_id', uid);
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
      achievedAt: DateTime.tryParse(row['achieved_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
