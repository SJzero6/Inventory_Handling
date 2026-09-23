import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_application/models/login_response.dart';

void main() {
  group('LoginResponse', () {
    test('parses login response correctly', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'token': 'test-token',
        'user': {
          'id': 1,
          'username': 'admin',
          'fullName': 'System Administrator',
          'email': null,
        },
        'company': {'id': 1, 'name': 'Inventory Demo Company'},
        'branch': {'id': 1, 'name': 'Main Branch'},
        'roles': [
          {'Id': 1, 'Name': 'Super Admin'},
        ],
        'permissions': [
          {
            'Id': 1,
            'Code': 'DASHBOARD_VIEW',
            'Name': 'View Dashboard',
            'Module': 'Dashboard',
          },
        ],
      };

      final result = LoginResponse.fromJson(json);

      expect(result.success, true);
      expect(result.message, 'Login successful');
      expect(result.token, 'test-token');

      expect(result.user.username, 'admin');
      expect(result.company.name, 'Inventory Demo Company');
      expect(result.branch.name, 'Main Branch');

      expect(result.roles.length, 1);
      expect(result.roles.first.name, 'Super Admin');

      expect(result.permissions.length, 1);
      expect(result.permissions.first.code, 'DASHBOARD_VIEW');
    });
  });
}
