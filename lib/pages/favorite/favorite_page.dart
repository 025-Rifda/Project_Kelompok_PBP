import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/sidebar.dart';
import '../../bloc/anime_bloc.dart';
import '../../bloc/anime_event.dart';
import 'widgets/favorite_header.dart';
import 'widgets/favorite_content.dart';
import 'widgets/favorite_filter_bar.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    context.read<AnimeBloc>().add(FetchFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile
          ? PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: FavoriteHeader(
                isMobile: true,
                onBack: () => context.go('/dashboard'),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) const Sidebar(selectedPage: 'Favorit'),
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  FavoriteHeader(
                    isMobile: false,
                    onBack: () => context.go('/dashboard'),
                  ),

                FavoriteFilterBar(),
                Expanded(child: FavoriteContent(isMobile: isMobile)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
