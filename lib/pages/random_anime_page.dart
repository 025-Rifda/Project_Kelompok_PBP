import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../cubit/anime_cubit.dart';
import '../cubit/anime_state.dart';
import '../models/anime_model.dart';
import '../widgets/media_card.dart';

class RandomAnimePage extends StatelessWidget {
  const RandomAnimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocProvider(
      create: (context) => AnimeCubit(context.read<Dio>())..fetchRandomAnime(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Anime Random',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: BlocBuilder<AnimeCubit, AnimeState>(
          builder: (context, state) {
            if (state is AnimeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnimeLoaded) {
              final anime = Anime.fromJson(state.animeList.first);
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Anime Acak untuk Kamu!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: isMobile
                          ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return MediaCard(
                                  item: anime,
                                  onTap: () =>
                                      context.go('/detail/${anime.malId}'),
                                );
                              },
                            )
                          : ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: SizedBox(
                                    width: 300,
                                    child: MediaCard(
                                      item: anime,
                                      onTap: () =>
                                          context.go('/detail/${anime.malId}'),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<AnimeCubit>().fetchRandomAnime(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AnimeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<AnimeCubit>().fetchRandomAnime(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Welcome to Random Anime'));
          },
        ),
      ),
    );
  }
}
