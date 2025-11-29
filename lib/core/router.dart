import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/popular_page.dart';
import '../pages/favorite/favorite_page.dart';
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
import '../pages/pengembang_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routerNeglect: false,

    routes: [
      // -----------------------------------------
      // AUTH & ROOT
      // -----------------------------------------
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // -----------------------------------------
      // MAIN PAGES
      // -----------------------------------------
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/popular', builder: (_, __) => const PopularPage()),
      GoRoute(path: '/favorite', builder: (_, __) => const FavoritePage()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),

      // -----------------------------------------
      // SETTINGS
      // -----------------------------------------
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsPage(),
        routes: [
          GoRoute(path: 'about', builder: (_, __) => const AboutPage()),
          GoRoute(path: 'help', builder: (_, __) => const HelpPage()),
          GoRoute(
            path: 'device-info',
            builder: (_, __) => const DeviceInfoPage(),
          ),
          GoRoute(path: 'pengembang', builder: (_, __) => PengembangPage()),
        ],
      ),

      // -----------------------------------------
      // RANDOM ANIME
      // -----------------------------------------
      GoRoute(path: '/random', builder: (_, __) => const RandomAnimePage()),

      // -----------------------------------------
      // DETAIL ROUTES
      // -----------------------------------------

      // A. Navigasi menggunakan extra → /detail
      // dipakai saat klik card di dashboard atau popular
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

      // B. Navigasi dengan ID → /detail/:id
      // dipakai untuk favorit, history, atau share link
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

      // -----------------------------------------
      // WEBVIEW
      // -----------------------------------------
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
