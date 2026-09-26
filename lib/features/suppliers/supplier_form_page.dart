import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/supplier/supplier_bloc.dart';
import '../../blocs/supplier/supplier_event.dart';
import '../../blocs/supplier/supplier_state.dart';
import '../../models/supplier_model.dart';

class SupplierFormPage extends StatefulWidget {
  final SupplierModel? supplier;

  const SupplierFormPage({super.key, this.supplier});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _supplierCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _paymentTermsController = TextEditingController();

  bool _isActive = true;

  bool get isEditMode => widget.supplier != null;

  @override
  void initState() {
    super.initState();

    final supplier = widget.supplier;

    if (supplier != null) {
      _supplierCodeController.text = supplier.supplierCode;
      _nameController.text = supplier.name;
      _contactPersonController.text = supplier.contactPerson ?? '';
      _phoneController.text = supplier.phone ?? '';
      _emailController.text = supplier.email ?? '';
      _addressController.text = supplier.address ?? '';
      _taxNumberController.text = supplier.taxNumber ?? '';
      _paymentTermsController.text = supplier.paymentTerms ?? '';

      _isActive = supplier.isActive;
    }
  }

  @override
  void dispose() {
    _supplierCodeController.dispose();
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    _paymentTermsController.dispose();

    super.dispose();
  }

  Map<String, dynamic> _buildRequest() {
    return {
      'supplierCode': _supplierCodeController.text.trim(),
      'name': _nameController.text.trim(),
      'contactPerson': _contactPersonController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'taxNumber': _taxNumberController.text.trim(),
      'paymentTerms': _paymentTermsController.text.trim(),
      'isActive': _isActive,
    };
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = _buildRequest();

    if (isEditMode) {
      context.read<SupplierBloc>().add(
        SupplierUpdateRequested(widget.supplier!.id, data),
      );
    } else {
      context.read<SupplierBloc>().add(SupplierCreateRequested(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Supplier' : 'Add Supplier'),
      ),
      body: BlocListener<SupplierBloc, SupplierState>(
        listener: (context, state) {
          if (state is SupplierOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            Navigator.pop(context);
          }

          if (state is SupplierError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Supplier Information'),

                    const SizedBox(height: 16),

                    _buildResponsiveFields([
                      _buildTextField(
                        controller: _supplierCodeController,
                        label: 'Supplier Code',
                        hint: 'Enter supplier code',
                        icon: Icons.tag,
                        required: true,
                      ),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Supplier Name',
                        hint: 'Enter supplier name',
                        icon: Icons.business,
                        required: true,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    _buildResponsiveFields([
                      _buildTextField(
                        controller: _contactPersonController,
                        label: 'Contact Person',
                        hint: 'Enter contact person',
                        icon: Icons.person_outline,
                      ),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        hint: 'Enter phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    _buildResponsiveFields([
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _taxNumberController,
                        label: 'Tax Number',
                        hint: 'Enter tax number',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter supplier address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _paymentTermsController,
                      label: 'Payment Terms',
                      hint: 'Example: 30 Days',
                      icon: Icons.payments_outlined,
                    ),

                    const SizedBox(height: 16),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active Supplier'),
                      subtitle: Text(
                        _isActive
                            ? 'Supplier is active'
                            : 'Supplier is inactive',
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    BlocBuilder<SupplierBloc, SupplierState>(
                      builder: (context, state) {
                        final isSaving = state is SupplierCreating;

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
                                    ? 'Update Supplier'
                                    : 'Save Supplier',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildResponsiveFields(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                fields[i],
                if (i < fields.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < fields.length; i++) ...[
              Expanded(child: fields[i]),
              if (i < fields.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator:
          validator ??
          (value) {
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
