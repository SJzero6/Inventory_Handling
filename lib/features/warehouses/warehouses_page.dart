import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/warehouse/warehouse_bloc.dart';
import '../../blocs/warehouse/warehouse_event.dart';
import '../../blocs/warehouse/warehouse_state.dart';
import '../../core/utils/responsive.dart';
import '../../models/warehouse_model.dart';
import 'warehouse_form_page.dart';

class WarehousesPage extends StatefulWidget {
  const WarehousesPage({super.key});

  @override
  State<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WarehouseModel> _filterWarehouses(List<WarehouseModel> warehouses) {
    if (_searchText.isEmpty) {
      return warehouses;
    }

    return warehouses.where((warehouse) {
      return warehouse.name.toLowerCase().contains(_searchText) ||
          warehouse.code.toLowerCase().contains(_searchText) ||
          warehouse.branchName.toLowerCase().contains(_searchText) ||
          (warehouse.address ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  void _openAddWarehouse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<WarehouseBloc>(),
          child: const WarehouseFormPage(),
        ),
      ),
    );
  }

  void _openEditWarehouse(WarehouseModel warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<WarehouseBloc>(),
          child: WarehouseFormPage(warehouse: warehouse),
        ),
      ),
    );
  }

  void _confirmDelete(WarehouseModel warehouse) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Warehouse'),
          content: Text(
            'Are you sure you want to delete '
            '"${warehouse.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<WarehouseBloc>().add(
                  WarehouseDeleteRequested(warehouse.id),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<WarehouseBloc>().add(WarehouseRefreshRequested());
            },
            icon: const Icon(Icons.refresh),
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: _openAddWarehouse,
                icon: const Icon(Icons.add),
                label: const Text('Add Warehouse'),
              ),
            ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: _openAddWarehouse,
              child: const Icon(Icons.add),
            )
          : null,
      body: BlocConsumer<WarehouseBloc, WarehouseState>(
        listener: (context, state) {
          if (state is WarehouseOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is WarehouseError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is WarehouseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WarehouseError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<WarehouseBloc>().add(
                          WarehouseLoadRequested(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is WarehouseLoaded) {
            final warehouses = _filterWarehouses(state.warehouses);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WarehouseBloc>().add(WarehouseRefreshRequested());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                children: [
                  _buildSearchBox(),
                  const SizedBox(height: 16),
                  if (warehouses.isEmpty)
                    _buildEmptyState()
                  else if (isMobile)
                    _buildMobileList(warehouses)
                  else
                    _buildDesktopTable(warehouses),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by warehouse, code, branch or address...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDesktopTable(List<WarehouseModel> warehouses) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Warehouse')),
            DataColumn(label: Text('Branch')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: warehouses.map((warehouse) {
            return DataRow(
              cells: [
                DataCell(Text(warehouse.code)),
                DataCell(Text(warehouse.name)),
                DataCell(Text(warehouse.branchName)),
                DataCell(Text(warehouse.address ?? '-')),
                DataCell(_buildStatus(warehouse.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          _openEditWarehouse(warehouse);
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () {
                          _confirmDelete(warehouse);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<WarehouseModel> warehouses) {
    return Column(
      children: warehouses.map((warehouse) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        warehouse.name.isNotEmpty
                            ? warehouse.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            warehouse.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            warehouse.code,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    _buildStatus(warehouse.isActive),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.account_tree_outlined,
                  warehouse.branchName,
                ),
                if ((warehouse.address ?? '').isNotEmpty)
                  _buildInfoRow(Icons.location_on_outlined, warehouse.address!),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _openEditWarehouse(warehouse);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        _confirmDelete(warehouse);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatus(bool isActive) {
    return Chip(
      label: Text(isActive ? 'Active' : 'Inactive'),
      avatar: Icon(
        isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
        size: 16,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.warehouse_outlined, size: 60),
          SizedBox(height: 12),
          Text('No warehouses found.', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
