import 'dart:convert';

class AppSession {
  const AppSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.username,
    required this.role,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String name;
  final String username;
  final String role;
  final DateTime expiresAt;

  String get token => accessToken;

  factory AppSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final accessToken = json['access'] as String? ?? '';

    return AppSession(
      accessToken: accessToken,
      refreshToken: json['refresh'] as String? ?? '',
      userId: user['id']?.toString() ?? '',
      name: user['fullName'] as String? ??
          user['name'] as String? ??
          user['username'] as String? ??
          'Admin',
      username: user['username'] as String? ?? '',
      role: user['role'] as String? ?? 'admin',
      expiresAt: _decodeExpiry(accessToken),
    );
  }
}

DateTime _decodeExpiry(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) {
      return DateTime.now().add(const Duration(hours: 8));
    }

    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(normalized)),
    ) as Map<String, dynamic>;

    final exp = payload['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true)
          .toLocal();
    }
  } catch (_) {
    // Ignore malformed tokens and fall back to a sensible client session.
  }

  return DateTime.now().add(const Duration(hours: 8));
}
