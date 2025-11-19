import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 209, 132, 218),
          title: const Text(
            'Anime Random',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
<<<<<<< Updated upstream
        body: BlocBuilder<AnimeCubit, AnimeState>(
          builder: (context, state) {
            if (state is AnimeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnimeLoaded) {
              final anime = Anime.fromJson(state.animeList.first);
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Anime Acak untuk Kamu!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: isMobile
                          ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return MediaCard(
                                  item: anime,
                                  onTap: () =>
                                      context.push('/detail/${anime.malId}'),
                                );
                              },
                            )
                          : ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: SizedBox(
                                    width: 300,
                                    child: MediaCard(
                                      item: anime,
                                      onTap: () =>
                                          context.push('/detail/${anime.malId}'),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<AnimeCubit>().fetchRandomAnime(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
=======
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.go('/dashboard'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Anime Random',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
>>>>>>> Stashed changes
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<AnimeBloc, AnimeState>(
      builder: (context, state) {
        if (state is AnimeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnimeLoaded) {
          final displayList = state.displayList
              .map((json) => Anime.fromJson(json))
              .toList();

          return Column(
            children: [
              _buildFilterBar(context),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final anime = displayList[index];
                    return MediaCard(
                      item: anime,
                      onTap: () => context.go('/detail/${anime.malId}'),
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
        return const Center(child: Text('Welcome to Random Anime'));
      },
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Text(
            'Filter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                color: const Color(0xFFBBDEFB),
                onPressed: () => _showRatingFilter(context),
              ),
              _filterButton(
                icon: Icons.refresh,
                label: 'Generate Lagi',
                color: Colors.white,
                onPressed: () => _generateNewAnime(context),
              ),
              _filterButton(
                icon: Icons.restore,
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
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showRatingFilter(BuildContext context) {
    bool? selectedSort;

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
                    SortByRatingEvent(selectedSort!),
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
