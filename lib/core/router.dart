import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/popular_page.dart';
import '../pages/favorite_page.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/profile_page.dart';
import '../pages/about_page.dart';
import '../pages/help_page.dart';
import '../pages/device_info_page.dart';
import '../pages/detail_page.dart';
import '../pages/random_anime_page.dart';
import '../pages/webview_page.dart';
import '../pages/detail_loader_page.dart';
import '../models/anime_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routerNeglect: false,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/popular',
        builder: (context, state) => const PopularPage(),
      ),
      GoRoute(
        path: '/favorite',
        builder: (context, state) => const FavoritePage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(path: 'help', builder: (context, state) => const HelpPage()),
          GoRoute(
            path: 'device-info',
            builder: (context, state) => const DeviceInfoPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/random',
        builder: (context, state) => const RandomAnimePage(),
      ),
      // Compatible route when navigating with extra payload
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final extra = state.extra;
          Anime? anime;
          if (extra is Anime) {
            anime = extra;
          } else if (extra is Map<String, dynamic>) {
            anime = Anime.fromJson(extra);
          }
          if (anime == null) {
            return const Scaffold(
              body: Center(child: Text('Anime data not found')),
            );
          }
          return DetailPage(anime: anime);
        },
      ),
      // New sharable route: /detail/:id
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid anime ID')),
            );
          }
          return DetailLoaderPage(id: id);
        },
      ),
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final url = state.extra as String?;
          return WebViewPage(url: url ?? 'https://myanimelist.net/');
        },
      ),
    ],
  );
}
