import 'package:equatable/equatable.dart';

import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../../models/unit_model.dart';

abstract class ProductFormState extends Equatable {
  const ProductFormState();

  @override
  List<Object?> get props => [];
}

class ProductFormInitial extends ProductFormState {}

class ProductFormLoading extends ProductFormState {}

class ProductFormLoaded extends ProductFormState {
  final List<CategoryModel> categories;
  final List<BrandModel> brands;
  final List<UnitModel> units;

  const ProductFormLoaded({
    required this.categories,
    required this.brands,
    required this.units,
  });

  @override
  List<Object?> get props => [categories, brands, units];
}

class ProductFormError extends ProductFormState {
  final String message;

  const ProductFormError(this.message);

  @override
  List<Object?> get props => [message];
}
