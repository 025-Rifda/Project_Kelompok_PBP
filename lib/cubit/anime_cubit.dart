import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'anime_state.dart';

class AnimeCubit extends Cubit<AnimeState> {
  final Dio dio;

  AnimeCubit(this.dio) : super(AnimeInitial());

  Future<void> fetchTopAnime() async {
    emit(AnimeLoading());
    try {
      final response = await dio.get('https://api.jikan.moe/v4/top/anime');
      final data = response.data['data'];
      emit(AnimeLoaded(data));
    } catch (e) {
      emit(AnimeError(e.toString()));
    }
  }

  Future<void> searchAnime(String query) async {
    emit(AnimeLoading());
    try {
      final response = await dio.get(
        'https://api.jikan.moe/v4/anime',
        queryParameters: {'q': query, 'limit': 20},
      );
      final data = response.data['data'];
      emit(AnimeLoaded(data));
    } catch (e) {
      emit(AnimeError(e.toString()));
    }
  }
}
