import 'package:newsapp/features/auth/domain/repositories/auth_repository.dart';

class IsLoggedInUseCase {
  final AuthRepository repository;

  const IsLoggedInUseCase(this.repository);

  bool call() {
    return repository.isLoggedIn;
  }
}
