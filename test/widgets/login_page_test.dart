// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:inventory_application/blocs/auth/auth_bloc.dart';
// import 'package:inventory_application/blocs/auth/auth_event.dart';
// import 'package:inventory_application/blocs/auth/auth_state.dart';
// import 'package:inventory_application/features/auth/login_page.dart';

// class TestAuthBloc extends AuthBloc {
//   TestAuthBloc()
//     : super(
//         authService: throw UnimplementedError(),
//         authStorage: throw UnimplementedError(),
//       );

//   @override
//   void add(AuthEvent event) {
//     if (event is LoginRequested) {
//       emit(AuthLoading());
//     }
//   }
// }

// void main() {
//   testWidgets('Login page displays username and password fields', (
//     tester,
//   ) async {
//     final bloc = TestAuthBloc();

//     await tester.pumpWidget(
//       MaterialApp(
//         home: BlocProvider<AuthBloc>.value(
//           value: bloc,
//           child: const LoginPage(),
//         ),
//       ),
//     );

//     expect(find.text('Username'), findsOneWidget);

//     expect(find.text('Password'), findsOneWidget);

//     expect(find.text('LOGIN'), findsOneWidget);

//     expect(find.text('Remember me'), findsOneWidget);

//     await bloc.close();
//   });

//   testWidgets('shows validation when login fields are empty', (tester) async {
//     final bloc = TestAuthBloc();

//     await tester.pumpWidget(
//       MaterialApp(
//         home: BlocProvider<AuthBloc>.value(
//           value: bloc,
//           child: const LoginPage(),
//         ),
//       ),
//     );

//     await tester.tap(find.text('LOGIN'));

//     await tester.pump();

//     expect(find.text('Please enter username'), findsOneWidget);

//     expect(find.text('Please enter password'), findsOneWidget);

//     await bloc.close();
//   });
// }
