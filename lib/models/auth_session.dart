class AppSession {
  const AppSession({
    required this.token,
    required this.userId,
    required this.name,
    required this.username,
    required this.role,
    required this.expiresAt,
  });

  final String token;
  final String userId;
  final String name;
  final String username;
  final String role;
  final DateTime expiresAt;

  factory AppSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return AppSession(
      token: json['token'] as String? ?? '',
      userId: user['id'] as String? ?? '',
      name: user['name'] as String? ?? 'Admin',
      username: user['username'] as String? ?? '',
      role: user['role'] as String? ?? 'admin',
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
