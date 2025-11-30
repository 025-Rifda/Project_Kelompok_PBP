import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import 'package:sizer/sizer.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Tentang'),
          Expanded(
            child: Column(children: [_buildHeader(), _buildContent(isMobile)]),
          ),
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
                'Tentang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.sp),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.tv,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'NekoFeed',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 16.sp : 15.sp,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Versi 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontSize: isMobile ? 14.sp : 13.sp,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Nekofeed adalah aplikasi untuk mencari dan menjelajahi anime favorit Anda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isMobile ? 12.sp : 11.sp,
              ),
            ),
            Text(
              'Temukan anime populer, simpan favorit, dan lihat riwayat pencarian Anda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isMobile ? 12.sp : 11.sp,
              ),
            ),
            const SizedBox(height: 30),
            _buildAboutItem('Pengembang', 'Kelompok 1', isMobile),
            _buildAboutItem('Platform', 'Flutter', isMobile),
            _buildAboutItem('API', 'Jikan API (MyAnimeList)', isMobile),
            _buildAboutItem('Lisensi', 'Open Source', isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem(String label, String value, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 13.sp : 12.sp,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: isMobile ? 12.sp : 11.sp),
        ),
      ),
    );
  }
}
