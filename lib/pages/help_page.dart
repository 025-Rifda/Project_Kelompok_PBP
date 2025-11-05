import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Bantuan'),
          Expanded(child: Column(children: [_buildHeader(), _buildContent()])),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Text(
        'Bantuan',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE1BEE7),
        ),
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
            _buildHelpSection('Cara Menggunakan Aplikasi', [
              '1. Gunakan search bar untuk mencari anime favorit Anda.',
              '2. Klik pada kartu anime untuk melihat detail.',
              '3. Tambahkan anime ke favorit dengan tombol hati.',
              '4. Gunakan filter genre dan rating untuk menyaring anime.',
              '5. Lihat riwayat pencarian Anda di halaman Riwayat.',
            ]),
            const SizedBox(height: 20),
            _buildHelpSection('Fitur Utama', [
              '• Dashboard: Lihat anime populer dan gunakan filter.',
              '• Anime Populer: Daftar anime dengan rating tinggi.',
              '• Favorit: Simpan anime yang Anda sukai.',
              '• Riwayat: Lihat query pencarian sebelumnya.',
              '• Pengaturan: Ubah tema dan reset pengaturan.',
            ]),
            const SizedBox(height: 20),
            _buildHelpSection('Tips', [
              '• Gunakan filter untuk menemukan anime berdasarkan genre.',
              '• Sort rating membantu menemukan anime terbaik.',
              '• Reset filter untuk kembali ke daftar asli.',
              '• Mode gelap tersedia di sidebar.',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE1BEE7),
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(item, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
