class LoginResult {
  final bool success;
  final String? sessionId;
  final String? userId;
  final String? username;
  final String? fullName;
  final bool isAdmin;
  final String? error;

  const LoginResult({
    required this.success,
    this.sessionId,
    this.userId,
    this.username,
    this.fullName,
    this.isAdmin = false,
    this.error,
  });
}
