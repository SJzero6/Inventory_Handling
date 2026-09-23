import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/dashboard_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService dashboardService;
  final AuthStorage authStorage;

  DashboardBloc({required this.dashboardService, required this.authStorage})
    : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadDashboard);
    on<DashboardRefreshRequested>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final token = await authStorage.getToken();

      if (token == null || token.isEmpty) {
        emit(const DashboardError('Authentication token not found.'));
        return;
      }

      final dashboard = await dashboardService.getDashboard(token);

      emit(DashboardLoaded(dashboard));
    } catch (e) {
      emit(DashboardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
