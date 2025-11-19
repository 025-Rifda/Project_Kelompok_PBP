import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_api/bloc/anime_bloc.dart';
import 'package:flutter_application_api/bloc/anime_event.dart';
import 'package:flutter_application_api/bloc/anime_state.dart';

class MockDio extends Mock implements Dio {}

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

  const anotherAnime = {
    'mal_id': 2,
    'title': 'Sample 2',
    'images': {
      'jpg': {'image_url': 'https://example.com/2.jpg'}
    },
    'score': 7.0,
  };

  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockDio = MockDio();
  });

  void arrangeSuccessResponses({
    List<Map<String, dynamic>>? topData,
    List<Map<String, dynamic>>? searchData,
  }) {
    when(
      () => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final path = invocation.positionalArguments.first as String;
      if (path.contains('top/anime')) {
        return _buildResponse(path, topData ?? [sampleAnime]);
      }
      return _buildResponse(path, searchData ?? [anotherAnime]);
    });
  }

  blocTest<AnimeBloc, AnimeState>(
    'FetchTopAnimeEvent emits AnimeLoaded with API data',
    build: () {
      arrangeSuccessResponses(topData: [sampleAnime, anotherAnime]);
      return AnimeBloc(mockDio);
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
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'https://api.jikan.moe/v4/top/anime'),
          message: 'error',
        ),
      );
      return AnimeBloc(mockDio);
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
      return AnimeBloc(mockDio);
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
      arrangeSuccessResponses(searchData: [anotherAnime]);
      return AnimeBloc(mockDio);
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
