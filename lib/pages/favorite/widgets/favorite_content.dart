import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/media_card.dart';
import '../../../bloc/anime_bloc.dart';
import '../../../bloc/anime_state.dart';
import 'favorite_empty_view.dart';
import '../../../models/anime_model.dart';

class FavoriteContent extends StatelessWidget {
  final bool isMobile;

  const FavoriteContent({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimeBloc, AnimeState>(
      builder: (context, state) {
        if (state is AnimeLoaded) {
          final favorites = state.favorites;

          if (favorites.isEmpty) {
            return const FavoriteEmptyView();
          }

          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: isMobile ? 0.65 : 0.75,
            ),
            itemCount: favorites.length,
            itemBuilder: (_, index) {
              // Jika item masih Map → konversi ke Anime
              final raw = favorites[index];
              final anime = raw is Anime ? raw : Anime.fromJson(raw);

              return MediaCard(
                item: anime,
                onTap: () {
                  // 🔥 Navigasi menggunakan GoRouter
                  context.push('/detail/${anime.malId}');
                },
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
