import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sizer/sizer.dart';
import 'widgets/sidebar.dart';
import 'bloc/anime_bloc.dart';
import 'bloc/anime_event.dart';
import 'cubit/anime_cubit.dart';

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
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            RepositoryProvider<Dio>(create: (context) => Dio()),
            BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
            BlocProvider<AnimeBloc>(
              create: (context) =>
                  AnimeBloc(context.read<Dio>())..add(FetchTopAnimeEvent()),
            ),
            BlocProvider<AnimeCubit>(
              create: (context) => AnimeCubit(context.read<Dio>()),
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
      },
    );
  }
}
