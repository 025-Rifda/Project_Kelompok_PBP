import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../models/anime_model.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_state.dart';
import '../bloc/anime_event.dart';
import '../services/history_service.dart';
import 'package:sizer/sizer.dart';

class DetailPage extends StatelessWidget {
  final Anime anime;

  const DetailPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HistoryService.addToHistory(anime);
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF5F0FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 54 : 95),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: isMobile ? 10 : 20,
          ),
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
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: isMobile ? 18.sp : 17.sp,
                ),
                onPressed: () => context.go('/dashboard'),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    anime.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16.sp : 14.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 40 : 48),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // GAMBAR POSTER
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          anime.imageUrl,
                          height: isMobile ? 220 : 280,
                          width: isMobile ? 160 : 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // JUDUL
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 40,
                    ),
                    child: Text(
                      anime.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color.fromARGB(255, 148, 108, 217)
                            : const Color(0xFFAC82DC),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // RATING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '${anime.score?.toStringAsFixed(1) ?? 'N/A'} / 10',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // INFO ANIME CARD
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                    ),
                    padding: EdgeInsets.all(isMobile ? 20 : 24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Theme.of(context).cardColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.35)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          context,
                          'Tahun Rilis',
                          anime.year?.toString() ?? '-',
                        ),
                        const Divider(height: 24, color: Color(0xFFE0D4F0)),
                        _infoRow(
                          context,
                          'Skor',
                          anime.score?.toStringAsFixed(1) ?? '-',
                        ),
                        const Divider(height: 24, color: Color(0xFFE0D4F0)),
                        _infoRow(context, 'Status', 'Completed'),
                        const Divider(height: 24, color: Color(0xFFE0D4F0)),
                        _infoRow(
                          context,
                          'Genre',
                          anime.genres?.join(', ') ?? 'Tidak tersedia',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SINOPSIS SECTION
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                    ),
                    padding: EdgeInsets.all(isMobile ? 20 : 24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Theme.of(context).cardColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.35)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Sinopsis',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color.fromARGB(255, 148, 108, 217)
                                    : const Color(0xFFAC82DC),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('💕', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          anime.synopsis ?? 'Sinopsis belum tersedia.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.6,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BUTTONS
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                    ),
                    child: Column(
                      children: [
                        // BUTTON MYANIMELIST
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push(
                                '/webview',
                                extra:
                                    'https://myanimelist.net/anime/${anime.malId}',
                              );
                            },
                            icon: const Icon(Icons.web, color: Colors.white),
                            label: const Text(
                              'Lihat di MyAnimeList',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E51A2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // BUTTON FAVORIT
                        BlocBuilder<AnimeBloc, AnimeState>(
                          builder: (context, state) {
                            final isFavorite =
                                state is AnimeLoaded &&
                                state.favorites.any(
                                  (fav) => fav['mal_id'] == anime.malId,
                                );

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (isFavorite) {
                                    context.read<AnimeBloc>().add(
                                      RemoveFromFavoritesEvent(
                                        anime.malId.toString(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Dihapus dari favorit'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    context.read<AnimeBloc>().add(
                                      AddToFavoritesEvent(anime.toJson()),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ditambahkan ke favorit'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  isFavorite
                                      ? 'Hapus dari Favorit'
                                      : 'Tambahkan ke Favorit',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB3BA),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
