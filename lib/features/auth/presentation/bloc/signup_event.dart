part of 'signup_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpRequested extends SignUpEvent {
  final String fullName;
  final String phone;
  final String email;
  final String password;

  const SignUpRequested({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, phone, email, password];
}
