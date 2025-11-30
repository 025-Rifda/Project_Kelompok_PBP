import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/sidebar.dart';
import 'features/anime/domain/repositories/anime_repository.dart';
import 'features/anime/domain/usecases/fetch_top_anime.dart';
import 'bloc/anime_bloc.dart';
import 'bloc/anime_event.dart';
import 'cubit/anime_cubit.dart';
import 'cubit/auth_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:auth_module/auth_module.dart';
import 'package:url_launcher_module/url_launcher_module.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/di/app_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  await configureDependencies(preferences: prefs);
  usePathUrlStrategy();
  runApp(const AplikasiAnime());
}

class AplikasiAnime extends StatelessWidget {
  const AplikasiAnime({super.key});

  @override
  Widget build(BuildContext context) {
    final locator = AppLocator.I;
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<Dio>.value(value: locator.get<Dio>()),
            RepositoryProvider<AnimeRepository>.value(
              value: locator.get<AnimeRepository>(),
            ),
            RepositoryProvider<FetchTopAnimeUseCase>.value(
              value: locator.get<FetchTopAnimeUseCase>(),
            ),
            RepositoryProvider<AuthRepository>.value(
              value: locator.get<AuthRepository>(),
            ),
            RepositoryProvider<UrlLauncherRepository>.value(
              value: locator.get<UrlLauncherRepository>(),
            ),
            RepositoryProvider<OpenUrlUseCase>.value(
              value: locator.get<OpenUrlUseCase>(),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
              BlocProvider<AnimeBloc>(
                create: (context) => AnimeBloc(
                  context.read<Dio>(),
                  context.read<FetchTopAnimeUseCase>(),
                )
                  ..add(FetchTopAnimeEvent())
                  ..add(const LoadFavoritesEvent()),
              ),
              BlocProvider<AnimeCubit>(
                create: (context) => AnimeCubit(context.read<Dio>()),
              ),
              BlocProvider<AuthCubit>(
                create: (context) => locator.get<AuthCubit>(),
              ),
            ],
            child: BlocBuilder<ThemeCubit, bool>(
              builder: (context, isDark) {
                return MaterialApp.router(
                  title: 'Nekofeed',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  routerConfig: AppRouter.router,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
