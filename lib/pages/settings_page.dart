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
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Pengaturan'),
          Expanded(child: Column(children: [_buildHeader(), _buildContent()])),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.go('/dashboard'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Pengaturan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBar(context),
            const SizedBox(height: 20),
            _buildSectionTitle('Tampilan'),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: 'Mode Gelap',
              subtitle: 'Aktifkan mode gelap untuk aplikasi',
              trailing: Switch(
                value: context.watch<ThemeCubit>().state,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Akun'),
            _buildSettingItem(
              icon: Icons.person,
              title: 'Profil',
              subtitle: 'Kelola informasi profil Anda',
              onTap: () => context.go('/settings/profile'),
            ),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notifikasi',
              subtitle: 'Atur preferensi notifikasi',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Aplikasi'),
            _buildSettingItem(
              icon: Icons.info,
              title: 'Tentang',
              subtitle: 'Versi aplikasi dan informasi lainnya',
              onTap: () => context.go('/settings/about'),
            ),
            _buildSettingItem(
              icon: Icons.help,
              title: 'Bantuan',
              subtitle: 'Panduan dan dukungan',
              onTap: () => context.go('/settings/help'),
            ),
            _buildSettingItem(
              icon: Icons.devices,
              title: 'Informasi Perangkat',
              subtitle: 'Lihat detail perangkat Anda',
              onTap: () => context.go('/settings/device-info'),
            ),
            const SizedBox(height: 30),

            // 🔹 Tombol Logout dengan konfirmasi
            Center(
              child: ElevatedButton.icon(
                onPressed: _showLogoutConfirmation,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Text(
            'Pengaturan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 10,
            children: [
              _filterButton(
                icon: Icons.restore,
                label: 'Reset',
                color: Colors.grey,
                onPressed: () => _resetSettings(context),
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
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  // 🔹 Tampilkan dialog konfirmasi sebelum logout
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
