import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_application/blocs/product_form/product_form_bloc.dart';
import 'package:inventory_application/blocs/product_form/product_form_event.dart';
import 'package:inventory_application/core/network/api_client.dart';
import 'package:inventory_application/core/storage/auth_storage.dart';
import 'package:inventory_application/features/products/product_form_page.dart';
import 'package:inventory_application/services/brand_service.dart';
import 'package:inventory_application/services/category_service.dart';
import 'package:inventory_application/services/unit_service.dart';

import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../../layouts/admin_layout.dart';
import '../../models/product_model.dart';
import '../../core/utils/responsive.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    if (_searchText.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(_searchText) ||
          product.productCode.toLowerCase().contains(_searchText) ||
          (product.barcode ?? '').toLowerCase().contains(_searchText) ||
          (product.categoryName ?? '').toLowerCase().contains(_searchText) ||
          (product.brandName ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedRoute: '/products',
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is ProductError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading || state is ProductInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<ProductBloc>().add(ProductLoadRequested());
                },
              );
            }

            if (state is ProductLoaded) {
              final products = _filterProducts(state.products);

              return _ProductsContent(
                products: products,
                totalProducts: state.products.length,
                searchController: _searchController,
                onRefresh: () {
                  context.read<ProductBloc>().add(ProductRefreshRequested());
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ProductsContent extends StatelessWidget {
  final List<ProductModel> products;
  final int totalProducts;
  final TextEditingController searchController;
  final VoidCallback onRefresh;

  const _ProductsContent({
    required this.products,
    required this.totalProducts,
    required this.searchController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.all(mobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),

          const SizedBox(height: 20),

          _buildSearchBar(context),

          const SizedBox(height: 20),

          Expanded(
            child: mobile
                ? _MobileProductList(products: products)
                : _DesktopProductTable(products: products),
          ),
        ],
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
                'Products',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$totalProducts products',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        if (!Responsive.isMobile(context))
          ElevatedButton.icon(
            onPressed: () {
              final productBloc = context.read<ProductBloc>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: productBloc),
                      BlocProvider(
                        create: (_) => ProductFormBloc(
                          categoryService: CategoryService(ApiClient()),
                          brandService: BrandService(ApiClient()),
                          unitService: UnitService(ApiClient()),
                          authStorage: AuthStorage(),
                        )..add(ProductFormLoadRequested()),
                      ),
                    ],
                    child: const ProductFormPage(),
                  ),
                ),
              ).then((result) {
                if (result == true) {
                  productBloc.add(ProductLoadRequested());
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),

        const SizedBox(width: 8),

        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search by product name, code, barcode...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
      ),
    );
  }
}

class _DesktopProductTable extends StatelessWidget {
  final List<ProductModel> products;

  const _DesktopProductTable({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _EmptyProducts();
    }

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 50,
            dataRowMinHeight: 58,
            dataRowMaxHeight: 70,
            columns: const [
              DataColumn(label: Text('Code')),
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Brand')),
              DataColumn(label: Text('Unit')),
              DataColumn(label: Text('Purchase')),
              DataColumn(label: Text('Selling')),
              DataColumn(label: Text('Stock Min.')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: products.map((product) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      product.productCode,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(SizedBox(width: 180, child: Text(product.name))),
                  DataCell(Text(product.categoryName ?? '-')),
                  DataCell(Text(product.brandName ?? '-')),
                  DataCell(Text(product.unitName ?? '-')),
                  DataCell(
                    Text('AED ${product.purchasePrice.toStringAsFixed(2)}'),
                  ),
                  DataCell(
                    Text('AED ${product.sellingPrice.toStringAsFixed(2)}'),
                  ),
                  DataCell(Text(product.minimumStock.toString())),
                  DataCell(_StatusBadge(isActive: product.isActive)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () {
                            // print('hi i am here');
                            final productBloc = context.read<ProductBloc>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: productBloc),
                                    BlocProvider(
                                      create: (_) => ProductFormBloc(
                                        categoryService: CategoryService(
                                          ApiClient(),
                                        ),
                                        brandService: BrandService(ApiClient()),
                                        unitService: UnitService(ApiClient()),
                                        authStorage: AuthStorage(),
                                      )..add(ProductFormLoadRequested()),
                                    ),
                                  ],
                                  child: ProductFormPage(product: product),
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                productBloc.add(ProductLoadRequested());
                              }
                            });
                          },
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () {
                            _confirmDelete(context, product);
                          },
                          icon: const Icon(Icons.delete_outline, size: 20),
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

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete '
            '"${product.name}"?',
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

                context.read<ProductBloc>().add(
                  ProductDeleteRequested(product.id),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _MobileProductList extends StatelessWidget {
  final List<ProductModel> products;

  const _MobileProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _EmptyProducts();
    }

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        product.name.isNotEmpty
                            ? product.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.productCode,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(isActive: product.isActive),
                  ],
                ),

                const Divider(height: 24),

                _MobileInfoRow(label: 'Barcode', value: product.barcode ?? '-'),
                _MobileInfoRow(label: 'Unit', value: product.unitName ?? '-'),
                _MobileInfoRow(
                  label: 'Purchase Price',
                  value: 'AED ${product.purchasePrice.toStringAsFixed(2)}',
                ),
                _MobileInfoRow(
                  label: 'Selling Price',
                  value: 'AED ${product.sellingPrice.toStringAsFixed(2)}',
                ),
                _MobileInfoRow(
                  label: 'Minimum Stock',
                  value: product.minimumStock.toString(),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        _confirmDelete(context, product);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete '
            '"${product.name}"?',
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

                context.read<ProductBloc>().add(
                  ProductDeleteRequested(product.id),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _MobileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _MobileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isActive
            ? Colors.green.withValues(alpha: 0.10)
            : Colors.red.withValues(alpha: 0.10),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
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
