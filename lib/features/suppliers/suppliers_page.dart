import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/supplier/supplier_bloc.dart';
import '../../blocs/supplier/supplier_event.dart';
import '../../blocs/supplier/supplier_state.dart';
import '../../core/utils/responsive.dart';
import '../../models/supplier_model.dart';
import 'supplier_form_page.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
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

  List<SupplierModel> _filterSuppliers(List<SupplierModel> suppliers) {
    if (_searchText.isEmpty) {
      return suppliers;
    }

    return suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(_searchText) ||
          supplier.supplierCode.toLowerCase().contains(_searchText) ||
          (supplier.contactPerson ?? '').toLowerCase().contains(_searchText) ||
          (supplier.phone ?? '').toLowerCase().contains(_searchText) ||
          (supplier.email ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  void _openAddSupplier() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SupplierBloc>(),
          child: const SupplierFormPage(),
        ),
      ),
    );
  }

  void _openEditSupplier(SupplierModel supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SupplierBloc>(),
          child: SupplierFormPage(supplier: supplier),
        ),
      ),
    );
  }

  void _confirmDelete(SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Supplier'),
          content: Text(
            'Are you sure you want to delete '
            '"${supplier.name}"?',
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

                context.read<SupplierBloc>().add(
                  SupplierDeleteRequested(supplier.id),
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
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<SupplierBloc>().add(SupplierRefreshRequested());
            },
            icon: const Icon(Icons.refresh),
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: _openAddSupplier,
                icon: const Icon(Icons.add),
                label: const Text('Add Supplier'),
              ),
            ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: _openAddSupplier,
              child: const Icon(Icons.add),
            )
          : null,
      body: BlocConsumer<SupplierBloc, SupplierState>(
        listener: (context, state) {
          if (state is SupplierOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is SupplierError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SupplierLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SupplierError) {
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
                        context.read<SupplierBloc>().add(
                          SupplierLoadRequested(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SupplierLoaded) {
            final suppliers = _filterSuppliers(state.suppliers);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SupplierBloc>().add(SupplierRefreshRequested());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                children: [
                  _buildSearchBox(),
                  const SizedBox(height: 16),
                  if (suppliers.isEmpty)
                    _buildEmptyState()
                  else if (isMobile)
                    _buildMobileList(suppliers)
                  else
                    _buildDesktopTable(suppliers),
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
        hintText: 'Search by supplier, code, contact, phone or email...',
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

  Widget _buildDesktopTable(List<SupplierModel> suppliers) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Supplier')),
            DataColumn(label: Text('Contact Person')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Payment Terms')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: suppliers.map((supplier) {
            return DataRow(
              cells: [
                DataCell(Text(supplier.supplierCode)),
                DataCell(Text(supplier.name)),
                DataCell(Text(supplier.contactPerson ?? '-')),
                DataCell(Text(supplier.phone ?? '-')),
                DataCell(Text(supplier.email ?? '-')),
                DataCell(Text(supplier.paymentTerms ?? '-')),
                DataCell(_buildStatus(supplier.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          _openEditSupplier(supplier);
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () {
                          _confirmDelete(supplier);
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

  Widget _buildMobileList(List<SupplierModel> suppliers) {
    return Column(
      children: suppliers.map((supplier) {
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
                        supplier.name.isNotEmpty
                            ? supplier.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            supplier.supplierCode,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    _buildStatus(supplier.isActive),
                  ],
                ),
                const Divider(height: 24),
                if ((supplier.contactPerson ?? '').isNotEmpty)
                  _buildInfoRow(Icons.person_outline, supplier.contactPerson!),
                if ((supplier.phone ?? '').isNotEmpty)
                  _buildInfoRow(Icons.phone_outlined, supplier.phone!),
                if ((supplier.email ?? '').isNotEmpty)
                  _buildInfoRow(Icons.email_outlined, supplier.email!),
                if ((supplier.paymentTerms ?? '').isNotEmpty)
                  _buildInfoRow(
                    Icons.payments_outlined,
                    supplier.paymentTerms!,
                  ),
                if ((supplier.address ?? '').isNotEmpty)
                  _buildInfoRow(Icons.location_on_outlined, supplier.address!),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _openEditSupplier(supplier);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        _confirmDelete(supplier);
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
          Icon(Icons.business_outlined, size: 60),
          SizedBox(height: 12),
          Text('No suppliers found.', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
