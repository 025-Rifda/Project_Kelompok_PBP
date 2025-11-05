import 'package:equatable/equatable.dart';

/// Semua event untuk AnimeBloc.
/// Menggunakan [Equatable] agar mudah dibandingkan antar event.
abstract class AnimeEvent extends Equatable {
  const AnimeEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk mengambil daftar anime populer.
class FetchTopAnimeEvent extends AnimeEvent {
  const FetchTopAnimeEvent();
}

/// Event untuk mencari anime berdasarkan query teks.
class SearchAnimeEvent extends AnimeEvent {
  final String query;
  const SearchAnimeEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event untuk memfilter anime berdasarkan genre tertentu.
class FilterByGenreEvent extends AnimeEvent {
  final String genre;
  const FilterByGenreEvent(this.genre);

  @override
  List<Object?> get props => [genre];
}

/// Event untuk memfilter anime berdasarkan rating minimum.
class FilterByRatingEvent extends AnimeEvent {
  final double minRating;
  const FilterByRatingEvent(this.minRating);

  @override
  List<Object?> get props => [minRating];
}

/// Event untuk mengurutkan anime berdasarkan rating.
/// Jika [ascending] true, diurut dari rendah ke tinggi.
class SortByRatingEvent extends AnimeEvent {
  final bool ascending;
  const SortByRatingEvent(this.ascending);

  @override
  List<Object?> get props => [ascending];
}

/// Event untuk menambah anime ke favorit.
class AddToFavoritesEvent extends AnimeEvent {
  final dynamic anime;
  const AddToFavoritesEvent(this.anime);

  @override
  List<Object?> get props => [anime];
}

/// Event untuk menghapus anime dari favorit.
class RemoveFromFavoritesEvent extends AnimeEvent {
  final String animeId;
  const RemoveFromFavoritesEvent(this.animeId);

  @override
  List<Object?> get props => [animeId];
}

/// Event untuk mengambil daftar favorit.
class FetchFavoritesEvent extends AnimeEvent {
  const FetchFavoritesEvent();
}

/// Event untuk menambah ke riwayat pencarian.
class AddToHistoryEvent extends AnimeEvent {
  final String query;
  const AddToHistoryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event untuk mengambil riwayat pencarian.
class FetchHistoryEvent extends AnimeEvent {
  const FetchHistoryEvent();
}

/// Event untuk menghapus riwayat pencarian.
class ClearHistoryEvent extends AnimeEvent {
  const ClearHistoryEvent();
}

/// Event untuk mereset filter dan urutan ke data awal.
class ResetFilterEvent extends AnimeEvent {
  const ResetFilterEvent();
}

/// Event untuk mereset semua pengaturan (favorit, riwayat, dll.).
class ResetSettingsEvent extends AnimeEvent {
  const ResetSettingsEvent();
}
