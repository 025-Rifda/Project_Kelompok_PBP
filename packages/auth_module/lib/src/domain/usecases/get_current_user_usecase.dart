import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  AuthUser? call() => _repository.currentUser;
}
