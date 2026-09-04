import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repository.dart';
import 'local_auth_repository.dart';

/// Supabase Auth implementation of [AuthRepository] with local fallback.
class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _client;
  final LocalAuthRepository? _fallback;

  SupabaseAuthRepository(this._client, {LocalAuthRepository? fallback})
      : _fallback = fallback;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final sbUser = _client.auth.currentUser;
    if (sbUser != null) {
      final meta = sbUser.userMetadata ?? {};
      final name = meta['name'] as String? ??
          sbUser.email?.split('@').first ??
          'User';

      return UserEntity(
        id: sbUser.id,
        email: sbUser.email ?? '',
        name: name,
        age: (meta['age'] as num?)?.toInt(),
        gender: meta['gender'] as String?,
        height: (meta['height'] as num?)?.toDouble(),
        weight: (meta['weight'] as num?)?.toDouble(),
        avatarEmoji: meta['avatar_emoji'] as String?,
        preferences: const {},
        createdAt: DateTime.tryParse(sbUser.createdAt) ?? DateTime.now(),
      );
    }

    if (_fallback != null) {
      return await _fallback.getCurrentUser();
    }
    return null;
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
        if (_fallback != null) {
          return await _fallback.signIn(email: email, password: password);
        }
        throw const AuthException('Sign in failed: user not found.');
      }

      final meta = user.userMetadata ?? {};
      final name = meta['name'] as String? ??
          user.email?.split('@').first ??
          'User';

      return UserEntity(
        id: user.id,
        email: user.email ?? email,
        name: name,
        age: (meta['age'] as num?)?.toInt(),
        gender: meta['gender'] as String?,
        height: (meta['height'] as num?)?.toDouble(),
        weight: (meta['weight'] as num?)?.toDouble(),
        avatarEmoji: meta['avatar_emoji'] as String?,
        preferences: const {},
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } on sb.AuthException catch (e) {
      if (_fallback != null) {
        try {
          return await _fallback.signIn(email: email, password: password);
        } catch (_) {}
      }
      throw AuthException(e.message);
    } catch (e) {
      if (_fallback != null) {
        try {
          return await _fallback.signIn(email: email, password: password);
        } catch (_) {}
      }
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
        if (_fallback != null) {
          return await _fallback.signUp(email: email, password: password, name: name);
        }
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
      if (_fallback != null) {
        try {
          return await _fallback.signUp(email: email, password: password, name: name);
        } catch (_) {}
      }
      throw AuthException(e.message);
    } catch (e) {
      if (_fallback != null) {
        try {
          return await _fallback.signUp(email: email, password: password, name: name);
        } catch (_) {}
      }
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _fallback?.signOut();
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? avatarEmoji,
  }) async {
    final Map<String, dynamic> data = {
      'name': name.trim(),
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'avatar_emoji': avatarEmoji,
    };

    try {
      final res = await _client.auth.updateUser(
        sb.UserAttributes(data: data),
      );
      final user = res.user;
      if (user != null) {
        final meta = user.userMetadata ?? {};
        final updatedUser = UserEntity(
          id: user.id,
          email: user.email ?? '',
          name: name.trim(),
          age: (meta['age'] as num?)?.toInt() ?? age,
          gender: (meta['gender'] as String?) ?? gender,
          height: (meta['height'] as num?)?.toDouble() ?? height,
          weight: (meta['weight'] as num?)?.toDouble() ?? weight,
          avatarEmoji: (meta['avatar_emoji'] as String?) ?? avatarEmoji,
          preferences: const {},
          createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        );

        if (_fallback != null) {
          try {
            await _fallback.updateProfile(
              name: name,
              age: age,
              gender: gender,
              height: height,
              weight: weight,
              avatarEmoji: avatarEmoji,
            );
          } catch (_) {}
        }

        return updatedUser;
      }
    } catch (_) {}

    if (_fallback != null) {
      return await _fallback.updateProfile(
        name: name,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        avatarEmoji: avatarEmoji,
      );
    }

    throw const AuthException('Failed to update profile.');
  }
}
