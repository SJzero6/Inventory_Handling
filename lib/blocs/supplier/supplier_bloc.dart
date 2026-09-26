import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/supplier_service.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierService supplierService;
  final AuthStorage authStorage;

  SupplierBloc({required this.supplierService, required this.authStorage})
    : super(SupplierInitial()) {
    on<SupplierLoadRequested>(_loadSuppliers);
    on<SupplierRefreshRequested>(_loadSuppliers);
    on<SupplierCreateRequested>(_createSupplier);
    on<SupplierUpdateRequested>(_updateSupplier);
    on<SupplierDeleteRequested>(_deleteSupplier);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadSuppliers(
    SupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());

    try {
      final token = await _getToken();

      final suppliers = await supplierService.getSuppliers(token: token);

      emit(SupplierLoaded(suppliers));
    } catch (e) {
      emit(SupplierError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _createSupplier(
    SupplierCreateRequested event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      final token = await _getToken();

      await supplierService.createSupplier(body: event.data, token: token);

      emit(const SupplierOperationSuccess('Supplier created successfully.'));

      add(SupplierLoadRequested());
    } catch (e) {
      emit(SupplierError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _updateSupplier(
    SupplierUpdateRequested event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      final token = await _getToken();

      await supplierService.updateSupplier(
        id: event.id,
        body: event.data,
        token: token,
      );

      emit(const SupplierOperationSuccess('Supplier updated successfully.'));

      add(SupplierLoadRequested());
    } catch (e) {
      emit(SupplierError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _deleteSupplier(
    SupplierDeleteRequested event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      final token = await _getToken();

      await supplierService.deleteSupplier(id: event.id, token: token);

      emit(const SupplierOperationSuccess('Supplier deleted successfully.'));

      add(SupplierLoadRequested());
    } catch (e) {
      emit(SupplierError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
