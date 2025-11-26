import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_event.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 236, 185, 245),
                  Color.fromARGB(255, 172, 130, 220),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Pengaturan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: _buildContent(),
      );
    }

    // WEB / DESKTOP
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Pengaturan'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 236, 185, 245),
            Color.fromARGB(255, 172, 130, 220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 17.sp),
            onPressed: () => context.go('/dashboard'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Pengaturan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 17.sp),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12.sp : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBar(context, isMobile),
            SizedBox(height: 8.sp),

            _buildSectionTitle('Tampilan', fontSize: isMobile ? 14.sp : 13.sp),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: 'Mode Gelap',
              subtitle: 'Aktifkan mode gelap untuk aplikasi',
              trailing: Switch(
                value: context.watch<ThemeCubit>().state,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
              iconSize: isMobile ? 15.sp : 14.sp,
              titleSize: isMobile ? 13.sp : 12.sp,
              subtitleSize: isMobile ? 12.sp : 11.sp,
            ),

            SizedBox(height: 8.sp),

            /// SECTION: Aplikasi
            _buildSectionTitle('Aplikasi', fontSize: isMobile ? 14.sp : 13.sp),
            _buildSettingItem(
              icon: Icons.info,
              title: 'Tentang',
              subtitle: 'Versi aplikasi dan informasi lainnya',
              onTap: () => context.go('/settings/about'),
              iconSize: isMobile ? 15.sp : 14.sp,
              titleSize: isMobile ? 13.sp : 12.sp,
              subtitleSize: isMobile ? 12.sp : 11.sp,
            ),
            _buildSettingItem(
              icon: Icons.help,
              title: 'Bantuan',
              subtitle: 'Panduan dan dukungan',
              onTap: () => context.go('/settings/help'),
              iconSize: isMobile ? 15.sp : 14.sp,
              titleSize: isMobile ? 13.sp : 12.sp,
              subtitleSize: isMobile ? 12.sp : 11.sp,
            ),
            _buildSettingItem(
              icon: Icons.devices,
              title: 'Informasi Perangkat',
              subtitle: 'Lihat detail perangkat Anda',
              onTap: () => context.go('/settings/device-info'),
              iconSize: isMobile ? 15.sp : 14.sp,
              titleSize: isMobile ? 13.sp : 12.sp,
              subtitleSize: isMobile ? 12.sp : 11.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            'Pengaturan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: isMobile ? 15.sp : 13.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 10,
            children: [
              _filterButton(
                icon: Icons.refresh,
                label: 'Reset',
                color: Colors.grey,
                onPressed: () => _resetSettings(context),
                isMobile: isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isMobile ? 14.sp : 12.sp),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: TextStyle(fontSize: isMobile ? 14.sp : 12.sp),
      ),
    );
  }

  void _resetSettings(BuildContext context) {
    context.read<ThemeCubit>().emit(false); // Reset ke mode terang
    context.read<AnimeBloc>().add(ResetSettingsEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil direset'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required double fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    double iconSize = 22,
    double titleSize = 14,
    double subtitleSize = 12,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.sp),
        child: ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: iconSize,
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: subtitleSize, color: Colors.grey[600]),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }

  // Tampilkan dialog konfirmasi sebelum logout
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog dulu
                _logout(); // Lanjut logout
              },
              child: const Text(
                'Ya',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus data pengguna

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil logout'),
          backgroundColor: Colors.redAccent,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      context.go('/login');
    }
  }
}
