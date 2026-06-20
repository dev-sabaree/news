import 'package:newsapp/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  });

  Future<void> logout();

  bool get isLoggedIn;

  UserEntity? get currentUser;
}
