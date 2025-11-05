import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'widgets/sidebar.dart';
import 'bloc/anime_bloc.dart';
import 'bloc/anime_event.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const AplikasiAnime());
}

class AplikasiAnime extends StatelessWidget {
  const AplikasiAnime({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<AnimeBloc>(
          create: (context) => AnimeBloc(Dio())..add(FetchTopAnimeEvent()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return MaterialApp.router(
            title: 'AnimeList+',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
