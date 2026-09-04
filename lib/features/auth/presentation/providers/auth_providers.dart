// Auth state + notifier providers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repository.dart';

class AuthState {
  final UserEntity? user;

  const AuthState(this.user);

  bool get isSignedIn => user != null;
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Loads the persisted session on startup and exposes sign in/up/out.
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return AuthState(await repo.getCurrentUser());
  }

  /// Returns an error message, or null on success.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = AsyncValue.data(AuthState(user));
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Returns an error message, or null on success.
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password, name: name);
      state = AsyncValue.data(AuthState(user));
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// One-tap demo account: creates it on first use, then signs in.
  Future<String?> demoSignIn() async {
    const email = 'demo@fitx.app';
    const password = 'demo1234';
    final repo = ref.read(authRepositoryProvider);

    try {
      final user = await repo.signIn(email: email, password: password);
      state = AsyncValue.data(AuthState(user));
      return null;
    } on AuthException {
      // Demo account doesn't exist yet — create it.
      try {
        final user = await repo.signUp(
          email: email,
          password: password,
          name: 'Demo Athlete',
        );
        state = AsyncValue.data(AuthState(user));
        return null;
      } on AuthException catch (e) {
        return e.message;
      }
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(AuthState(null));
  }

  /// Updates profile details and refreshes local auth state.
  /// Returns error string on failure, or null on success.
  Future<String?> updateProfile({
    required String name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? avatarEmoji,
  }) async {
    try {
      final updatedUser = await ref.read(authRepositoryProvider).updateProfile(
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            avatarEmoji: avatarEmoji,
          );
      state = AsyncValue.data(AuthState(updatedUser));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
