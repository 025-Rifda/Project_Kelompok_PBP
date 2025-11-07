import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: const Color.fromARGB(255, 168, 128, 176),
            ),
            onPressed: () => context.go('/dashboard'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Pengaturan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 168, 128, 176),
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
              onTap: () {
                // Navigate to notification settings
              },
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Pengaturan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 168, 128, 176),
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
    context.read<ThemeCubit>().emit(false); // Reset to light mode
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
          color: const Color.fromARGB(255, 168, 128, 176),
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
        leading: Icon(icon, color: const Color.fromARGB(255, 168, 128, 176)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
