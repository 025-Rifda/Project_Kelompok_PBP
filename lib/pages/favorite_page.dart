import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import '../widgets/anime_card.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_state.dart';
import '../bloc/anime_event.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool? _sortRatingAscending;

  @override
  void initState() {
    super.initState();
    context.read<AnimeBloc>().add(FetchFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Favorit'),
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
                'Anime Favorit',
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
      child: Column(
        children: [
          _buildFilterBar(context),
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
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Belum ada anime favorit',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tambahkan anime ke favorit dari halaman detail',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final anime = favorites[index];
                      return AnimeCard(
                        title: anime['title'] ?? 'No Title',
                        imageUrl: anime['images']['jpg']['image_url'] ?? '',
                        score: anime['score']?.toDouble() ?? 0.0,
                        onTap: () {
                          // Navigate to detail page if needed
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
            'Filter Favorit',
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
                icon: Icons.star,
                label: 'Rating',
                color: const Color(0xFFBBDEFB),
                onPressed: () => _showRatingFilter(context),
              ),
              _filterButton(
                icon: Icons.refresh,
                label: 'Reset',
                color: Colors.grey,
                onPressed: () => _resetFilters(context),
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

  void _showRatingFilter(BuildContext context) {
    final currentState = context.read<AnimeBloc>().state as AnimeLoaded;
    bool? selectedSort = currentState.sortFavoritesAscending;

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
    setState(() {
      _sortRatingAscending = null;
    });
    context.read<AnimeBloc>().add(ResetFilterEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorting direset'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
