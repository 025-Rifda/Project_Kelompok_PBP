import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import '../widgets/media_card.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_state.dart';
import '../bloc/anime_event.dart';
import '../models/anime_model.dart';
import 'package:sizer/sizer.dart';

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

  Widget _buildHeader(bool isMobile) {
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

  Widget _buildContent(bool isMobile) {
    return Column(
      children: [
        _buildFilterBar(context, isMobile),
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
                          size: 100,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Belum ada anime favorit',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tambahkan anime ke favorit dari halaman detail',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final raw = favorites[index];
                    // Check if raw is Anime already or Map and parse accordingly
                    final animeModel = raw is Anime ? raw : Anime.fromJson(raw);
                    return MediaCard(
                      item: animeModel,
                      onTap: () {
                        context.push('/detail/${animeModel.malId}');
                      },
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

  Widget _buildFilterBar(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Text(
            'Filter Favorit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: isMobile ? 16.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 10,
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
    final currentState = context.read<AnimeBloc>().state;
    bool? selectedSort;
    if (currentState is AnimeLoaded) {
      selectedSort = currentState.sortFavoritesAscending;
    }

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
                    groupValue: selectedSort,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedSort = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('High -> Low'),
                  leading: Radio<bool?>(
                    value: false,
                    groupValue: selectedSort,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedSort = value;
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
                if (selectedSort != null) {
                  context.read<AnimeBloc>().add(
                    SortFavoritesEvent(selectedSort!),
                  );
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      selectedSort == true
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

  void _resetFilters(BuildContext context) {
    setState(() {});
    context.read<AnimeBloc>().add(ResetFilterEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorting direset'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
