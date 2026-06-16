import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckSessionRequested>(_onCheckSessionRequested);
  }

  // 👇 returns error CODE — not message
  String _getErrorCode(dynamic e) {
    final message = e.toString().toLowerCase();

    if (message.contains('invalid_credentials') ||
        message.contains('invalid login credentials')) {
      return 'invalid_credentials';
    }
    if (message.contains('email_not_confirmed')) {
      return 'email_not_confirmed';
    }
    if (message.contains('user_not_found')) {
      return 'user_not_found';
    }
    if (message.contains('too_many_requests') ||
        message.contains('rate limit')) {
      return 'too_many_requests';
    }
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'network_error';
    }
    if (message.contains('email_address_invalid') ||
        message.contains('invalid email')) {
      return 'invalid_email';
    }
    if (message.contains('weak_password') ||
        message.contains('password should be')) {
      return 'weak_password';
    }
    if (message.contains('email_exists') ||
        message.contains('user_already_exists') ||
        message.contains('already registered')) {
      return 'email_exists';
    }

    return 'unknown_error';
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthFailure(_getErrorCode(e))); // 👈 code emit
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signUp(
        fullName: event.fullName,
        phone: event.phone,
        email: event.email,
        password: event.password,
      );
      emit(const AuthSuccess('signup_success')); // 👈 key emit
    } catch (e) {
      emit(AuthFailure(_getErrorCode(e))); // 👈 code emit
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.logout();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckSessionRequested(
    CheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (authRepository.isLoggedIn) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }
}