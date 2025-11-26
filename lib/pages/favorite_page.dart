import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../widgets/sidebar.dart';
import '../widgets/media_card.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_state.dart';
import '../bloc/anime_event.dart';
import '../models/anime_model.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    context.read<AnimeBloc>().add(FetchFavoritesEvent());
  }

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
          title: Text(
            'Anime Favorit',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: _buildContent(isMobile),
      );
    }

    // DESKTOP
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Favorit'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(child: _buildContent(isMobile)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEADER DESKTOP
  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(2.h),
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
                'Anime Favorit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CONTENT
  Widget _buildContent(bool isMobile) {
    return Column(
      children: [
        _buildFilterBar(isMobile),
        Expanded(
          child: BlocBuilder<AnimeBloc, AnimeState>(
            builder: (context, state) {
              if (state is AnimeLoaded) {
                final favorites = state.favorites;

                if (favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 18.w,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Belum ada anime favorit',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Tambahkan anime dari halaman detail',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 4,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: isMobile ? 0.65 : 0.75,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final raw = favorites[index];
                    final anime = raw is Anime ? raw : Anime.fromJson(raw);

                    return MediaCard(
                      item: anime,
                      onTap: () => context.push('/detail/${anime.malId}'),
                    );
                  },
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  // FILTER BAR
  Widget _buildFilterBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: isMobile ? 1.2.h : 1.h,
      ),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Text(
            'Filter Favorit',
            style: TextStyle(
              fontSize: isMobile ? 16.sp : 13.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 2.w,
            children: [
              _filterButton(
                icon: Icons.star,
                label: 'Rating',
                color: const Color.fromARGB(255, 152, 209, 255),
                onPressed: () => _showRatingFilter(context),
                isMobile: isMobile,
              ),
              _filterButton(
                icon: Icons.refresh,
                label: 'Reset',
                color: Colors.grey,
                onPressed: () => _resetFilters(context),
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

  void _showRatingFilter(BuildContext context) {
    // Get current sortFavoritesAscending value safely, default to true if not available
    bool currentSortAscending = true;
    final currentState = context.read<AnimeBloc>().state;
    if (currentState is AnimeLoaded) {
      currentSortAscending = currentState.sortFavoritesAscending;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Urutkan Berdasarkan Rating'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Low → High'),
              leading: Radio<bool>(
                value: true,
                groupValue: currentSortAscending,
                onChanged: (v) {
                  context.read<AnimeBloc>().add(SortFavoritesEvent(true));
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('High → Low'),
              leading: Radio<bool>(
                value: false,
                groupValue: currentSortAscending,
                onChanged: (v) {
                  context.read<AnimeBloc>().add(SortFavoritesEvent(false));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters(BuildContext context) {
    context.read<AnimeBloc>().add(ResetFilterEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorting favorit direset'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
