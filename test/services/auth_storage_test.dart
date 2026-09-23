import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_application/core/storage/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthStorage', () {
    late AuthStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = AuthStorage();
    });

    test('saves token when remember me is enabled', () async {
      await storage.saveSession(token: 'test-token', rememberMe: true);

      expect(await storage.getToken(), 'test-token');

      expect(await storage.getRememberMe(), true);
    });

    test('does not save token when remember me is disabled', () async {
      await storage.saveSession(token: 'test-token', rememberMe: false);

      expect(await storage.getToken(), isNull);

      expect(await storage.getRememberMe(), false);
    });

    test('clears session', () async {
      await storage.saveSession(token: 'test-token', rememberMe: true);

      await storage.clearSession();

      expect(await storage.getToken(), isNull);
    });
  });
}
