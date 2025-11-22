import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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

  double? selectedRating;
  bool? _sortRatingAscending;

  String _username = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    context.read<AnimeBloc>().add(FetchTopAnimeEvent());

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        context.read<AnimeBloc>().add(const FetchHistoryEvent());
      }
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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) const Sidebar(selectedPage: 'Dashboard'),
          Expanded(
            child: Column(
              children: [
                _buildSearchBar(),
                SizedBox(height: 2.h),
                _buildBanner(context),
                SizedBox(height: 2.h),
                Expanded(child: _buildContentArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(2.h),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          hintText: 'Cari anime kesukaanmu...',
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AnimeBloc>().add(FetchTopAnimeEvent());
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (query) {
          context.read<AnimeBloc>().add(
            query.isEmpty ? FetchTopAnimeEvent() : SearchAnimeEvent(query),
          );
        },
      ),
    );
  }

  // BANNER
  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(2.5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Hari ini ada banyak anime populer buat kamu tonton!',
                  style: TextStyle(color: Colors.white, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Image.asset('assets/splash.png', height: 12.h),
        ],
      ),
    );
  }

  // CONTENT AREA
  Widget _buildContentArea() {
    return BlocConsumer<AnimeBloc, AnimeState>(
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
            children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              Expanded(child: _buildAnimeGrid(animeList)),
            ],
          );
        }

        return const Center(child: Text('Welcome to Anime Dashboard'));
      },
    );
  }

  // HEADER (Title + Filter)
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Text(
            'Top Rated Anime',
            style: TextStyle(
              fontSize: 14.sp,
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

  // GRIDVIEW (BARU)
  Widget _buildAnimeGrid(List<Anime> animeList) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 5,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: isMobile ? 0.65 : 0.75,
      ),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];
        return MediaCard(
          item: anime,
          onTap: () => context.push('/detail/${anime.malId}'),
        );
      },
    );
  }

  // FILTER BUTTON WIDGET
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
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  // POPUP SORTING RATING
  void _showRatingFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Urutkan Berdasarkan Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<bool>(
                title: const Text('Low → High'),
                value: true,
                groupValue: _sortRatingAscending,
                onChanged: (v) => setState(() => _sortRatingAscending = v),
              ),
              RadioListTile<bool>(
                title: const Text('High → Low'),
                value: false,
                groupValue: _sortRatingAscending,
                onChanged: (v) => setState(() => _sortRatingAscending = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_sortRatingAscending != null) {
                  context.read<AnimeBloc>().add(
                    SortByRatingEvent(_sortRatingAscending!),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters(BuildContext context) {
    setState(() => _sortRatingAscending = null);
    context.read<AnimeBloc>().add(ResetFilterEvent());
  }
}
