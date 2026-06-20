import 'package:newsapp/features/auth/domain/entities/user_entity.dart';
import 'package:newsapp/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  UserEntity? call() {
    return repository.currentUser;
  }
}
