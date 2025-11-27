import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_event.dart';
import '../bloc/anime_state.dart';
import '../models/anime_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/media_card.dart';
import 'package:sizer/sizer.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({super.key});

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  @override
  void initState() {
    super.initState();
    context.read<AnimeBloc>().add(FetchPopularAnimeEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // MOBILE LAYOUT
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
            'Anime Populer',
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
        drawer: _buildDrawer(context),
        body: _buildContent(isMobile),
      );
    }

    // DESKTOP LAYOUT
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Anime Populer'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent(isMobile)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
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
              _buildFilterBar(context, isMobile),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 5,
                    crossAxisSpacing: isMobile ? 2.w : 20,
                    mainAxisSpacing: isMobile ? 2.h : 20,
                    childAspectRatio: isMobile ? 0.65 : 0.70,
                  ),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final anime = displayList[index];
                    return MediaCard(
                      item: anime,
                      onTap: () => context.push('/detail/${anime.malId}'),
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
    );
  }

  Widget _buildHeader() {
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
                'Anime Populer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 14.sp,
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

  Widget _buildFilterBar(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Text(
            'Filter',
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
                    onChanged: (value) {
                      setState(() => selectedSort = value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('High -> Low'),
                  leading: Radio<bool?>(
                    value: false,
                    groupValue: selectedSort,
                    onChanged: (value) {
                      setState(() => selectedSort = value);
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
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
            child: const Text(
              'Menu Navigasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Anime Populer'),
            onTap: () {
              Navigator.pop(context);
              // Already on this page
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorit'),
            onTap: () {
              Navigator.pop(context);
              context.go('/favorite');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat'),
            onTap: () {
              Navigator.pop(context);
              context.go('/history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shuffle),
            title: const Text('Anime Random'),
            onTap: () {
              Navigator.pop(context);
              context.go('/random');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
        ],
      ),
    );
  }
}
