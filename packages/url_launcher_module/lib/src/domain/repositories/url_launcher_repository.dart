/// Abstraction boundary for launching external URLs.
abstract class UrlLauncherRepository {
  Future<bool> open(String url);
}
