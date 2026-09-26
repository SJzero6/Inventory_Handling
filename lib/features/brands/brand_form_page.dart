import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/brand/brand_bloc.dart';
import '../../blocs/brand/brand_event.dart';
import '../../blocs/brand/brand_state.dart';
import '../../models/brand_model.dart';

class BrandFormPage extends StatefulWidget {
  final BrandModel? brand;

  const BrandFormPage({super.key, this.brand});

  @override
  State<BrandFormPage> createState() => _BrandFormPageState();
}

class _BrandFormPageState extends State<BrandFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  bool get isEditMode => widget.brand != null;

  @override
  void initState() {
    super.initState();

    if (widget.brand != null) {
      _nameController.text = widget.brand!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();

    if (isEditMode) {
      context.read<BrandBloc>().add(
        BrandUpdateRequested(id: widget.brand!.id, name: name),
      );
    } else {
      context.read<BrandBloc>().add(BrandCreateRequested(name: name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrandBloc, BrandState>(
      listener: (context, state) {
        if (state is BrandOperationSuccess) {
          Navigator.pop(context, true);
        }

        if (state is BrandError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(isEditMode ? 'Edit Brand' : 'Add Brand')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Brand Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Brand name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),

                          const SizedBox(width: 12),

                          ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.save),
                            label: Text(
                              isEditMode ? 'Update Brand' : 'Save Brand',
                            ),
                          ),
                        ],
                      ),
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
}
