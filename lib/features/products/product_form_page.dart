import 'package:flutter/material.dart';
import 'package:inventory_application/blocs/product/product_state.dart';

import '../../core/utils/responsive.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../../models/product_request.dart';
import '../../models/unit_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_model.dart';

import '../../blocs/product_form/product_form_bloc.dart';
import '../../blocs/product_form/product_form_event.dart';
import '../../blocs/product_form/product_form_state.dart';

import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';

class ProductFormPage extends StatefulWidget {
  final CategoryModel? initialCategory;
  final BrandModel? initialBrand;
  final UnitModel? initialUnit;
  final ProductModel? product;

  const ProductFormPage({
    super.key,
    this.initialCategory,
    this.initialBrand,
    this.initialUnit,
    this.product,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _productCodeController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _taxPercentController = TextEditingController();
  final _minimumStockController = TextEditingController();

  CategoryModel? _selectedCategory;
  BrandModel? _selectedBrand;
  UnitModel? _selectedUnit;

  bool _hasBatch = false;
  bool _hasExpiry = false;
  bool get isEditMode => widget.product != null;
  bool _dropdownsInitialized = false;

  // @override
  // void initState() {
  //   super.initState();

  //   _selectedCategory = widget.initialCategory;
  //   _selectedBrand = widget.initialBrand;
  //   _selectedUnit = widget.initialUnit;
  // }

  void _setInitialDropdownValues(ProductFormLoaded state) {
    if (_dropdownsInitialized) return;

    if (!isEditMode) {
      _selectedCategory = widget.initialCategory;
      _selectedBrand = widget.initialBrand;
      _selectedUnit = widget.initialUnit;
    } else {
      final product = widget.product!;

      _selectedCategory = state.categories
          .where((category) => category.id == product.categoryId)
          .firstOrNull;

      _selectedBrand = state.brands
          .where((brand) => brand.id == product.brandId)
          .firstOrNull;

      _selectedUnit = state.units
          .where((unit) => unit.id == product.unitId)
          .firstOrNull;
    }

    _dropdownsInitialized = true;
  }

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    if (product != null) {
      _productCodeController.text = product.productCode;
      _barcodeController.text = product.barcode ?? '';
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _purchasePriceController.text = product.purchasePrice.toString();
      _sellingPriceController.text = product.sellingPrice.toString();
      _taxPercentController.text = product.taxPercent.toString();
      _minimumStockController.text = product.minimumStock.toString();

      // _selectedCategory = product.categoryId;
      // _selectedBrand = product.brandId;
      // _selectedUnit = product.unitId;

      // _selectedCategory = widget.initialCategory;
      // _selectedBrand = widget.initialBrand;
      // _selectedUnit = widget.initialUnit;

      _hasBatch = product.hasBatch;
      _hasExpiry = product.hasExpiry;
    }
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _barcodeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _taxPercentController.dispose();
    _minimumStockController.dispose();

    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    if (num.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  ProductRequest _buildRequest() {
    return ProductRequest(
      categoryId: _selectedCategory?.id,
      brandId: _selectedBrand?.id,
      unitId: _selectedUnit!.id,
      productCode: _productCodeController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      purchasePrice: num.parse(_purchasePriceController.text.trim()),
      sellingPrice: num.parse(_sellingPriceController.text.trim()),
      taxPercent: num.parse(_taxPercentController.text.trim()),
      minimumStock: num.parse(_minimumStockController.text.trim()),
      hasBatch: _hasBatch,
      hasExpiry: _hasExpiry,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnit == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a unit.')));
      return;
    }

    final request = _buildRequest();

    if (isEditMode) {
      context.read<ProductBloc>().add(
        ProductUpdateRequested(id: widget.product!.id, request: request),
      );
    } else {
      context.read<ProductBloc>().add(ProductCreateRequested(request));
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _decoration(label),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<CategoryModel> categories,
    List<BrandModel> brands,
    List<UnitModel> units,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 700;

              if (!twoColumns) {
                return Column(
                  children: [
                    _buildTextField(
                      controller: _productCodeController,
                      label: 'Product Code',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _barcodeController,
                      label: 'Barcode',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Product Name',
                      validator: _requiredValidator,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _productCodeController,
                      label: 'Product Code',
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _barcodeController,
                      label: 'Barcode',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _nameController,
                      label: 'Product Name',
                      validator: _requiredValidator,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          Text('Classification', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Dropdowns will be connected to APIs next.
          DropdownButtonFormField<CategoryModel>(
            initialValue: _selectedCategory,
            decoration: _decoration('Category'),
            items: categories.map((category) {
              return DropdownMenuItem<CategoryModel>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<BrandModel>(
            initialValue: _selectedBrand,
            decoration: _decoration('Brand'),
            items: brands.map((brand) {
              return DropdownMenuItem<BrandModel>(
                value: brand,
                child: Text(brand.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBrand = value;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<UnitModel>(
            initialValue: _selectedUnit,
            decoration: _decoration('Unit'),
            validator: (value) {
              if (value == null) {
                return 'Please select a unit';
              }

              return null;
            },
            items: units.map((unit) {
              return DropdownMenuItem<UnitModel>(
                value: unit,
                child: Text(
                  unit.shortName != null && unit.shortName!.isNotEmpty
                      ? '${unit.name} (${unit.shortName})'
                      : unit.name,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUnit = value;
              });
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Pricing & Stock',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 700;

              if (!twoColumns) {
                return Column(
                  children: [
                    _buildTextField(
                      controller: _purchasePriceController,
                      label: 'Purchase Price',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _sellingPriceController,
                      label: 'Selling Price',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _taxPercentController,
                      label: 'Tax %',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _minimumStockController,
                      label: 'Minimum Stock',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _purchasePriceController,
                      label: 'Purchase Price',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _sellingPriceController,
                      label: 'Selling Price',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _taxPercentController,
                      label: 'Tax %',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _minimumStockController,
                      label: 'Minimum Stock',
                      validator: _numberValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Product Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Has Batch'),
            value: _hasBatch,
            onChanged: (value) {
              setState(() {
                _hasBatch = value;
              });
            },
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Has Expiry'),
            value: _hasExpiry,
            onChanged: (value) {
              setState(() {
                _hasExpiry = value;
              });
            },
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, productState) {
                  final isSaving = productState is ProductCreating;

                  return ElevatedButton.icon(
                    onPressed: isSaving ? null : _submit,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isSaving
                          ? (isEditMode ? 'Updating...' : 'Saving...')
                          : (isEditMode ? 'Update Product' : 'Save Product'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductOperationSuccess) {
          Navigator.pop(context, true);
        }

        if (state is ProductError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<ProductFormBloc, ProductFormState>(
        builder: (context, state) {
          if (state is ProductFormLoading || state is ProductFormInitial) {
            return Scaffold(
              appBar: AppBar(
                title: Text(isEditMode ? 'Edit Product' : 'Add Product'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProductFormError) {
            return Scaffold(
              appBar: AppBar(
                title: Text(isEditMode ? 'Edit Product' : 'Add Product'),
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductFormBloc>().add(
                          ProductFormLoadRequested(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProductFormLoaded) {
            _setInitialDropdownValues(state);
            if (isEditMode &&
                _selectedCategory == null &&
                _selectedBrand == null &&
                _selectedUnit == null) {
              final product = widget.product!;

              _selectedCategory = product.categoryId == null
                  ? null
                  : state.categories.cast<CategoryModel?>().firstWhere(
                      (category) => category?.id == product.categoryId,
                      orElse: () => null,
                    );

              _selectedBrand = product.brandId == null
                  ? null
                  : state.brands.cast<BrandModel?>().firstWhere(
                      (brand) => brand?.id == product.brandId,
                      orElse: () => null,
                    );

              _selectedUnit = product.unitId == null
                  ? null
                  : state.units.cast<UnitModel?>().firstWhere(
                      (unit) => unit?.id == product.unitId,
                      orElse: () => null,
                    );
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(isEditMode ? 'Edit Product' : 'Add Product'),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    Responsive.isMobile(context) ? 16 : 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: _buildForm(
                        context,
                        state.categories,
                        state.brands,
                        state.units,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
