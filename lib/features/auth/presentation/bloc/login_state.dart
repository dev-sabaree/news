part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final String errorCode;

  const LoginFailure(this.errorCode);

  @override
  List<Object?> get props => [errorCode];
}
