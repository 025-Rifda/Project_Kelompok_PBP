import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/sidebar.dart';
import 'bloc/anime_bloc.dart';
import 'bloc/anime_event.dart';
import 'cubit/anime_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  usePathUrlStrategy();
  runApp(AplikasiAnime(prefs: prefs));
}

class AplikasiAnime extends StatelessWidget {
  const AplikasiAnime({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<Dio>(create: (context) => Dio()),
            RepositoryProvider<AuthRepository>(
              create: (_) => AuthRepository(preferences: prefs),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
              BlocProvider<AnimeBloc>(
                create: (context) => AnimeBloc(context.read<Dio>())
                  ..add(FetchTopAnimeEvent())
                  ..add(const LoadFavoritesEvent()),
              ),
              BlocProvider<AnimeCubit>(
                create: (context) => AnimeCubit(context.read<Dio>()),
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
