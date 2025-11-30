import 'package:dio/dio.dart';

import '../../../../models/anime_model.dart';

/// Remote data source responsible for calling the Jikan API.
abstract class AnimeRemoteDataSource {
  Future<List<Anime>> fetchTopAnime();
}

class AnimeRemoteDataSourceImpl implements AnimeRemoteDataSource {
  final Dio client;

  AnimeRemoteDataSourceImpl(this.client);

  @override
  Future<List<Anime>> fetchTopAnime() async {
    final response = await client.get('https://api.jikan.moe/v4/top/anime');
    final rawList = (response.data['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return rawList.map(Anime.fromJson).toList();
  }
}
