import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class Sidebar extends StatelessWidget {
  final String selectedRoute;
  final Function(String route) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedRoute,
    required this.onItemSelected,
  });

  bool _hasPermission(BuildContext context, String permission) {
    final state = context.read<AuthBloc>().state;

    if (state is! AuthAuthenticated) {
      return false;
    }

    return state.loginResponse.permissions.any(
      (item) => item.code == permission,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF172033),
      child: SafeArea(
        child: Column(
          children: [
            _buildLogo(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _menuItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    route: '/dashboard',
                    permission: 'DASHBOARD_VIEW',
                  ),

                  _sectionTitle('MASTER DATA'),

                  _menuItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Products',
                    route: '/products',
                    permission: 'PRODUCT_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Categories',
                    route: '/categories',
                    permission: 'CATEGORY_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.branding_watermark_outlined,
                    title: 'Brands',
                    route: '/brands',
                    permission: 'BRAND_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.straighten_outlined,
                    title: 'Units',
                    route: '/units',
                    permission: 'UNIT_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.local_shipping_outlined,
                    title: 'Suppliers',
                    route: '/suppliers',
                    permission: 'SUPPLIER_VIEW',
                  ),

                  _sectionTitle('INVENTORY'),

                  _menuItem(
                    context,
                    icon: Icons.warehouse_outlined,
                    title: 'Warehouses',
                    route: '/warehouses',
                    permission: 'WAREHOUSE_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.inventory_outlined,
                    title: 'Stock',
                    route: '/stock',
                    permission: 'STOCK_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.tune_outlined,
                    title: 'Stock Adjustments',
                    route: '/stock-adjustments',
                    permission: 'STOCK_ADJUST',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.compare_arrows_outlined,
                    title: 'Stock Transfers',
                    route: '/stock-transfers',
                    permission: 'STOCK_TRANSFER',
                  ),

                  _sectionTitle('PURCHASING'),

                  _menuItem(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    title: 'Purchase Orders',
                    route: '/purchase-orders',
                    permission: 'PURCHASE_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.move_to_inbox_outlined,
                    title: 'Goods Receiving',
                    route: '/goods-receipts',
                    permission: 'RECEIVING_VIEW',
                  ),

                  _sectionTitle('REPORTS'),

                  _menuItem(
                    context,
                    icon: Icons.assessment_outlined,
                    title: 'Stock Report',
                    route: '/reports/stock',
                    permission: 'REPORT_STOCK',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Purchase Report',
                    route: '/reports/purchase',
                    permission: 'REPORT_PURCHASE',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Transaction Report',
                    route: '/reports/transactions',
                    permission: 'REPORT_TRANSACTION',
                  ),

                  _sectionTitle('ADMINISTRATION'),

                  _menuItem(
                    context,
                    icon: Icons.people_outline,
                    title: 'Users',
                    route: '/users',
                    permission: 'USER_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Roles & Permissions',
                    route: '/roles',
                    permission: 'USER_VIEW',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.history_outlined,
                    title: 'Audit Logs',
                    route: '/audit-logs',
                    permission: 'SETTINGS_VIEW',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [
          Icon(Icons.inventory_2, color: Colors.white, size: 30),
          SizedBox(width: 12),
          Text(
            'Inventory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required String permission,
  }) {
    if (!_hasPermission(context, permission)) {
      return const SizedBox.shrink();
    }

    final selected = selectedRoute == route;

    return InkWell(
      onTap: () => onItemSelected(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
