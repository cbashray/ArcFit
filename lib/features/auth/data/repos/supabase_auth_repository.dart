import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repository.dart';

/// Supabase Auth implementation of [AuthRepository]
class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Future<UserEntity?> getCurrentUser() async {
    final sbUser = _client.auth.currentUser;
    if (sbUser == null) return null;

    final name = sbUser.userMetadata?['name'] as String? ?? 
                 sbUser.email?.split('@').first ?? 
                 'User';

    return UserEntity(
      id: sbUser.id,
      email: sbUser.email ?? '',
      name: name,
      preferences: const {},
      createdAt: DateTime.tryParse(sbUser.createdAt) ?? DateTime.now(),
    );
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = res.user;
      if (user == null) {
        throw const AuthException('Sign in failed: user not found.');
      }

      final name = user.userMetadata?['name'] as String? ?? 
                   user.email?.split('@').first ?? 
                   'User';

      return UserEntity(
        id: user.id,
        email: user.email ?? email,
        name: name,
        preferences: const {},
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      final user = res.user;
      if (user == null) {
        throw const AuthException('Sign up failed: unable to create account.');
      }

      return UserEntity(
        id: user.id,
        email: user.email ?? email,
        name: name.trim(),
        preferences: const {},
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }
}
