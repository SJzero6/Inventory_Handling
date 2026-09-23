// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:inventory_application/blocs/auth/auth_bloc.dart';
// import 'package:inventory_application/blocs/auth/auth_state.dart';
// import 'package:inventory_application/core/storage/auth_storage.dart';
// import 'package:inventory_application/features/auth/login_page.dart';
// import 'package:inventory_application/services/auth_service.dart';

// class FakeAuthService extends AuthService {
//   FakeAuthService() : super(null as dynamic);

//   @override
//   Future LoginPage({required String username, required String password}) async {
//     throw UnimplementedError();
//   }
// }

// void main() {
//   group('AuthBloc', () {
//     test('initial state is AuthInitial', () {
//       final bloc = AuthBloc(
//         authService: FakeAuthService(),
//         authStorage: AuthStorage(),
//       );

//       expect(bloc.state, isA<AuthInitial>());

//       bloc.close();
//     });
//   });
// }
