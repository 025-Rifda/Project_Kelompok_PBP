import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../models/anime_model.dart';
import '../bloc/anime_bloc.dart';
import '../bloc/anime_state.dart';
import '../bloc/anime_event.dart';

class DetailPage extends StatelessWidget {
  final Anime anime;

  const DetailPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1BEE7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          anime.title,
          style: const TextStyle(
            color: Colors.white,
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
                color: const Color(0xFFE1BEE7),
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
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info dashboard
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow('Tahun Rilis', anime.year?.toString() ?? '-'),
                  _infoRow('Skor', anime.score?.toStringAsFixed(1) ?? '-'),
                  _infoRow('Status', 'Completed'), // Placeholder
                  _infoRow('Genre', 'Action, Adventure'), // Placeholder
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
                  color: const Color(0xFFE1BEE7).withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anime.synopsis ?? 'Sinopsis belum tersedia.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            // Tombol favorit
            BlocBuilder<AnimeBloc, AnimeState>(
              builder: (context, state) {
                final isFavorite =
                    state is AnimeLoaded &&
                    state.favorites.any((fav) => fav['mal_id'] == anime.malId);
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
                    isFavorite ? 'Hapus dari Favorit' : 'Tambahkan ke Favorit',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB3BA), // Pink lembut
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 30,
                      vertical: 15,
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
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
