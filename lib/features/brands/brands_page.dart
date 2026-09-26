import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/brand/brand_bloc.dart';
import '../../blocs/brand/brand_event.dart';
import '../../blocs/brand/brand_state.dart';
import '../../models/brand_model.dart';
import 'brand_form_page.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  final _searchController = TextEditingController();

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

  List<BrandModel> _filterBrands(List<BrandModel> brands) {
    if (_searchText.isEmpty) {
      return brands;
    }

    return brands.where((brand) {
      return brand.name.toLowerCase().contains(_searchText);
    }).toList();
  }

  void _openAddBrand() {
    final brandBloc = context.read<BrandBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: brandBloc, child: const BrandFormPage()),
      ),
    ).then((result) {
      if (result == true) {
        brandBloc.add(BrandLoadRequested());
      }
    });
  }

  void _openEditBrand(BrandModel brand) {
    final brandBloc = context.read<BrandBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: brandBloc,
          child: BrandFormPage(brand: brand),
        ),
      ),
    ).then((result) {
      if (result == true) {
        brandBloc.add(BrandLoadRequested());
      }
    });
  }

  void _confirmDelete(BrandModel brand) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Brand'),
          content: Text(
            'Are you sure you want to delete '
            '"${brand.name}"?',
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

                context.read<BrandBloc>().add(BrandDeleteRequested(brand.id));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<BrandBloc>().add(BrandRefreshRequested());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocListener<BrandBloc, BrandState>(
        listener: (context, state) {
          if (state is BrandError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is BrandOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<BrandBloc, BrandState>(
          builder: (context, state) {
            if (state is BrandLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BrandError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BrandBloc>().add(BrandLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            List<BrandModel> brands = [];

            if (state is BrandLoaded) {
              brands = state.brands;
            }

            if (state is BrandCreating) {
              brands = state.brands;
            }

            final filteredBrands = _filterBrands(brands);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search brands...',
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
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _openAddBrand,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Brand'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: filteredBrands.isEmpty
                            ? const Center(child: Text('No brands found.'))
                            : isMobile
                            ? _buildMobileList(filteredBrands)
                            : _buildDesktopTable(filteredBrands),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopTable(List<BrandModel> brands) {
    return Card(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Brand Name')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: brands.map((brand) {
              return DataRow(
                cells: [
                  DataCell(Text(brand.id.toString())),
                  DataCell(Text(brand.name)),
                  DataCell(Text(brand.isActive ? 'Active' : 'Inactive')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () {
                            _openEditBrand(brand);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () {
                            _confirmDelete(brand);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<BrandModel> brands) {
    return ListView.separated(
      itemCount: brands.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final brand = brands[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                brand.name.isNotEmpty ? brand.name[0].toUpperCase() : '?',
              ),
            ),
            title: Text(brand.name),
            subtitle: Text(brand.isActive ? 'Active' : 'Inactive'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _openEditBrand(brand);
                }

                if (value == 'delete') {
                  _confirmDelete(brand);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}
