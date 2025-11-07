abstract class AnimeState {}

class AnimeInitial extends AnimeState {}

class AnimeLoading extends AnimeState {}

class AnimeLoaded extends AnimeState {
  final List<dynamic> animeList;
  AnimeLoaded(this.animeList);

  dynamic get animeData => animeList.isNotEmpty ? animeList.first : null;
}

class AnimeError extends AnimeState {
  final String message;
  AnimeError(this.message);
}
