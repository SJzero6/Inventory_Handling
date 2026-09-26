import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/warehouse_service.dart';
import 'warehouse_event.dart';
import 'warehouse_state.dart';

class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  final WarehouseService warehouseService;
  final AuthStorage authStorage;

  WarehouseBloc({required this.warehouseService, required this.authStorage})
    : super(WarehouseInitial()) {
    on<WarehouseLoadRequested>(_loadWarehouses);
    on<WarehouseRefreshRequested>(_loadWarehouses);
    on<WarehouseCreateRequested>(_createWarehouse);
    on<WarehouseUpdateRequested>(_updateWarehouse);
    on<WarehouseDeleteRequested>(_deleteWarehouse);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadWarehouses(
    WarehouseEvent event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(WarehouseLoading());

    try {
      final token = await _getToken();

      final warehouses = await warehouseService.getWarehouses(token: token);

      emit(WarehouseLoaded(warehouses));
    } catch (e) {
      emit(WarehouseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _createWarehouse(
    WarehouseCreateRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      final token = await _getToken();

      await warehouseService.createWarehouse(body: event.data, token: token);

      emit(const WarehouseOperationSuccess('Warehouse created successfully.'));

      add(WarehouseLoadRequested());
    } catch (e) {
      emit(WarehouseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _updateWarehouse(
    WarehouseUpdateRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      final token = await _getToken();

      await warehouseService.updateWarehouse(
        id: event.id,
        body: event.data,
        token: token,
      );

      emit(const WarehouseOperationSuccess('Warehouse updated successfully.'));

      add(WarehouseLoadRequested());
    } catch (e) {
      emit(WarehouseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _deleteWarehouse(
    WarehouseDeleteRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      final token = await _getToken();

      await warehouseService.deleteWarehouse(id: event.id, token: token);

      emit(const WarehouseOperationSuccess('Warehouse deleted successfully.'));

      add(WarehouseLoadRequested());
    } catch (e) {
      emit(WarehouseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
