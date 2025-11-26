import 'package:url_launcher_module/url_launcher_module.dart';
import '../../core/di/app_locator.dart';

void registerUrlLauncherModule(AppLocator locator) {
  locator
    ..registerSingleton<UrlLauncherRepository>(UrlLauncherRepositoryImpl())
    ..registerSingleton<OpenUrlUseCase>(
      OpenUrlUseCase(locator.get<UrlLauncherRepository>()),
    );
}
