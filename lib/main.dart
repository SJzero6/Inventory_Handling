import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_application/app/route.dart';

import 'blocs/auth/auth_bloc.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final authStorage = AuthStorage();

  runApp(
    BlocProvider(
      create: (_) => AuthBloc(
        authService: authService,
        authStorage: authStorage,
      ), // add ..add(AuthCheckRequested()) to restore a saved session
      child: const InventoryApp(),
    ),
  );
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Management',
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
