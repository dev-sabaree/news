import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('User not found');
    }

    return UserModel.fromSupabaseUser(user.id, user.email ?? '');
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
  
    await remoteDataSource.signUp(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {


    await remoteDataSource.logout();
  }

  @override
  bool get isLoggedIn => remoteDataSource.getCurrentSession() != null;
}
