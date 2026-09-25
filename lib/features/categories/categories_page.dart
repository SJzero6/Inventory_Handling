import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_application/features/categories/category_form_page.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../core/utils/responsive.dart';
import '../../models/category_model.dart';
import '../../layouts/admin_layout.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String _searchQuery = '';

  List<CategoryModel> _filterCategories(List<CategoryModel> categories) {
    if (_searchQuery.trim().isEmpty) {
      return categories;
    }

    final query = _searchQuery.toLowerCase();

    return categories.where((category) {
      return category.name.toLowerCase().contains(query) ||
          (category.description ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedRoute: '/categories',
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoryBloc>().add(CategoryLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryLoaded) {
            final categories = _filterCategories(state.categories);

            return _buildContent(context, categories);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<CategoryModel> categories) {
    return Padding(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSearch(),
          const SizedBox(height: 20),
          Expanded(
            child: Responsive.isMobile(context)
                ? _buildMobileList(categories)
                : _buildDesktopTable(categories),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final categoryBloc = context.read<CategoryBloc>();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: categoryBloc,
                  child: const CategoryFormPage(),
                ),
              ),
            ).then((result) {
              if (result == true) {
                categoryBloc.add(CategoryLoadRequested());
              }
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Category'),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: const InputDecoration(
        hintText: 'Search categories...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDesktopTable(List<CategoryModel> categories) {
    return Card(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Description')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: categories.map((category) {
              return DataRow(
                cells: [
                  DataCell(Text(category.name)),
                  DataCell(Text(category.description ?? '-')),
                  DataCell(_statusBadge(category.isActive)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            final categoryBloc = context.read<CategoryBloc>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: categoryBloc,
                                  child: CategoryFormPage(category: category),
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                categoryBloc.add(CategoryLoadRequested());
                              }
                            });
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Delete will be implemented next.
                          },
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

  Widget _buildMobileList(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories found.'));
    }

    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = categories[index];

        return Card(
          child: ListTile(
            title: Text(category.name),
            subtitle: Text(category.description ?? '-'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // Edit will be implemented next.
                }

                if (value == 'delete') {
                  // Delete will be implemented next.
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

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Text(isActive ? 'Active' : 'Inactive'),
    );
  }
}
