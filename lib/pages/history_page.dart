import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import '../services/history_service.dart';
import '../models/anime_model.dart';
import 'package:sizer/sizer.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool? _sortRatingAscending;
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.getHistory();
    setState(() {
      _history = _applyFiltersAndSort(history);
    });
  }

  List<Map<String, dynamic>> _applyFiltersAndSort(
    List<Map<String, dynamic>> history,
  ) {
    List<Map<String, dynamic>> filtered = history;

    // Sort by rating if specified
    if (_sortRatingAscending != null) {
      filtered.sort((a, b) {
        final aScore = a['score']?.toDouble() ?? 0.0;
        final bScore = b['score']?.toDouble() ?? 0.0;
        return _sortRatingAscending!
            ? aScore.compareTo(bScore)
            : bScore.compareTo(aScore);
      });
    } else {
      // Sort by timestamp
      filtered.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp']);
        final bTime = DateTime.parse(b['timestamp']);
        return _sortNewestFirst
            ? bTime.compareTo(aTime)
            : aTime.compareTo(bTime);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
          title: Text(
            'Riwayat Kunjungan',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildContent(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Riwayat'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
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
            onPressed: () => context.go('/dashboard'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Riwayat Kunjungan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Column(
      children: [
        _buildFilterBar(context, isMobile),
        Expanded(
          child: _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 100,
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Belum ada riwayat kunjungan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Riwayat anime yang dikunjungi akan muncul di sini',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final title = item['title'] as String;
                    final imageUrl = item['image_url'] as String;
                    final score = item['score'] as double?;
                    final timestamp = DateTime.parse(item['timestamp']);
                    final malId = item['mal_id'] as int;

                    return GestureDetector(
                      onTap: () {
                        // Navigate to detail page
                        final anime = Anime(
                          malId: malId,
                          title: title,
                          imageUrl: imageUrl,
                          score: score,
                          year: item['year'] as int?,
                          synopsis: '', // Placeholder
                        );
                        context.push('/detail/${anime.malId}');
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  width: 70,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),

                              // TITLE + SUBTITLE
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onBackground,
                                          ),
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${score?.toStringAsFixed(1) ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),

                                    Text(
                                      'Dikunjungi: ${timestamp.toLocal().toString().split('.')[0]}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // DELETE BUTTON
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () =>
                                    _removeFromHistory(context, malId),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1 — Title
          Text(
            'Filter Riwayat',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: isMobile ? 16.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          // Baris 2 — Tombol di kanan
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              children: [
                _filterButton(
                  icon: Icons.star,
                  label: 'Rating',
                  color: const Color(0xFF98D1FF),
                  onPressed: () => _showRatingFilter(context),
                  isMobile: isMobile,
                ),
                _filterButton(
                  icon: Icons.sort,
                  label: 'Tanggal',
                  color: const Color(0xFF81C784),
                  onPressed: () => _toggleSort(context),
                  isMobile: isMobile,
                ),
                _filterButton(
                  icon: Icons.delete_sweep,
                  label: 'Hapus Semua',
                  color: Colors.red,
                  onPressed: () => _clearHistory(context),
                  isMobile: isMobile,
                ),
              ],
            ),
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

  void _toggleSort(BuildContext context) {
    setState(() {
      _sortNewestFirst = !_sortNewestFirst;
    });
    _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _sortNewestFirst
              ? 'Diurutkan dari terbaru'
              : 'Diurutkan dari terlama',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeFromHistory(BuildContext context, int malId) async {
    await HistoryService.removeFromHistory(malId);
    _loadHistory(); // Reload history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anime dihapus dari riwayat'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat kunjungan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await HistoryService.clearHistory();
              _loadHistory(); // Reload history
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Riwayat kunjungan telah dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRatingFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Urutkan Berdasarkan Rating'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Low -> High'),
                  leading: Radio<bool?>(
                    value: true,
                    groupValue: _sortRatingAscending,
                    onChanged: (bool? value) {
                      setState(() {
                        _sortRatingAscending = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('High -> Low'),
                  leading: Radio<bool?>(
                    value: false,
                    groupValue: _sortRatingAscending,
                    onChanged: (bool? value) {
                      setState(() {
                        _sortRatingAscending = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _loadHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _sortRatingAscending!
                          ? 'Diurutkan rating dari terendah'
                          : 'Diurutkan rating dari tertinggi',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
