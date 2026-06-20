import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/features/auth/domain/entities/user_entity.dart';
import 'package:newsapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_error_mapper.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password,
      );
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(AuthErrorMapper.getErrorCode(e)));
    }
  }
}
