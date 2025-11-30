import '../../../../models/anime_model.dart';
import '../../domain/repositories/anime_repository.dart';
import '../datasources/anime_remote_data_source.dart';

/// Concrete repository that delegates to the remote data source.
class AnimeRepositoryImpl implements AnimeRepository {
  final AnimeRemoteDataSource remoteDataSource;

  AnimeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Anime>> fetchTopAnime() => remoteDataSource.fetchTopAnime();
}
