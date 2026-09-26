import 'package:flutter/material.dart';
import 'package:inventory_application/blocs/brand/brand_bloc.dart';
import 'package:inventory_application/blocs/brand/brand_event.dart';
import 'package:inventory_application/blocs/category/category_bloc.dart';
import 'package:inventory_application/blocs/category/category_event.dart';
import 'package:inventory_application/blocs/dashboard/dashboard_event.dart';
import 'package:inventory_application/blocs/product/product_event.dart';
import 'package:inventory_application/blocs/supplier/supplier_bloc.dart';
import 'package:inventory_application/blocs/supplier/supplier_event.dart';
import 'package:inventory_application/blocs/unit/unit_bloc.dart';
import 'package:inventory_application/blocs/unit/unit_event.dart';
import 'package:inventory_application/features/brands/brands_page.dart';
import 'package:inventory_application/features/categories/categories_page.dart';
import 'package:inventory_application/features/products/products_page.dart';
import 'package:inventory_application/features/suppliers/suppliers_page.dart';
import 'package:inventory_application/features/units/units_page.dart';
import 'package:inventory_application/services/brand_service.dart';
import 'package:inventory_application/services/category_service.dart';
import 'package:inventory_application/services/product_service.dart';
import 'package:inventory_application/services/supplier_service.dart';
import 'package:inventory_application/services/unit_service.dart';

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
  static const String brands = '/brands';
  static const String units = '/units';
  static const String suppliers = '/suppliers';

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

      case brands:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => BrandBloc(
              brandService: BrandService(ApiClient()),
              authStorage: AuthStorage(),
            )..add(BrandLoadRequested()),
            child: const BrandsPage(),
          ),
        );

      case units:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => UnitBloc(
              unitService: UnitService(ApiClient()),
              authStorage: AuthStorage(),
            )..add(UnitLoadRequested()),
            child: const UnitsPage(),
          ),
        );
      case suppliers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => SupplierBloc(
              supplierService: SupplierService(ApiClient()),
              authStorage: AuthStorage(),
            )..add(SupplierLoadRequested()),
            child: const SuppliersPage(),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
