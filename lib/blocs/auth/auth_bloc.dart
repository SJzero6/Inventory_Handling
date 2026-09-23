import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final AuthStorage authStorage;

  AuthBloc({required this.authService, required this.authStorage})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await authService.login(
        username: event.username,
        password: event.password,
      );

      await authStorage.saveSession(
        token: result.token,
        rememberMe: event.rememberMe,
      );

      emit(AuthAuthenticated(result));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authStorage.clearSession();

    emit(AuthUnauthenticated());
  }
}
