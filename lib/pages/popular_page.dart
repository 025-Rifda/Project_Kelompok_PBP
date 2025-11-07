import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  Set<String> _selectedGenres = {};
  double? _selectedRating;

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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFE1BEE7)),
            onPressed: () => context.go('/dashboard'),
          ),
          Text(
            'Anime Populer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE1BEE7),
            ),
          ),
          const Spacer(),
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
            List<Map<String, dynamic>> animeList = state.displayList
                .cast<Map<String, dynamic>>();

            // Apply filters and sorting
            if (_selectedGenres.isNotEmpty) {
              animeList = animeList.where((anime) {
                final genres = anime['genres'] as List<dynamic>?;
                return genres != null &&
                    genres.any((genre) => _selectedGenres.contains(genre));
              }).toList();
            }

            if (_selectedRating != null) {
              animeList = animeList.where((anime) {
                final score = anime['score']?.toDouble() ?? 0.0;
                return score >= _selectedRating!;
              }).toList();
            }

            final displayList = animeList
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
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final anime = displayList[index];
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
            'Filter',
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
            itemCount: genres.length + 1, // +1 for "Semua" option
            itemBuilder: (context, index) {
              if (index == 0) {
                return CheckboxListTile(
                  title: const Text('Semua'),
                  value: _selectedGenres.isEmpty,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedGenres.clear();
                      }
                    });
                    _loadPopular();
                  },
                );
              }
              final genre = genres[index - 1];
              return CheckboxListTile(
                title: Text(genre),
                value: _selectedGenres.contains(genre),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedGenres.add(genre);
                    } else {
                      _selectedGenres.remove(genre);
                    }
                  });
                  _loadPopular();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _loadPopular() {
    setState(() {});
  }

  void _showRatingFilter(BuildContext context) {
    final ratings = [7.0, 8.0, 9.0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Minimum Rating'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: ratings.length + 1, // +1 for "Semua" option
            itemBuilder: (context, index) {
              if (index == 0) {
                return CheckboxListTile(
                  title: const Text('Semua'),
                  value: _selectedRating == null,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedRating = null;
                      }
                    });
                    _loadPopular();
                  },
                );
              }
              final rating = ratings[index - 1];
              return CheckboxListTile(
                title: Text('Rating ${rating}+'),
                value: _selectedRating == rating,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedRating = rating;
                    } else {
                      _selectedRating = null;
                    }
                  });
                  _loadPopular();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _resetFilters(BuildContext context) {
    setState(() {
      _selectedGenres.clear();
      _selectedRating = null;
    });
    _loadPopular();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter direset'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
