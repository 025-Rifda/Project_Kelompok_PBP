import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_event.dart';

// State Cubit untuk mengatur mode terang/gelap
class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false); // false = light, true = dark
  void toggleTheme() => emit(!state);
}

class Sidebar extends StatelessWidget {
  final String selectedPage;
  const Sidebar({super.key, required this.selectedPage});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    final isDark = context.watch<ThemeCubit>().state;

    // Hide sidebar on mobile
    if (isMobile) return const SizedBox.shrink();

    return Container(
      width: isTablet ? 200 : 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF212121), const Color(0xFF424242)] // Dark mode
              : [
                  const Color(0xFFE1BEE7),
                  const Color(0xFFBBDEFB),
                ], // Light mode
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          //  Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tv,
                color: isDark
                    ? Colors.white
                    : const Color.fromARGB(255, 5, 56, 107),
                size: isTablet ? 25 : 30,
              ),
              const SizedBox(width: 8),
              Text(
                'Nekofeed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isDark
                      ? Colors.white
                      : const Color.fromARGB(255, 5, 56, 107),
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          //  Menu Items
          _buildMenuItem(
            context,
            Icons.dashboard,
            'Dashboard',
            selectedPage == 'Dashboard',
            '/dashboard',
            isDark,
            isTablet,
            resetToTop: true,
          ),
          _buildMenuItem(
            context,
            Icons.star,
            'Anime Populer',
            selectedPage == 'Anime Populer',
            '/popular',
            isDark,
            isTablet,
          ),
          _buildMenuItem(
            context,
            Icons.favorite,
            'Favorit',
            selectedPage == 'Favorit',
            '/favorite',
            isDark,
            isTablet,
          ),
          _buildMenuItem(
            context,
            Icons.history,
            'Riwayat',
            selectedPage == 'Riwayat',
            '/history',
            isDark,
            isTablet,
          ),
          _buildMenuItem(
            context,
            Icons.shuffle,
            'Anime Random',
            selectedPage == 'Anime Random',
            '/random',
            isDark,
            isTablet,
          ),
          _buildMenuItem(
            context,
            Icons.settings,
            'Pengaturan',
            selectedPage == 'Pengaturan',
            '/settings',
            isDark,
            isTablet,
          ),
          _buildMenuItem(
            context,
            Icons.person,
            'Profil',
            selectedPage == 'Profil',
            '/settings/profile',
            isDark,
            isTablet,
          ),

          const Spacer(),
          const Divider(color: Colors.white38, indent: 20, endIndent: 20),

          // Logout Button
          ListTile(
            leading: Icon(
              Icons.logout,
              color: isDark
                  ? Colors.white
                  : const Color.fromARGB(255, 5, 56, 107),
              size: isTablet ? 25 : 30,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : const Color.fromARGB(255, 5, 56, 107),
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 14 : null,
              ),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              context.go('/');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //  Menu Builder
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isSelected,
    String route,
    bool isDark,
    bool isTablet, {
    bool resetToTop = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.white : const Color.fromARGB(255, 5, 56, 107),
          size: isTablet ? 25 : 30,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark
                ? Colors.white
                : const Color.fromARGB(255, 5, 56, 107),
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          if (!isSelected) {
            if (resetToTop) {
              context.read<AnimeBloc>().add(
                FetchTopAnimeEvent(resetToTop: true),
              );
            }
            context.go(route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
