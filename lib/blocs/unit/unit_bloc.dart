import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/unit_service.dart';
import 'unit_event.dart';
import 'unit_state.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final UnitService unitService;
  final AuthStorage authStorage;

  UnitBloc({required this.unitService, required this.authStorage})
    : super(UnitInitial()) {
    on<UnitLoadRequested>(_loadUnits);
    on<UnitRefreshRequested>(_loadUnits);
    on<UnitCreateRequested>(_createUnit);
    on<UnitUpdateRequested>(_updateUnit);
    on<UnitDeleteRequested>(_deleteUnit);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadUnits(UnitEvent event, Emitter<UnitState> emit) async {
    emit(UnitLoading());

    try {
      final token = await _getToken();

      final units = await unitService.getUnits(token: token);

      emit(UnitLoaded(units));
    } catch (e) {
      emit(UnitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _createUnit(
    UnitCreateRequested event,
    Emitter<UnitState> emit,
  ) async {
    try {
      final token = await _getToken();

      await unitService.createUnit(
        name: event.name,
        shortName: event.shortName,
        token: token,
      );

      emit(const UnitOperationSuccess('Unit created successfully.'));

      add(UnitLoadRequested());
    } catch (e) {
      emit(UnitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _updateUnit(
    UnitUpdateRequested event,
    Emitter<UnitState> emit,
  ) async {
    try {
      final token = await _getToken();

      await unitService.updateUnit(
        id: event.id,
        name: event.name,
        shortName: event.shortName,
        token: token,
      );

      emit(const UnitOperationSuccess('Unit updated successfully.'));

      add(UnitLoadRequested());
    } catch (e) {
      emit(UnitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _deleteUnit(
    UnitDeleteRequested event,
    Emitter<UnitState> emit,
  ) async {
    try {
      final token = await _getToken();

      await unitService.deleteUnit(id: event.id, token: token);

      emit(const UnitOperationSuccess('Unit deleted successfully.'));

      add(UnitLoadRequested());
    } catch (e) {
      emit(UnitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
