import '../../../../models/anime_model.dart';
import '../repositories/anime_repository.dart';

/// Use case that coordinates fetching top anime via the repository.
class FetchTopAnimeUseCase {
  final AnimeRepository repository;

  const FetchTopAnimeUseCase(this.repository);

  Future<List<Anime>> call() => repository.fetchTopAnime();
}
