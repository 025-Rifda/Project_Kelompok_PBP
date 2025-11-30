import 'package:flutter_application_api/features/anime/domain/repositories/anime_repository.dart';
import 'package:flutter_application_api/features/anime/domain/usecases/fetch_top_anime.dart';
import 'package:flutter_application_api/models/anime_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnimeRepository extends Mock implements AnimeRepository {}

void main() {
  late _MockAnimeRepository mockRepository;
  late FetchTopAnimeUseCase useCase;

  const sampleAnime = Anime(
    malId: 1,
    title: 'Test Anime',
    imageUrl: 'https://example.com/test.png',
    score: 9.0,
  );

  setUp(() {
    mockRepository = _MockAnimeRepository();
    useCase = FetchTopAnimeUseCase(mockRepository);
  });

  test('calls repository to fetch top anime', () async {
    when(() => mockRepository.fetchTopAnime())
        .thenAnswer((_) async => const [sampleAnime]);

    final result = await useCase();

    expect(result, const [sampleAnime]);
    verify(() => mockRepository.fetchTopAnime()).called(1);
  });

  test('propagates repository error', () async {
    final exception = Exception('failed');
    when(() => mockRepository.fetchTopAnime()).thenThrow(exception);

    expect(() => useCase(), throwsA(exception));
  });
}
