import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String tokenKey = 'auth_token';
  static const String rememberMeKey = 'remember_me';

  Future<void> saveSession({
    required String token,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setString(tokenKey, token);
      await prefs.setBool(rememberMeKey, true);
    } else {
      await clearSession();
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(rememberMeKey) ?? false;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(rememberMeKey);
  }
}
