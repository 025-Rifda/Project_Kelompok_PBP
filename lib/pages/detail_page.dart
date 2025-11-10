import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../models/anime_model.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_state.dart';
import '../bloc/anime_event.dart';
import '../services/history_service.dart';

class DetailPage extends StatelessWidget {
  final Anime anime;

  const DetailPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    // Tambah ke history saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HistoryService.addToHistory(anime);
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              context.pop();
            } else {
              // Fallback jika tidak ada stack untuk dipop (mis. dinavigasi dengan context.go)
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          anime.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar poster anime (responsive)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  anime.imageUrl,
                  height: isMobile ? 200 : 250,
                  width: isMobile ? 150 : 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Judul dan rating
            Text(
              anime.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${anime.score?.toStringAsFixed(1) ?? 'N/A'} / 10',
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info dashboard
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow(context, 'Tahun Rilis', anime.year?.toString() ?? '-'),
                  _infoRow(context, 'Skor', anime.score?.toStringAsFixed(1) ?? '-'),
                  _infoRow(context, 'Status', 'Completed'), // Placeholder
                  _infoRow(
                    context,
                    'Genre',
                    anime.genres?.join(', ') ?? 'Tidak tersedia',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sinopsis
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sinopsis 💕',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anime.synopsis ?? 'Sinopsis belum tersedia.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 30),

            // Tombol-tombol aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol WebView MyAnimeList
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      '/webview',
                      extra: 'https://myanimelist.net/anime/${anime.malId}',
                    );
                  },
                  icon: const Icon(Icons.web),
                  label: const Text('Lihat di MyAnimeList'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF2E51A2,
                    ), // Biru MyAnimeList
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 15 : 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Tombol favorit
                BlocBuilder<AnimeBloc, AnimeState>(
                  builder: (context, state) {
                    final isFavorite =
                        state is AnimeLoaded &&
                        state.favorites.any(
                          (fav) => fav['mal_id'] == anime.malId,
                        );
                    return ElevatedButton.icon(
                      onPressed: () {
                        if (isFavorite) {
                          context.read<AnimeBloc>().add(
                            RemoveFromFavoritesEvent(anime.malId.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dihapus dari favorit'),
                              backgroundColor: Colors.red,
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
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(
                        isFavorite
                            ? 'Hapus dari Favorit'
                            : 'Tambahkan ke Favorit',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB3BA), // Pink lembut
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 15 : 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onBackground),
          ),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), fontSize: 16)),
        ],
      ),
    );
  }
}
