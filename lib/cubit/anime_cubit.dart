import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'anime_state.dart';

class AnimeCubit extends Cubit<AnimeState> {
  final Dio dio;

  AnimeCubit(this.dio) : super(AnimeInitial());

  Future<void> fetchRandomAnime() async {
    emit(AnimeLoading());
    try {
      final response = await dio.get('https://api.jikan.moe/v4/random/anime');
      emit(AnimeLoaded([response.data['data']]));
    } catch (e) {
      emit(AnimeError('Failed to fetch random anime: $e'));
    }
  }
}
