import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_event.dart';
import '../bloc/anime_state.dart';
import '../models/anime_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/anime_card.dart';
import '../pages/detail_page.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({super.key});

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  @override
  void initState() {
    super.initState();
    context.read<AnimeBloc>().add(FetchTopAnimeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Anime Populer'),
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
          Text(
            'Anime Populer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE1BEE7),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFE1BEE7)),
            onPressed: () =>
                context.read<AnimeBloc>().add(FetchTopAnimeEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: BlocBuilder<AnimeBloc, AnimeState>(
        builder: (context, state) {
          if (state is AnimeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimeLoaded) {
            final animeList = state.displayList
                .map((json) => Anime.fromJson(json))
                .toList();
            return Column(
              children: [
                _buildFilterBar(context),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: animeList.length,
                    itemBuilder: (context, index) {
                      final anime = animeList[index];
                      return AnimeCard(
                        title: anime.title,
                        imageUrl: anime.imageUrl,
                        score: anime.score,
                        year: anime.year,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(anime: anime),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is AnimeError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          return const Center(child: Text('Welcome to Popular Anime'));
        },
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
            'Filter & Sort',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE1BEE7),
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 10,
            children: [
              _filterButton(
                icon: Icons.filter_list,
                label: 'Genre',
                color: const Color(0xFFE1BEE7),
                onPressed: () => _showGenreFilter(context),
              ),
              _filterButton(
                icon: Icons.sort,
                label: 'Rating',
                color: const Color(0xFFBBDEFB),
                onPressed: () => _toggleSort(context),
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

  void _showGenreFilter(BuildContext context) {
    final genres = [
      'Action',
      'Adventure',
      'Comedy',
      'Drama',
      'Fantasy',
      'Horror',
      'Mystery',
      'Romance',
      'Sci-Fi',
      'Slice of Life',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Genre'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              return ListTile(
                title: Text(genre),
                onTap: () {
                  context.read<AnimeBloc>().add(FilterByGenreEvent(genre));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Filter diterapkan: $genre'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _toggleSort(BuildContext context) {
    final currentState = context.read<AnimeBloc>().state;
    if (currentState is AnimeLoaded) {
      final ascending = currentState.sortAscending;
      context.read<AnimeBloc>().add(SortByRatingEvent(!ascending));
    }
  }

  void _resetFilters(BuildContext context) {
    context.read<AnimeBloc>().add(ResetFilterEvent());
  }
}
