import 'package:dio/dio.dart';
import 'package:flutter_application_api/features/anime/domain/repositories/anime_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/anime/data/datasources/anime_remote_data_source.dart';
import '../../features/anime/data/repositories/anime_repository_impl.dart';
import '../../features/anime/domain/usecases/fetch_top_anime.dart';
import '../../features/auth/auth_module.dart';
import '../../features/url_launcher/url_launcher_module.dart';

typedef _FactoryFunc<T extends Object> = T Function();

/// Lightweight service locator to centralize dependency wiring.
class AppLocator {
  AppLocator._();

  static final AppLocator I = AppLocator._();

  final Map<Type, dynamic> _singletons = {};
  final Map<Type, _FactoryFunc<dynamic>> _factories = {};

  void registerSingleton<T extends Object>(T instance) {
    if (isRegistered<T>()) {
      throw StateError('Type $T already registered');
    }
    _singletons[T] = instance;
  }

  void registerFactory<T extends Object>(_FactoryFunc<T> creator) {
    if (isRegistered<T>()) {
      throw StateError('Type $T already registered');
    }
    _factories[T] = creator;
  }

  T get<T extends Object>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    final factory = _factories[T];
    if (factory != null) {
      return factory() as T;
    }
    throw StateError('No dependency registered for type $T');
  }

  bool isRegistered<T extends Object>() =>
      _singletons.containsKey(T) || _factories.containsKey(T);
}

/// Register application-wide dependencies and feature modules.
Future<void> configureDependencies({
  required SharedPreferences preferences,
}) async {
  final locator = AppLocator.I;
  final dio = Dio();
  locator
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<AnimeRemoteDataSource>(AnimeRemoteDataSourceImpl(dio))
    ..registerSingleton<AnimeRepository>(
      AnimeRepositoryImpl(locator.get<AnimeRemoteDataSource>()),
    )
    ..registerSingleton<FetchTopAnimeUseCase>(
      FetchTopAnimeUseCase(locator.get<AnimeRepository>()),
    );

  registerAuthModule(locator);
  registerUrlLauncherModule(locator);
}
