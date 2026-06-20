import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:newsapp/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:newsapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogoutUseCase logoutUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.logoutUseCase,
    required this.isLoggedInUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckSessionRequested>(_onCheckSessionRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await logoutUseCase();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckSessionRequested(
    CheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!isLoggedInUseCase()) {
      emit(AuthUnauthenticated());
      return;
    }

    final user = getCurrentUserUseCase();
    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(user));
  }
}
