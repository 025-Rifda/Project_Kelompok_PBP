import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/popular_page.dart';
import '../pages/favorite_page.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/detail_page.dart';
import '../models/anime_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routerNeglect: true,
    routes: [
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
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final anime = state.extra as Anime?;
          if (anime == null) {
            return const Scaffold(
              body: Center(child: Text('Anime data not found')),
            );
          }
          return DetailPage(anime: anime);
        },
      ),
    ],
  );
}
