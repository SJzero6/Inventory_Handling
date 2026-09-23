import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/brand_service.dart';
import '../../services/category_service.dart';
import '../../services/unit_service.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../../models/unit_model.dart';

import 'product_form_event.dart';
import 'product_form_state.dart';

class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  final CategoryService categoryService;
  final BrandService brandService;
  final UnitService unitService;
  final AuthStorage authStorage;

  ProductFormBloc({
    required this.categoryService,
    required this.brandService,
    required this.unitService,
    required this.authStorage,
  }) : super(ProductFormInitial()) {
    on<ProductFormLoadRequested>(_loadData);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadData(
    ProductFormLoadRequested event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormLoading());

    try {
      final token = await _getToken();

      final results = await Future.wait([
        categoryService.getCategories(token: token),
        brandService.getBrands(token: token),
        unitService.getUnits(token: token),
      ]);

      emit(
        ProductFormLoaded(
          categories: results[0] as List<CategoryModel>,
          brands: results[1] as List<BrandModel>,
          units: results[2] as List<UnitModel>,
        ),
      );
    } catch (e) {
      emit(ProductFormError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
