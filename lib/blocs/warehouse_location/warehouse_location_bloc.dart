import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/warehouse_location_service.dart';
import 'warehouse_location_event.dart';
import 'warehouse_location_state.dart';

class WarehouseLocationBloc
    extends Bloc<WarehouseLocationEvent, WarehouseLocationState> {
  final WarehouseLocationService warehouseLocationService;
  final AuthStorage authStorage;

  WarehouseLocationBloc({
    required this.warehouseLocationService,
    required this.authStorage,
  }) : super(WarehouseLocationInitial()) {
    on<WarehouseLocationLoadRequested>(_loadLocations);

    on<WarehouseLocationRefreshRequested>(_loadLocations);

    on<WarehouseLocationCreateRequested>(_createLocation);

    on<WarehouseLocationUpdateRequested>(_updateLocation);

    on<WarehouseLocationDeleteRequested>(_deleteLocation);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadLocations(
    WarehouseLocationEvent event,
    Emitter<WarehouseLocationState> emit,
  ) async {
    emit(WarehouseLocationLoading());

    try {
      final token = await _getToken();

      final locations = await warehouseLocationService.getWarehouseLocations(
        token: token,
      );

      emit(WarehouseLocationLoaded(locations));
    } catch (e) {
      emit(
        WarehouseLocationError(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _createLocation(
    WarehouseLocationCreateRequested event,
    Emitter<WarehouseLocationState> emit,
  ) async {
    try {
      final token = await _getToken();

      await warehouseLocationService.createWarehouseLocation(
        body: event.data,
        token: token,
      );

      emit(
        const WarehouseLocationOperationSuccess(
          'Warehouse location created successfully.',
        ),
      );

      add(WarehouseLocationLoadRequested());
    } catch (e) {
      emit(
        WarehouseLocationError(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _updateLocation(
    WarehouseLocationUpdateRequested event,
    Emitter<WarehouseLocationState> emit,
  ) async {
    try {
      final token = await _getToken();

      await warehouseLocationService.updateWarehouseLocation(
        id: event.id,
        body: event.data,
        token: token,
      );

      emit(
        const WarehouseLocationOperationSuccess(
          'Warehouse location updated successfully.',
        ),
      );

      add(WarehouseLocationLoadRequested());
    } catch (e) {
      emit(
        WarehouseLocationError(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _deleteLocation(
    WarehouseLocationDeleteRequested event,
    Emitter<WarehouseLocationState> emit,
  ) async {
    try {
      final token = await _getToken();

      await warehouseLocationService.deleteWarehouseLocation(
        id: event.id,
        token: token,
      );

      emit(
        const WarehouseLocationOperationSuccess(
          'Warehouse location deleted successfully.',
        ),
      );

      add(WarehouseLocationLoadRequested());
    } catch (e) {
      emit(
        WarehouseLocationError(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }
}
