import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/media_card.dart';
import '../../../bloc/anime_bloc.dart';
import '../../../bloc/anime_event.dart';
import '../../../bloc/anime_state.dart';
import 'favorite_empty_view.dart';
import 'favorite_item_tile.dart';
import '../../../models/anime_model.dart';

class FavoriteContent extends StatefulWidget {
  final bool isMobile;

  const FavoriteContent({super.key, required this.isMobile});

  @override
  State<FavoriteContent> createState() => _FavoriteContentState();
}

class _FavoriteContentState extends State<FavoriteContent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimeBloc, AnimeState>(
      builder: (context, state) {
        if (state is AnimeLoaded) {
          final favorites = state.favorites;

          if (favorites.isEmpty) {
            return const FavoriteEmptyView();
          }

          return ListView.builder(
            key: ValueKey(
              'favorites_${favorites.length}_${favorites.hashCode}',
            ),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            itemCount: favorites.length,
            itemBuilder: (_, index) {
              // Jika item masih Map → konversi ke Anime
              final raw = favorites[index];
              final anime = raw is Anime ? raw : Anime.fromJson(raw);

              return FavoriteItemTile(
                anime: anime,
                onTap: () {
                  // 🔥 Navigasi menggunakan GoRouter
                  context.push('/detail/${anime.malId}');
                },
                onDelete: () =>
                    _removeFromFavorites(context, anime.malId.toString()),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _removeFromFavorites(BuildContext context, String animeId) async {
    context.read<AnimeBloc>().add(RemoveFromFavoritesEvent(animeId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anime dihapus dari favorit'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
