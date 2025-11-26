import 'package:auth_module/auth_module.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/app_locator.dart';
import '../../cubit/auth_cubit.dart';

void registerAuthModule(AppLocator locator) {
  if (!locator.isRegistered<SharedPreferences>()) {
    throw StateError('SharedPreferences must be registered before auth module.');
  }

  locator
    ..registerSingleton<AuthRepository>(
      FirebaseAuthRepository(preferences: locator.get<SharedPreferences>()),
    )
    ..registerSingleton<LoginUseCase>(
      LoginUseCase(locator.get<AuthRepository>()),
    )
    ..registerSingleton<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(locator.get<AuthRepository>()),
    )
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        locator.get<LoginUseCase>(),
        locator.get<GetCurrentUserUseCase>(),
      ),
    );
}
