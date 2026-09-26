import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/unit/unit_bloc.dart';
import '../../blocs/unit/unit_event.dart';
import '../../blocs/unit/unit_state.dart';
import '../../models/unit_model.dart';
import 'unit_form_page.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
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

  List<UnitModel> _filterUnits(List<UnitModel> units) {
    if (_searchText.isEmpty) {
      return units;
    }

    return units.where((unit) {
      return unit.name.toLowerCase().contains(_searchText) ||
          (unit.shortName ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  void _openAddUnit() {
    final unitBloc = context.read<UnitBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: unitBloc, child: const UnitFormPage()),
      ),
    ).then((result) {
      if (result == true) {
        unitBloc.add(UnitLoadRequested());
      }
    });
  }

  void _openEditUnit(UnitModel unit) {
    final unitBloc = context.read<UnitBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: unitBloc,
          child: UnitFormPage(unit: unit),
        ),
      ),
    ).then((result) {
      if (result == true) {
        unitBloc.add(UnitLoadRequested());
      }
    });
  }

  void _confirmDelete(UnitModel unit) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Unit'),
          content: Text(
            'Are you sure you want to delete '
            '"${unit.name}"?',
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

                context.read<UnitBloc>().add(UnitDeleteRequested(unit.id));
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
        title: const Text('Units'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<UnitBloc>().add(UnitRefreshRequested());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocListener<UnitBloc, UnitState>(
        listener: (context, state) {
          if (state is UnitError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is UnitOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<UnitBloc, UnitState>(
          builder: (context, state) {
            if (state is UnitLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UnitError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UnitBloc>().add(UnitLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            List<UnitModel> units = [];

            if (state is UnitLoaded) {
              units = state.units;
            }

            if (state is UnitCreating) {
              units = state.units;
            }

            final filteredUnits = _filterUnits(units);

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
                                hintText: 'Search units...',
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
                            onPressed: _openAddUnit,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Unit'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: filteredUnits.isEmpty
                            ? const Center(child: Text('No units found.'))
                            : isMobile
                            ? _buildMobileList(filteredUnits)
                            : _buildDesktopTable(filteredUnits),
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

  Widget _buildDesktopTable(List<UnitModel> units) {
    return Card(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Unit Name')),
              DataColumn(label: Text('Short Name')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: units.map((unit) {
              return DataRow(
                cells: [
                  DataCell(Text(unit.id.toString())),
                  DataCell(Text(unit.name)),
                  DataCell(Text(unit.shortName ?? '')),
                  DataCell(Text(unit.isActive ? 'Active' : 'Inactive')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () {
                            _openEditUnit(unit);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () {
                            _confirmDelete(unit);
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

  Widget _buildMobileList(List<UnitModel> units) {
    return ListView.separated(
      itemCount: units.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final unit = units[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                (unit.shortName ?? '').isNotEmpty
                    ? (unit.shortName ?? '')[0].toUpperCase()
                    : '?',
              ),
            ),
            title: Text(unit.name),
            subtitle: Text(
              '${unit.shortName ?? ''} • '
              '${unit.isActive ? 'Active' : 'Inactive'}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _openEditUnit(unit);
                }

                if (value == 'delete') {
                  _confirmDelete(unit);
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
