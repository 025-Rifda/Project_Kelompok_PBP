import 'package:equatable/equatable.dart';

/// Kelas dasar untuk semua state dari AnimeBloc.
abstract class AnimeState extends Equatable {
  const AnimeState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum data dimuat.
class AnimeInitial extends AnimeState {
  const AnimeInitial();
}

/// State ketika data sedang dimuat.
class AnimeLoading extends AnimeState {
  const AnimeLoading();
}

/// State ketika data berhasil dimuat dan siap ditampilkan.
class AnimeLoaded extends AnimeState {
  final List<dynamic> animeList; // Data utama dari API
  final List<dynamic>? filteredList; // Data hasil filter (optional)
  final String? currentGenre; // Genre yang sedang diterapkan
  final double? minRating; // Rating minimum yang diterapkan
  final bool sortAscending; // Urutan rating (default true)
  final List<dynamic> favorites; // Daftar anime favorit
  final List<Map<String, dynamic>>
  searchHistory; // Riwayat pencarian dengan timestamp

  const AnimeLoaded(
    this.animeList, {
    this.filteredList,
    this.currentGenre,
    this.minRating,
    this.sortAscending = true,
    this.favorites = const [],
    this.searchHistory = const [],
  });

  /// Mengembalikan daftar yang siap ditampilkan ke UI.
  List<dynamic> get displayList => filteredList ?? animeList;

  /// Copy state lama dan ubah sebagian field tanpa bikin objek baru.
  AnimeLoaded copyWith({
    List<dynamic>? animeList,
    List<dynamic>? filteredList,
    String? currentGenre,
    double? minRating,
    bool? sortAscending,
    List<dynamic>? favorites,
    List<Map<String, dynamic>>? searchHistory,
  }) {
    return AnimeLoaded(
      animeList ?? this.animeList,
      filteredList: filteredList ?? this.filteredList,
      currentGenre: currentGenre ?? this.currentGenre,
      minRating: minRating ?? this.minRating,
      sortAscending: sortAscending ?? this.sortAscending,
      favorites: favorites ?? this.favorites,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }

  @override
  List<Object?> get props => [
    animeList,
    filteredList,
    currentGenre,
    minRating,
    sortAscending,
    favorites,
    searchHistory,
  ];
}

/// State ketika terjadi kesalahan (error).
class AnimeError extends AnimeState {
  final String message;

  const AnimeError(this.message);

  @override
  List<Object?> get props => [message];
}
