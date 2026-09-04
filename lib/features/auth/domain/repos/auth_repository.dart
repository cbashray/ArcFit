// Auth Repository Interface for FitX
import '../entities/user_entity.dart';

/// Thrown when sign in / sign up fails with a user-facing message.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  /// The currently signed-in user, or null.
  Future<UserEntity?> getCurrentUser();

  /// Sign in with email and password. Throws [AuthException] on failure.
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email, password and name. Throws [AuthException] on failure.
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Update the current user's profile information.
  Future<UserEntity> updateProfile({
    required String name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? avatarEmoji,
  });
}
