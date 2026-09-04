/// User Entity for FitX
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final int? age;
  final String? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final String? avatarEmoji; // e.g. '🦁', '⚡', '🏋️'
  final Map<String, dynamic> preferences;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.avatarEmoji,
    this.preferences = const {},
    required this.createdAt,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      profileImageUrl: map['profile_image_url'] as String?,
      age: (map['age'] as num?)?.toInt(),
      gender: map['gender'] as String?,
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      avatarEmoji: map['avatar_emoji'] as String?,
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
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'avatar_emoji': avatarEmoji,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? avatarEmoji,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        id == other.id &&
        email == other.email &&
        name == other.name &&
        age == other.age &&
        gender == other.gender &&
        height == other.height &&
        weight == other.weight &&
        avatarEmoji == other.avatarEmoji;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      (age?.hashCode ?? 0) ^
      (gender?.hashCode ?? 0) ^
      (height?.hashCode ?? 0) ^
      (weight?.hashCode ?? 0) ^
      (avatarEmoji?.hashCode ?? 0);
}