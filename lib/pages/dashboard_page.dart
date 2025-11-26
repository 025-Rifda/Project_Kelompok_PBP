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
import '../widgets/rating_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  // ======================== LOGOUT WITH RATING DIALOG ==========================
  Future<void> _handleLogout() async {
    // Show rating dialog first
    await showDialog(
      context: context,
      builder: (context) => const RatingDialog(),
    );

    // The actual logout confirmation and logout process is handled inside RatingDialog
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      key: _scaffoldKey,

      // ======================== APP BAR DIBUAT KONDISIONAL DENGAN GRADIENT ==========================
      appBar: isMobile
          ? AppBar(
              // Header Ungu Mobile
              automaticallyImplyLeading: false,
              title: const Text(
                "Dashboard",
                style: TextStyle(color: Colors.white), // 🔥 Teks berwarna putih
              ),

              // 🔥 Set Background transparan
              backgroundColor: Colors.transparent,
              elevation: 0, // Hilangkan bayangan/shadow
              // 🔥 Terapkan Gradient sebagai FlexibleSpaceBar
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

              // MENU MOBILE (Icon Burger)
              leading: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ), // 🔥 Ikon putih
                onPressed: _showMobileMenu,
              ),
              // LOGOUT HANYA MUNCUL DI MOBILE
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ), // 🔥 Ikon putih
                  onPressed: _handleLogout,
                ),
              ],
            )
          : null, // DI DESKTOP/WEB, APPBAR ADALAH NULL (HILANG)
      // Drawer disetel null karena kita menggunakan bottom sheet untuk mobile
      drawer: null,

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

  // ======================== SEARCH BAR ==========================
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

  // ======================== BANNER ==========================
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
          // Gambar Kucing
          Image.asset('assets/splash.png', height: 12.h),
        ],
      ),
    );
  }

  // ======================== MOBILE BOTTOM SHEET MENU (Dipanggil oleh AppBar) ==========================
  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () => context.go('/dashboard'),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Populer'),
                onTap: () => context.go('/popular'),
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorit'),
                onTap: () => context.go('/favorite'),
              ),
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Anime Random'),
                onTap: () => context.go('/random'),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Riwayat'),
                onTap: () => context.go('/history'),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Pengaturan'),
                onTap: () => context.go('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () => context.go('/profile'),
              ),
              // Add Logout here with rating and confirmation dialog
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet first
                  _handleLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================== CONTENT BLOC ==========================
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

  // ======================== HEADER FILTER ==========================
  Widget _buildHeader() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Text(
            'Top Rated Anime',
            style: TextStyle(
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

  // ======================== GRID VIEW ==========================
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

  // ======================== FILTER BUTTON ==========================
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

  // ======================== RATING FILTER POPUP ==========================
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

  // ======================== RESET FILTER ==========================
  void _resetFilters(BuildContext context) {
    setState(() => _sortRatingAscending = null);
    context.read<AnimeBloc>().add(ResetFilterEvent());
  }
}
