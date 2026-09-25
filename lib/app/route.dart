import 'package:flutter/material.dart';
import 'package:inventory_application/blocs/category/category_bloc.dart';
import 'package:inventory_application/blocs/category/category_event.dart';
import 'package:inventory_application/blocs/dashboard/dashboard_event.dart';
import 'package:inventory_application/blocs/product/product_event.dart';
import 'package:inventory_application/features/categories/categories_page.dart';
import 'package:inventory_application/features/products/products_page.dart';
import 'package:inventory_application/services/category_service.dart';
import 'package:inventory_application/services/product_service.dart';

import '../features/auth/login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../core/network/api_client.dart';
import '../core/storage/auth_storage.dart';
import '../services/dashboard_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product/product_bloc.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String categories = '/categories';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => DashboardBloc(
              dashboardService: DashboardService(ApiClient()),
              authStorage: AuthStorage(),
            )..add(DashboardLoadRequested()),
            child: const DashboardPage(),
          ),
        );
      case products:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProductBloc(
              productService: ProductService(ApiClient()),
              authStorage: AuthStorage(),
            )..add(ProductLoadRequested()),
            child: const ProductsPage(),
          ),
        );
      case categories:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => CategoryBloc(
              categoryService: CategoryService(ApiClient()),
              authStorage: AuthStorage(),
            )..add(CategoryLoadRequested()),
            child: const CategoriesPage(),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
