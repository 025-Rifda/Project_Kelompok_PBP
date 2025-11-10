import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_event.dart';
import '../bloc/anime_state.dart';
import '../models/anime_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/media_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  Set<String> _selectedGenres = {};
  double? selectedRating;
  bool? _sortRatingAscending;
  String _username = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    context.read<AnimeBloc>().add(FetchTopAnimeEvent());
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Pengguna';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 209, 132, 218),
          title: const Text(
            'Nekofeed',
            style: TextStyle(
              color: Color.fromARGB(255, 168, 128, 176),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _showMobileDrawer(context),
            ),
          ],
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                _buildSearchBar(),
                _buildBanner(context),
                const SizedBox(height: 20),

                _buildContentArea(),
              ],
            ),
            if (_isSearching)
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: BlocBuilder<AnimeBloc, AnimeState>(
                  builder: (context, state) {
                    if (state is AnimeLoaded &&
                        state.searchHistory.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.searchHistory.take(5).length,
                          itemBuilder: (context, index) {
                            final history = state.searchHistory[index];
                            final query = history['query'] as String;
                            return Container(
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  _searchController.text = query;
                                  _searchFocusNode.unfocus();
                                  context.read<AnimeBloc>().add(
                                    SearchAnimeEvent(query),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Text(query),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              if (!isTablet) const Sidebar(selectedPage: 'Dashboard'),
              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildBanner(context),
                    const SizedBox(height: 20),

                    _buildContentArea(),
                  ],
                ),
              ),
            ],
          ),
          if (_isSearching)
            Positioned(
              top: 80, // Position below search bar
              left: isTablet
                  ? 20
                  : 270, // Align with text area after search icon
              right: 20,
              child: BlocBuilder<AnimeBloc, AnimeState>(
                builder: (context, state) {
                  if (state is AnimeLoaded && state.searchHistory.isNotEmpty) {
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.searchHistory.take(5).length,
                        itemBuilder: (context, index) {
                          final history = state.searchHistory[index];
                          final query = history['query'] as String;
                          return Container(
                            color: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                _searchController.text = query;
                                _searchFocusNode.unfocus();
                                context.read<AnimeBloc>().add(
                                  SearchAnimeEvent(query),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Text(query),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        cursorColor: const Color.fromARGB(255, 168, 128, 176),
        decoration: InputDecoration(
          hintText: 'Cari anime kesukaanmu...',
          hintStyle: const TextStyle(
            color: const Color.fromARGB(255, 168, 128, 176),
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 241, 222, 249),
          prefixIcon: const Icon(
            Icons.search,
            color: const Color.fromARGB(255, 168, 128, 176),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: const Color.fromARGB(255, 168, 128, 176),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AnimeBloc>().add(FetchTopAnimeEvent());
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (query) {
          context.read<AnimeBloc>().add(
            query.isEmpty ? FetchTopAnimeEvent() : SearchAnimeEvent(query),
          );
        },
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  //  BANNER
  Widget _buildBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE1BEE7), Color(0xFFBBDEFB)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai $_username 💕!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hari ini ada banyak anime populer buat kamu tonton!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Image.asset('assets/splash.png', height: 90, width: 90),
        ],
      ),
    );
  }

  //  CONTENT AREA (LIST + FILTERS)
  Widget _buildContentArea() {
    return Expanded(
      child: BlocConsumer<AnimeBloc, AnimeState>(
        listener: (context, state) {
          if (state is AnimeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnimeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimeLoaded) {
            final animeList = state.displayList
                .map((json) => Anime.fromJson(json))
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildAnimeList(animeList),
              ],
            );
          } else if (state is AnimeError) {
            return Center(
              child: Text(
                'Ups, anime tidak ditemukan (｡•́︿•̀｡)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          return const Center(child: Text('Welcome to Anime Dashboard'));
        },
      ),
    );
  }

  //  HEADER (Title + Filter Buttons)
  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Top Rated Anime',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: const Color.fromARGB(255, 168, 128, 176),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Top Rated Anime',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  // ANIME LIST (horizontal scroll)
  Widget _buildAnimeList(List<Anime> animeList) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7,
          ),
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
                      return MediaCard(
                        item: anime,
                        onTap: () => context.push('/detail/${anime.malId}'),
                      );
          },
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: animeList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return MediaCard(
            item: anime,
            onTap: () => context.push('/detail/${anime.malId}'),
          );
        },
      ),
    );
  }

  //  Filter Button Builder
  Widget _filterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );
  }

  //  FILTER / SORT FUNCTIONS

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
                context.read<AnimeBloc>().add(
                  SortByRatingEvent(_sortRatingAscending!),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _sortRatingAscending!
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

  void _toggleSort(BuildContext context) {
    final currentState = context.read<AnimeBloc>().state;
    if (currentState is AnimeLoaded) {
      final ascending = currentState.sortAscending;
      context.read<AnimeBloc>().add(SortByRatingEvent(!ascending));
    }
  }

  void _resetFilters(BuildContext context) {
    setState(() {
      _sortRatingAscending = null;
    });
    context.read<AnimeBloc>().add(ResetFilterEvent());
  }

  void _showDeleteHistoryDialog(BuildContext context, String query) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus pencarian ini dari histori Anda?'),
          content: Text(
            'Anda telah mencari sebelumnya. Menghapus "$query" dari histori akan menghapusnya secara permanen dari akun Anda di semua perangkat.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                context.read<AnimeBloc>().add(RemoveHistoryItemEvent(query));
                setState(() {
                  _isSearching = false;
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              context,
              Icons.dashboard,
              'Dashboard',
              '/dashboard',
              resetToTop: true,
            ),
            _buildMenuItem(context, Icons.star, 'Anime Populer', '/popular'),
            _buildMenuItem(context, Icons.favorite, 'Favorit', '/favorite'),
            _buildMenuItem(context, Icons.shuffle, 'Anime Random', '/random'),
            _buildMenuItem(context, Icons.history, 'Riwayat', '/history'),
            _buildMenuItem(context, Icons.settings, 'Pengaturan', '/settings'),
            _buildMenuItem(
              context,
              Icons.person,
              'Profil',
              '/settings/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    bool resetToTop = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 168, 128, 176)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (resetToTop) {
          context.read<AnimeBloc>().add(FetchTopAnimeEvent(resetToTop: true));
        }
        context.go(route);
      },
    );
  }
}
