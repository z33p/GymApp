class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'username': username,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as String,
      displayName: map['display_name'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
