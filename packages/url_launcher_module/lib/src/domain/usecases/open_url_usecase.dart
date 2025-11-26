import '../repositories/url_launcher_repository.dart';

class OpenUrlUseCase {
  OpenUrlUseCase(this._repository);

  final UrlLauncherRepository _repository;

  Future<bool> call(String url) {
    return _repository.open(url);
  }
}
