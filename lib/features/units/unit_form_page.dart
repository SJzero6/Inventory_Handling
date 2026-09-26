import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/unit/unit_bloc.dart';
import '../../blocs/unit/unit_event.dart';
import '../../blocs/unit/unit_state.dart';
import '../../models/unit_model.dart';

class UnitFormPage extends StatefulWidget {
  final UnitModel? unit;

  const UnitFormPage({super.key, this.unit});

  @override
  State<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();

  bool get isEditMode => widget.unit != null;

  @override
  void initState() {
    super.initState();

    if (widget.unit != null) {
      _nameController.text = widget.unit!.name;
      _shortNameController.text = widget.unit!.shortName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final shortName = _shortNameController.text.trim();

    if (isEditMode) {
      context.read<UnitBloc>().add(
        UnitUpdateRequested(
          id: widget.unit!.id,
          name: name,
          shortName: shortName,
        ),
      );
    } else {
      context.read<UnitBloc>().add(
        UnitCreateRequested(name: name, shortName: shortName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state is UnitOperationSuccess) {
          Navigator.pop(context, true);
        }

        if (state is UnitError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(isEditMode ? 'Edit Unit' : 'Add Unit')),
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
                        labelText: 'Unit Name',
                        hintText: 'Example: Kilogram',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Unit name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _shortNameController,
                      decoration: const InputDecoration(
                        labelText: 'Short Name',
                        hintText: 'Example: kg',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Short name is required';
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
                              isEditMode ? 'Update Unit' : 'Save Unit',
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
