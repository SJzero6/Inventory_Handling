import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_application/services/product_service.dart';

import '../../core/storage/auth_storage.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService;
  final AuthStorage authStorage;

  ProductBloc({required this.productService, required this.authStorage})
    : super(ProductInitial()) {
    on<ProductLoadRequested>(_loadProducts);
    on<ProductRefreshRequested>(_loadProducts);

    on<ProductCreateRequested>(_createProduct);
    on<ProductUpdateRequested>(_updateProduct);
    on<ProductDeleteRequested>(_deleteProduct);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadProducts(
    ProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final token = await _getToken();

      final products = await productService.getProducts(token: token);

      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _createProduct(
    ProductCreateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductCreating());

    try {
      final token = await _getToken();

      await productService.createProduct(request: event.request, token: token);

      emit(const ProductOperationSuccess('Product created successfully.'));
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _updateProduct(
    ProductUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final token = await _getToken();

      await productService.updateProduct(
        id: event.id,
        request: event.request,
        token: token,
      );

      emit(const ProductOperationSuccess('Product updated successfully.'));

      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _deleteProduct(
    ProductDeleteRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final token = await _getToken();

      await productService.deleteProduct(id: event.id, token: token);

      emit(const ProductOperationSuccess('Product deleted successfully.'));

      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
