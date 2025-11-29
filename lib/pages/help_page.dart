import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import 'package:sizer/sizer.dart';

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
            onPressed: () => context.go('/settings'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Bantuan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        child: Column(
          children: [
            _buildHelpCard(
              title: "Cara Menggunakan Aplikasi",
              icon: Icons.menu_book_rounded,
              items: [
                'Gunakan search bar untuk mencari anime favorit Anda.',
                'Klik pada kartu anime untuk melihat detail.',
                'Tambahkan anime ke favorit dengan tombol hati.',
                'Gunakan filter genre dan rating untuk menyaring anime.',
                'Lihat riwayat pencarian Anda di halaman Riwayat.',
              ],
            ),
            const SizedBox(height: 25),
            _buildHelpCard(
              title: "Fitur Utama",
              icon: Icons.star_rounded,
              items: [
                'Dashboard: Lihat anime populer dan gunakan filter.',
                'Anime Populer: Daftar anime dengan rating tinggi.',
                'Favorit: Simpan anime yang Anda sukai.',
                'Riwayat: Lihat query pencarian sebelumnya.',
                'Pengaturan: Ubah tema dan reset pengaturan.',
              ],
            ),
            const SizedBox(height: 25),
            _buildHelpCard(
              title: "Tips",
              icon: Icons.lightbulb_outline_rounded,
              items: [
                'Gunakan filter untuk menemukan anime berdasarkan genre.',
                'Sort rating membantu menemukan anime terbaik.',
                'Reset filter untuk kembali ke daftar asli.',
                'Mode gelap tersedia di sidebar.',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "•  ",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
