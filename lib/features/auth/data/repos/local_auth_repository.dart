// Local auth repository backed by SharedPreferences.
//
// Stores a tiny "user table" as JSON so the app runs fully offline.
// Swap this for a Supabase/Firebase implementation later without
// touching the UI — the [AuthRepository] interface stays the same.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const _usersKey = 'fitx_users';
  static const _sessionKey = 'fitx_session_user_id';

  final SharedPreferences _prefs;

  LocalAuthRepository(this._prefs);

  Map<String, Map<String, dynamic>> _readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<void> _writeUsers(Map<String, Map<String, dynamic>> users) =>
      _prefs.setString(_usersKey, jsonEncode(users));

  @override
  Future<UserEntity?> getCurrentUser() async {
    final id = _prefs.getString(_sessionKey);
    if (id == null) return null;
    final user = _readUsers()[id];
    if (user == null) return null;
    return UserEntity.fromMap(user);
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _readUsers();
    final match = users.values.where(
      (u) => (u['email'] as String).toLowerCase() == normalizedEmail,
    );

    if (match.isEmpty) {
      throw const AuthException(
        'No account found with this email. Create one first.',
      );
    }

    final user = match.first;
    if (user['password'] != password) {
      throw const AuthException('Incorrect password. Try again.');
    }

    await _prefs.setString(_sessionKey, user['id'] as String);
    return UserEntity.fromMap(user);
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _readUsers();

    final alreadyExists = users.values.any(
      (u) => (u['email'] as String).toLowerCase() == normalizedEmail,
    );
    if (alreadyExists) {
      throw const AuthException(
        'An account with this email already exists. Sign in instead.',
      );
    }

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final userMap = <String, dynamic>{
      'id': id,
      'email': email.trim(),
      'name': name.trim(),
      'password': password,
      'preferences': <String, dynamic>{},
      'created_at': DateTime.now().toIso8601String(),
    };

    users[id] = userMap;
    await _writeUsers(users);
    await _prefs.setString(_sessionKey, id);
    return UserEntity.fromMap(userMap);
  }

  @override
  Future<void> signOut() => _prefs.remove(_sessionKey);

  @override
  Future<UserEntity> updateProfile({
    required String name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? avatarEmoji,
  }) async {
    final id = _prefs.getString(_sessionKey);
    if (id == null) {
      throw const AuthException('No active user session to update.');
    }

    final users = _readUsers();
    final userMap = users[id];
    if (userMap == null) {
      throw const AuthException('User not found in local storage.');
    }

    userMap['name'] = name.trim();
    userMap['age'] = age;
    userMap['gender'] = gender;
    userMap['height'] = height;
    userMap['weight'] = weight;
    userMap['avatar_emoji'] = avatarEmoji;

    users[id] = userMap;
    await _writeUsers(users);
    return UserEntity.fromMap(userMap);
  }
}
