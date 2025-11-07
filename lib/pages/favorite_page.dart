import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import '../widgets/anime_card.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_state.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Set<String> _selectedGenres = {};
  double? _selectedRating;

  @override
  void initState() {
    super.initState();
    // Load favorites if needed
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFFE1BEE7)),
            onPressed: () => context.go('/dashboard'),
          ),
          Text(
            'Anime Favorit',
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

                  // Apply filters
                  List<Map<String, dynamic>> filteredFavorites = favorites
                      .cast<Map<String, dynamic>>();

                  // Filter by genre
                  if (_selectedGenres.isNotEmpty) {
                    filteredFavorites = filteredFavorites.where((anime) {
                      final genres = anime['genres'] as List<dynamic>?;
                      return genres != null &&
                          genres.any(
                            (genre) => _selectedGenres.contains(genre),
                          );
                    }).toList();
                  }

                  // Filter by rating
                  if (_selectedRating != null) {
                    filteredFavorites = filteredFavorites.where((anime) {
                      final score = anime['score']?.toDouble() ?? 0.0;
                      return score >= _selectedRating!;
                    }).toList();
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
                    itemCount: filteredFavorites.length,
                    itemBuilder: (context, index) {
                      final anime = filteredFavorites[index];
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
        title: const Text('Filter Favorit by Genre'),
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
                    _loadFavorites();
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
                  _loadFavorites();
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

  void _loadFavorites() {
    setState(() {});
  }

  void _showRatingFilter(BuildContext context) {
    final ratings = [7.0, 8.0, 9.0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Favorit by Minimum Rating'),
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
                    _loadFavorites();
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
                  _loadFavorites();
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
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter direset'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
