import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_application/blocs/auth/auth_state.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../layouts/admin_layout.dart';
import '../../models/dashboard_model.dart';
import '../../core/utils/responsive.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    String userName = 'User';

    if (authState is AuthAuthenticated) {
      userName = authState.loginResponse.user.fullName;
    }

    return AdminLayout(
      selectedRoute: '/dashboard',
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<DashboardBloc>().add(DashboardLoadRequested());
              },
            );
          }

          if (state is DashboardLoaded) {
            return _DashboardContent(
              dashboard: state.dashboard,
              userName: userName,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardModel dashboard;
  final String userName;

  const _DashboardContent({required this.dashboard, required this.userName});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(DashboardRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 24),

              _buildSummaryCards(context),

              const SizedBox(height: 24),

              _buildStockAndPurchase(context),

              const SizedBox(height: 24),

              _buildRecentData(context, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back, $userName',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            context.read<DashboardBloc>().add(DashboardRefreshRequested());
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final summary = dashboard.summary;

    final cards = [
      _SummaryCardData(
        title: 'Products',
        value: summary.products.total.toString(),
        subtitle: '${summary.products.active} active',
        icon: Icons.inventory_2_outlined,
      ),
      _SummaryCardData(
        title: 'Suppliers',
        value: summary.suppliers.toString(),
        subtitle: 'Total suppliers',
        icon: Icons.local_shipping_outlined,
      ),
      _SummaryCardData(
        title: 'Warehouses',
        value: summary.warehouses.toString(),
        subtitle: 'Total warehouses',
        icon: Icons.warehouse_outlined,
      ),
      _SummaryCardData(
        title: 'Branches',
        value: summary.branches.toString(),
        subtitle: 'Total branches',
        icon: Icons.account_tree_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Responsive.isMobile(context)
            ? 1
            : Responsive.isTablet(context)
            ? 2
            : 4;

        final spacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(data: card),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildStockAndPurchase(BuildContext context) {
    final stock = dashboard.summary.stock;
    final purchases = dashboard.summary.purchases;
    final receiving = dashboard.summary.receiving;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = Responsive.isMobile(context);

        final stockCard = _DashboardPanel(
          title: 'Stock Overview',
          icon: Icons.inventory_outlined,
          child: Column(
            children: [
              _InfoRow(label: 'Stock Items', value: stock.itemCount.toString()),
              _InfoRow(
                label: 'Total Quantity',
                value: stock.totalQuantity.toString(),
              ),
              _InfoRow(
                label: 'Total Value',
                value: _formatCurrency(stock.totalValue),
              ),
            ],
          ),
        );

        final purchaseCard = _DashboardPanel(
          title: 'Purchase Orders',
          icon: Icons.shopping_cart_outlined,
          child: Column(
            children: [
              _InfoRow(label: 'Total', value: purchases.total.toString()),
              _InfoRow(label: 'Draft', value: purchases.draft.toString()),
              _InfoRow(label: 'Approved', value: purchases.approved.toString()),
              _InfoRow(
                label: 'Partially Received',
                value: purchases.partiallyReceived.toString(),
              ),
              _InfoRow(
                label: 'Fully Received',
                value: purchases.fullyReceived.toString(),
              ),
            ],
          ),
        );

        final receivingCard = _DashboardPanel(
          title: 'Goods Receiving',
          icon: Icons.move_to_inbox_outlined,
          child: Column(
            children: [
              _InfoRow(label: 'Total', value: receiving.total.toString()),
              _InfoRow(label: 'Received', value: receiving.received.toString()),
              _InfoRow(label: 'Approved', value: receiving.approved.toString()),
              _InfoRow(
                label: 'Cancelled',
                value: receiving.cancelled.toString(),
              ),
            ],
          ),
        );

        if (mobile) {
          return Column(
            children: [
              stockCard,
              const SizedBox(height: 16),
              purchaseCard,
              const SizedBox(height: 16),
              receivingCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: stockCard),
            const SizedBox(width: 16),
            Expanded(child: purchaseCard),
            const SizedBox(width: 16),
            Expanded(child: receivingCard),
          ],
        );
      },
    );
  }

  Widget _buildRecentData(BuildContext context, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardPanel(
          title: 'Recent Transactions',
          icon: Icons.swap_horiz_outlined,
          child: dashboard.recentTransactions.isEmpty
              ? const _EmptyData()
              : _RecentTransactions(transactions: dashboard.recentTransactions),
        ),

        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            if (Responsive.isMobile(context)) {
              return Column(
                children: [
                  _DashboardPanel(
                    title: 'Recent Purchase Orders',
                    icon: Icons.shopping_cart_outlined,
                    child: _PurchaseOrders(
                      orders: dashboard.recentPurchaseOrders,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DashboardPanel(
                    title: 'Recent Goods Receipts',
                    icon: Icons.receipt_long_outlined,
                    child: _GoodsReceipts(
                      receipts: dashboard.recentGoodsReceipts,
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DashboardPanel(
                    title: 'Recent Purchase Orders',
                    icon: Icons.shopping_cart_outlined,
                    child: _PurchaseOrders(
                      orders: dashboard.recentPurchaseOrders,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DashboardPanel(
                    title: 'Recent Goods Receipts',
                    icon: Icons.receipt_long_outlined,
                    child: _GoodsReceipts(
                      receipts: dashboard.recentGoodsReceipts,
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        _DashboardPanel(
          title: 'Low Stock Products',
          icon: Icons.warning_amber_outlined,
          child: dashboard.lowStockProducts.isEmpty
              ? const _EmptyData(message: 'No low stock products')
              : _LowStockProducts(products: dashboard.lowStockProducts),
        ),
      ],
    );
  }

  static String _formatCurrency(num value) {
    return 'AED ${value.toStringAsFixed(2)}';
  }
}

class _SummaryCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  _SummaryCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
              ),
              child: Icon(
                data.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DashboardPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<RecentTransaction> transactions;

  const _RecentTransactions({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions.take(10).map((transaction) {
        final positive = transaction.quantity >= 0;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            child: Icon(
              positive ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
            ),
          ),
          title: Text(
            transaction.productName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${transaction.productCode} • '
            '${transaction.transactionType} • '
            '${transaction.warehouseName}',
          ),
          trailing: Text(
            '${positive ? '+' : ''}${transaction.quantity}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: positive ? Colors.green : Colors.red,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PurchaseOrders extends StatelessWidget {
  final List<RecentPurchaseOrder> orders;

  const _PurchaseOrders({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyData();
    }

    return Column(
      children: orders.map((order) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            order.purchaseOrderNumber,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${order.supplierName} • ${order.warehouseName}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AED ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              _StatusBadge(status: order.status),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GoodsReceipts extends StatelessWidget {
  final List<RecentGoodsReceipt> receipts;

  const _GoodsReceipts({required this.receipts});

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty) {
      return const _EmptyData();
    }

    return Column(
      children: receipts.map((receipt) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            receipt.receiptNumber,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${receipt.supplierName} • '
            '${receipt.warehouseName}',
          ),
          trailing: _StatusBadge(status: receipt.status),
        );
      }).toList(),
    );
  }
}

class _LowStockProducts extends StatelessWidget {
  final List<LowStockProduct> products;

  const _LowStockProducts({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products.map((product) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.warning_amber),
          title: Text(product.productName ?? ''),
          subtitle: Text(product.productCode ?? ''),
          trailing: Text(
            '${product.quantity ?? 0}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey.shade200,
      ),
      child: Text(
        status,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyData extends StatelessWidget {
  final String message;

  const _EmptyData({this.message = 'No data available'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
