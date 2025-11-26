import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  locator
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerSingleton<Dio>(Dio());

  registerAuthModule(locator);
  registerUrlLauncherModule(locator);
}
