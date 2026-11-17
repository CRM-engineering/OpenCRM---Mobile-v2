class SessionManager {
  static String? sessionId;
  static String? userId;
  static String? username;
  static String? fullName;
  static bool isAdmin = false;

  static bool get isLoggedIn => sessionId != null;

  static void clear() {
    sessionId = null;
    userId = null;
    username = null;
    fullName = null;
    isAdmin = false;
  }
}
