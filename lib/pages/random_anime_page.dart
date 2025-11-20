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
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFC8FF), Color(0xFFB497E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            'Anime Random',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: _buildContent(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FF),
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
          colors: [Color(0xFFEFC8FF), Color(0xFFB497E5)],
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
                style: TextStyle(
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

  // FILTER BAR BARU - BESAR & CANTIK
  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            'Filter',
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _bigFilterButton(
                icon: Icons.star,
                label: 'Rating',
                color: const Color(0xFFE0F0FF),
                onPressed: () => _showRatingFilter(context),
              ),
              _bigFilterButton(
                icon: Icons.refresh,
                label: 'Generate Lagi',
                color: const Color(0xFFF9F9F9),
                onPressed: () => _generateNewAnime(context),
              ),
              _bigFilterButton(
                icon: Icons.restore,
                label: 'Reset',
                color: const Color(0xFFE8E8E8),
                onPressed: () => _resetFilters(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TOMBOL FILTER BESAR (PERBAIKAN)
  Widget _bigFilterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 13.sp),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
          ),
        ],
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
