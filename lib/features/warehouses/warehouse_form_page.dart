import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/warehouse/warehouse_bloc.dart';
import '../../blocs/warehouse/warehouse_event.dart';
import '../../blocs/warehouse/warehouse_state.dart';
import '../../models/warehouse_model.dart';

class WarehouseFormPage extends StatefulWidget {
  final WarehouseModel? warehouse;

  const WarehouseFormPage({super.key, this.warehouse});

  @override
  State<WarehouseFormPage> createState() => _WarehouseFormPageState();
}

class _WarehouseFormPageState extends State<WarehouseFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _branchIdController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isActive = true;

  bool get isEditMode => widget.warehouse != null;

  @override
  void initState() {
    super.initState();

    final warehouse = widget.warehouse;

    if (warehouse != null) {
      _nameController.text = warehouse.name;
      _codeController.text = warehouse.code;
      _branchIdController.text = warehouse.branchId.toString();
      _addressController.text = warehouse.address ?? '';

      _isActive = warehouse.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _branchIdController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  Map<String, dynamic> _buildRequest() {
    return {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'branchId': int.tryParse(_branchIdController.text.trim()) ?? 0,
      'address': _addressController.text.trim(),
      'isActive': _isActive,
    };
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final branchId = int.tryParse(_branchIdController.text.trim());

    if (branchId == null || branchId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Branch ID.')),
      );
      return;
    }

    final data = _buildRequest();

    if (isEditMode) {
      context.read<WarehouseBloc>().add(
        WarehouseUpdateRequested(widget.warehouse!.id, data),
      );
    } else {
      context.read<WarehouseBloc>().add(WarehouseCreateRequested(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Warehouse' : 'Add Warehouse'),
      ),
      body: BlocListener<WarehouseBloc, WarehouseState>(
        listener: (context, state) {
          if (state is WarehouseOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            Navigator.pop(context);
          }

          if (state is WarehouseError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Warehouse Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Warehouse Name',
                      hint: 'Enter warehouse name',
                      icon: Icons.warehouse_outlined,
                      required: true,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _codeController,
                      label: 'Warehouse Code',
                      hint: 'Example: WH-001',
                      icon: Icons.tag,
                      required: true,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _branchIdController,
                      label: 'Branch ID',
                      hint: 'Enter branch ID',
                      icon: Icons.account_tree_outlined,
                      required: true,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter warehouse address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active Warehouse'),
                      subtitle: Text(
                        _isActive
                            ? 'Warehouse is active'
                            : 'Warehouse is inactive',
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    BlocBuilder<WarehouseBloc, WarehouseState>(
                      builder: (context, state) {
                        final isSaving = state is WarehouseCreating;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                    },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: isSaving ? null : _submit,
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                isSaving
                                    ? 'Saving...'
                                    : isEditMode
                                    ? 'Update Warehouse'
                                    : 'Save Warehouse',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
