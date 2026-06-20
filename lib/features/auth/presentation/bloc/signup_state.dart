part of 'signup_bloc.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String messageKey;

  const SignUpSuccess(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

class SignUpFailure extends SignUpState {
  final String errorCode;

  const SignUpFailure(this.errorCode);

  @override
  List<Object?> get props => [errorCode];
}
