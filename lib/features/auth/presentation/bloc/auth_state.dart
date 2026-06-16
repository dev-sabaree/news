import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthSuccess extends AuthState {
  final String messageKey; // 👈 key, not message
  const AuthSuccess(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

class AuthFailure extends AuthState {
  final String errorCode; // 👈 code, not message
  const AuthFailure(this.errorCode);

  @override
  List<Object?> get props => [errorCode];
}