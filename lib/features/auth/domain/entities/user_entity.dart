/// User Entity for FitX
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.preferences = const {},
    required this.createdAt,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      profileImageUrl: map['profile_image_url'] as String?,
      preferences: map['preferences'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && id == other.id;
  }

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ name.hashCode;
}