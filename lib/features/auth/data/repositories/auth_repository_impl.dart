import 'package:newsapp/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:newsapp/features/auth/data/models/user_model.dart';
import 'package:newsapp/features/auth/domain/entities/user_entity.dart';
import 'package:newsapp/features/auth/domain/repositories/auth_repository.dart';

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

  @override
  UserEntity? get currentUser {
    final user = remoteDataSource.getCurrentUser();
    if (user == null) return null;

    return UserModel.fromSupabaseUser(user.id, user.email ?? '');
  }
}
