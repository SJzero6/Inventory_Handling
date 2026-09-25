import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/brand_service.dart';
import 'brand_event.dart';
import 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  final BrandService brandService;
  final AuthStorage authStorage;

  BrandBloc({required this.brandService, required this.authStorage})
    : super(BrandInitial()) {
    on<BrandLoadRequested>(_loadBrands);
    on<BrandRefreshRequested>(_loadBrands);
    on<BrandCreateRequested>(_createBrand);
    on<BrandUpdateRequested>(_updateBrand);
    on<BrandDeleteRequested>(_deleteBrand);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadBrands(BrandEvent event, Emitter<BrandState> emit) async {
    emit(BrandLoading());

    try {
      final token = await _getToken();

      final brands = await brandService.getBrands(token: token);

      emit(BrandLoaded(brands));
    } catch (e) {
      emit(BrandError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _createBrand(
    BrandCreateRequested event,
    Emitter<BrandState> emit,
  ) async {
    try {
      final token = await _getToken();

      await brandService.createBrand(name: event.name, token: token);

      emit(const BrandOperationSuccess('Brand created successfully.'));

      add(BrandLoadRequested());
    } catch (e) {
      emit(BrandError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _updateBrand(
    BrandUpdateRequested event,
    Emitter<BrandState> emit,
  ) async {
    try {
      final token = await _getToken();

      await brandService.updateBrand(
        id: event.id,
        name: event.name,
        token: token,
      );

      emit(const BrandOperationSuccess('Brand updated successfully.'));

      add(BrandLoadRequested());
    } catch (e) {
      emit(BrandError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _deleteBrand(
    BrandDeleteRequested event,
    Emitter<BrandState> emit,
  ) async {
    try {
      final token = await _getToken();

      await brandService.deleteBrand(id: event.id, token: token);

      emit(const BrandOperationSuccess('Brand deleted successfully.'));

      add(BrandLoadRequested());
    } catch (e) {
      emit(BrandError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
