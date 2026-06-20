import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/features/auth/domain/usecases/signup_usecase.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_error_mapper.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpUseCase signUpUseCase;

  SignUpBloc({required this.signUpUseCase}) : super(SignUpInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());
    try {
      await signUpUseCase(
        fullName: event.fullName,
        phone: event.phone,
        email: event.email,
        password: event.password,
      );
      emit(const SignUpSuccess('signup_success'));
    } catch (e) {
      emit(SignUpFailure(AuthErrorMapper.getErrorCode(e)));
    }
  }
}
