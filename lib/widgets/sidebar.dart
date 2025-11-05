import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          // 🌸 Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tv, color: Colors.white, size: isTablet ? 25 : 30),
              const SizedBox(width: 8),
              Text(
                'AnimeList+',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // 📜 Menu Items
          _buildMenuItem(
            context,
            Icons.dashboard,
            'Dashboard',
            selectedPage == 'Dashboard',
            '/dashboard',
          ),
          _buildMenuItem(
            context,
            Icons.star,
            'Anime Populer',
            selectedPage == 'Anime Populer',
            '/popular',
          ),
          _buildMenuItem(
            context,
            Icons.favorite,
            'Favorit',
            selectedPage == 'Favorit',
            '/favorite',
          ),
          _buildMenuItem(
            context,
            Icons.history,
            'Riwayat',
            selectedPage == 'Riwayat',
            '/history',
          ),
          _buildMenuItem(
            context,
            Icons.settings,
            'Pengaturan',
            selectedPage == 'Pengaturan',
            '/settings',
          ),

          const Spacer(),
          const Divider(color: Colors.white38, indent: 20, endIndent: 20),

          // 🌙 Toggle Mode
          ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            title: Text(
              isDark ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 14 : null,
              ),
            ),
            trailing: Switch(
              value: isDark,
              activeColor: Colors.white,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 🧭 Menu Builder
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isSelected,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          if (!isSelected) {
            context.go(route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
