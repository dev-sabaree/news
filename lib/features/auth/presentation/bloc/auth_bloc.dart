import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:newsapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:newsapp/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:newsapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogoutUseCase logoutUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final supabase.SupabaseClient supabaseClient;

  late final StreamSubscription<supabase.AuthState> _authStateSubscription;

  AuthBloc({
    required this.logoutUseCase,
    required this.isLoggedInUseCase,
    required this.getCurrentUserUseCase,
    required this.supabaseClient,
  }) : super(AuthInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckSessionRequested>(_onCheckSessionRequested);

    _authStateSubscription = supabaseClient.auth.onAuthStateChange.listen((
      data,
    ) {
      // The splash screen performs the initial session check.
      // Ignore Supabase's initial session event here so it
      // does not navigate away from the splash immediately.
      if (data.event == supabase.AuthChangeEvent.initialSession) {
        return;
      }

      add(CheckSessionRequested());
    });
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (_) {
      // Only change the UI when Supabase confirms that no session remains.
      if (supabaseClient.auth.currentSession == null) {
        emit(AuthUnauthenticated());
      }
    }
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

  @override
  Future<void> close() async {
    await _authStateSubscription.cancel();
    return super.close();
  }
}
