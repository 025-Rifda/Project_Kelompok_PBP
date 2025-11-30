import '../../../../models/anime_model.dart';

/// Contract that exposes anime-related capabilities to the domain layer.
abstract class AnimeRepository {
  /// Returns the list of top anime.
  Future<List<Anime>> fetchTopAnime();
}
