import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'anime_state.dart';

class AnimeCubit extends Cubit<AnimeState> {
  final Dio dio;

  AnimeCubit(this.dio) : super(AnimeInitial());

  Future<void> fetchRandomAnime() async {
    emit(AnimeLoading());

    try {
      List<dynamic> animeData = [];

      // Loop sampai dapat 3 anime yang aman
      while (animeData.length < 3) {
        final response = await dio.get('https://api.jikan.moe/v4/random/anime');

        final data = response.data['data'];

        final rating = data['rating'] ?? '';

        // Filter anime DEWASA
        final bool isAdult = rating.contains('R+') || rating.contains('Rx');

        // Jika rating dewasa → skip dan ambil lagi
        if (isAdult) {
          continue;
        }

        // Lolos filter → tambahkan
        animeData.add(data);
      }

      emit(AnimeLoaded(animeData));
    } catch (e) {
      emit(AnimeError('Failed to fetch random anime: $e'));
    }
  }
}
