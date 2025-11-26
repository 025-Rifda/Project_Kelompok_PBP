import 'package:url_launcher/url_launcher.dart';
import '../domain/repositories/url_launcher_repository.dart';

/// `url_launcher`-backed implementation for opening links.
class UrlLauncherRepositoryImpl implements UrlLauncherRepository {
  @override
  Future<bool> open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
      return true;
    }
    return false;
  }
}
