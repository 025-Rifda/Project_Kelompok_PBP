import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_api/bloc/anime_bloc.dart';
import 'package:flutter_application_api/bloc/anime_event.dart';
import 'package:flutter_application_api/bloc/anime_state.dart';
import 'package:flutter_application_api/features/anime/domain/usecases/fetch_top_anime.dart';
import 'package:flutter_application_api/models/anime_model.dart';

class MockDio extends Mock implements Dio {}
class MockFetchTopAnimeUseCase extends Mock implements FetchTopAnimeUseCase {}

Response<dynamic> _buildResponse(String path, List<Map<String, dynamic>> data) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: {'data': data},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleAnime = {
    'mal_id': 1,
    'title': 'Sample 1',
    'images': {
      'jpg': {'image_url': 'https://example.com/1.jpg'}
    },
    'score': 8.5,
  };

  const sampleAnimeModel = Anime(
    malId: 1,
    title: 'Sample 1',
    imageUrl: 'https://example.com/1.jpg',
    score: 8.5,
  );

  const anotherAnime = {
    'mal_id': 2,
    'title': 'Sample 2',
    'images': {
      'jpg': {'image_url': 'https://example.com/2.jpg'}
    },
    'score': 7.0,
  };

  const anotherAnimeModel = Anime(
    malId: 2,
    title: 'Sample 2',
    imageUrl: 'https://example.com/2.jpg',
    score: 7.0,
  );

  late MockDio mockDio;
  late MockFetchTopAnimeUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockDio = MockDio();
    mockUseCase = MockFetchTopAnimeUseCase();
  });

  void arrangeSearchResponses({List<Map<String, dynamic>>? data}) {
    when(
      () => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) {
      final path = invocation.positionalArguments.first as String;
      return Future.value(_buildResponse(path, data ?? [anotherAnime]));
    });
  }

  blocTest<AnimeBloc, AnimeState>(
    'FetchTopAnimeEvent emits AnimeLoaded with API data',
    build: () {
      when(() => mockUseCase()).thenAnswer(
        (_) async => [sampleAnimeModel, anotherAnimeModel],
      );
      return AnimeBloc(mockDio, mockUseCase);
    },
    act: (bloc) => bloc.add(const FetchTopAnimeEvent()),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<AnimeLoading>(),
      isA<AnimeLoaded>().having(
        (state) => state.animeList.length,
        'top list length',
        2,
      ),
    ],
  );

  blocTest<AnimeBloc, AnimeState>(
    'FetchTopAnimeEvent emits AnimeError when request fails',
    build: () {
      when(() => mockUseCase()).thenThrow(Exception('error'));
      return AnimeBloc(mockDio, mockUseCase);
    },
    act: (bloc) => bloc.add(const FetchTopAnimeEvent()),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<AnimeLoading>(),
      isA<AnimeError>(),
    ],
  );

  blocTest<AnimeBloc, AnimeState>(
    'AddToFavoritesEvent and RemoveFromFavoritesEvent update favorites list',
    build: () {
      return AnimeBloc(mockDio, mockUseCase);
    },
    seed: () => const AnimeLoaded([sampleAnime]),
    act: (bloc) async {
      bloc.add(const AddToFavoritesEvent(sampleAnime));
      bloc.add(RemoveFromFavoritesEvent(sampleAnime['mal_id'].toString()));
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<AnimeLoaded>().having(
        (state) => state.favorites.length,
        'favorites count after add',
        1,
      ),
      isA<AnimeLoaded>().having(
        (state) => state.favorites.length,
        'favorites count after remove',
        0,
      ),
    ],
  );

  blocTest<AnimeBloc, AnimeState>(
    'SearchAnimeEvent stores query into search history',
    build: () {
      arrangeSearchResponses(data: [anotherAnime]);
      return AnimeBloc(mockDio, mockUseCase);
    },
    act: (bloc) async {
      bloc.add(const SearchAnimeEvent('naruto'));
    },
    wait: const Duration(milliseconds: 150),
    expect: () => [
      isA<AnimeLoading>(),
      isA<AnimeLoaded>()
          .having((state) => state.animeList.length, 'results', 1)
          .having(
            (state) => state.searchHistory.map((e) => e['query']).toList(),
            'history queries',
            contains('naruto'),
          ),
    ],
  );
}
