import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_event.dart';
import '../bloc/anime_state.dart';
import '../models/anime_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/media_card.dart';

class RandomAnimePage extends StatefulWidget {
  const RandomAnimePage({super.key});

  @override
  State<RandomAnimePage> createState() => _RandomAnimePageState();
}

class _RandomAnimePageState extends State<RandomAnimePage> {
  @override
  void initState() {
    super.initState();
    context.read<AnimeBloc>().add(FetchRandomAnimeEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

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
            'Anime Random',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
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
          const Sidebar(selectedPage: 'Anime Random'),
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

  // HEADER (DESKTOP)
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(2.2.h),
      width: double.infinity,
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
                'Anime Random',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 15.sp,
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

  // MAIN CONTENT
  Widget _buildContent() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    return BlocBuilder<AnimeBloc, AnimeState>(
      builder: (context, state) {
        if (state is AnimeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnimeLoaded) {
          final list = state.displayList
              .map((json) => Anime.fromJson(json))
              .toList();

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(2.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 5,
                    crossAxisSpacing: 2.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: isMobile ? 0.64 : 0.75,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final anime = list[index];
                    return MediaCard(
                      item: anime,
                      onTap: () => context.push('/detail/${anime.malId}'),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Center(
          child: Text(
            'Welcome to Random Anime',
            style: TextStyle(fontSize: 12.sp),
          ),
        );
      },
    );
  }

  // FILTER BAR BARU
  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE FILTER (ATAS KIRI)
          Text(
            'Filter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          SizedBox(height: 1.h),

          // BUTTONS (BAWAH KANAN)
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 1.5.w,
              runSpacing: 1.h,
              children: [
                _smallFilterButton(
                  icon: Icons.star,
                  label: 'Rating',
                  color: const Color.fromARGB(255, 152, 209, 255),
                  onPressed: () => _showRatingFilter(context),
                ),
                _smallFilterButton(
                  icon: Icons.shuffle,
                  label: 'Generate',
                  color: const Color.fromARGB(255, 218, 164, 164),
                  onPressed: () => _generateNewAnime(context),
                ),
                _smallFilterButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.grey.shade400,
                  onPressed: () => _resetFilters(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallFilterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POPUP FILTER RATING
  void _showRatingFilter(BuildContext context) {
    bool? selectedSort;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Urutkan Berdasarkan Rating',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<bool?>(
                title: Text("Low → High"),
                value: true,
                groupValue: selectedSort,
                onChanged: (v) => setState(() => selectedSort = v),
              ),
              RadioListTile<bool?>(
                title: Text("High → Low"),
                value: false,
                groupValue: selectedSort,
                onChanged: (v) => setState(() => selectedSort = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                if (selectedSort != null) {
                  context.read<AnimeBloc>().add(
                    SortByRatingEvent(selectedSort!),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  void _generateNewAnime(BuildContext context) {
    context.read<AnimeBloc>().add(FetchRandomAnimeEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menggenerate anime acak baru'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _resetFilters(BuildContext context) {
    context.read<AnimeBloc>().add(ResetFilterEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorting direset'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
