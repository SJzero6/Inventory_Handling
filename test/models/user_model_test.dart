import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_application/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('creates UserModel from JSON correctly', () {
      final json = {
        'id': 1,
        'username': 'admin',
        'fullName': 'System Administrator',
        'email': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'admin');
      expect(user.fullName, 'System Administrator');
      expect(user.email, isNull);
    });
  });
}
