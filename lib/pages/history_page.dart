import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../models/anime_model.dart';
import '../services/history_service.dart';
import '../widgets/history/history_empty_state.dart';
import '../widgets/history/history_filter_bar.dart';
import '../widgets/history/history_item_tile.dart';
import '../widgets/sidebar.dart';

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
    final filtered = List<Map<String, dynamic>>.from(history);

    if (_sortRatingAscending != null) {
      filtered.sort((a, b) {
        final aScore = a['score']?.toDouble() ?? 0.0;
        final bScore = b['score']?.toDouble() ?? 0.0;
        return _sortRatingAscending!
            ? aScore.compareTo(bScore)
            : bScore.compareTo(aScore);
      });
    } else {
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        HistoryFilterBar(
          isMobile: isMobile,
          onFilterRating: () => _showRatingFilter(context),
          onToggleDate: () => _toggleSort(context),
          onClearAll: () => _clearHistory(context),
        ),
        Expanded(
          child: _history.isEmpty
              ? const HistoryEmptyState()
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

                    return HistoryItemTile(
                      title: title,
                      imageUrl: imageUrl,
                      score: score,
                      visitedAt: timestamp,
                      onTap: () {
                        final anime = Anime(
                          malId: malId,
                          title: title,
                          imageUrl: imageUrl,
                          score: score,
                          year: item['year'] as int?,
                          synopsis: '',
                        );
                        context.push('/detail/${anime.malId}');
                      },
                      onDelete: () => _removeFromHistory(context, malId),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _toggleSort(BuildContext context) {
    setState(() {
      _sortNewestFirst = !_sortNewestFirst;
      _sortRatingAscending = null;
    });
    _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _sortNewestFirst ? 'Diurutkan dari terbaru' : 'Diurutkan dari terlama',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeFromHistory(BuildContext context, int malId) async {
    await HistoryService.removeFromHistory(malId);
    if (!mounted) return;
    _loadHistory();
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
              if (!mounted) return;
              _loadHistory();
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
                final sortChoice = _sortRatingAscending ?? true;
                setState(() {
                  _sortRatingAscending = sortChoice;
                  _sortNewestFirst = false;
                });
                _loadHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sortChoice
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
