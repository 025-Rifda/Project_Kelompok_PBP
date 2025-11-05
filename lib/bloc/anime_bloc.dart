import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'anime_event.dart';
import 'anime_state.dart';

class AnimeBloc extends Bloc<AnimeEvent, AnimeState> {
  final Dio dio;
  List<dynamic> _animeList = [];
  List<dynamic> _topAnimeList = [];
  List<dynamic> _favorites = [];
  List<Map<String, dynamic>> _searchHistory = [];

  AnimeBloc(this.dio) : super(AnimeInitial()) {
    on<FetchTopAnimeEvent>(_handleFetchTopAnime);
    on<SearchAnimeEvent>(_handleSearchAnime);
    on<FilterByGenreEvent>(_handleFilterByGenre);
    on<FilterByRatingEvent>(_handleFilterByRating);
    on<SortByRatingEvent>(_handleSortByRating);
    on<AddToFavoritesEvent>(_handleAddToFavorites);
    on<RemoveFromFavoritesEvent>(_handleRemoveFromFavorites);
    on<FetchFavoritesEvent>(_handleFetchFavorites);
    on<AddToHistoryEvent>(_handleAddToHistory);
    on<FetchHistoryEvent>(_handleFetchHistory);
    on<ClearHistoryEvent>(_handleClearHistory);
    on<ResetFilterEvent>(_handleReset);
    on<ResetSettingsEvent>(_handleResetSettings);
  }

  // 🔸 Fungsi umum untuk mengambil data dari API
  Future<List<dynamic>> _fetchAnimeData({
    required String endpoint,
    Map<String, dynamic>? query,
  }) async {
    final response = await dio.get(
      'https://api.jikan.moe/v4/$endpoint',
      queryParameters: query,
    );
    return response.data['data'];
  }

  // 🔸 Fetch anime terpopuler
  Future<void> _handleFetchTopAnime(
    FetchTopAnimeEvent event,
    Emitter<AnimeState> emit,
  ) async {
    emit(AnimeLoading());
    try {
      _topAnimeList = await _fetchAnimeData(endpoint: 'top/anime');
      _animeList = _topAnimeList;
      emit(
        AnimeLoaded(
          _animeList,
          favorites: _favorites,
          searchHistory: _searchHistory,
        ),
      );
    } catch (e) {
      emit(AnimeError('Gagal memuat data: $e'));
    }
  }

  // 🔸 Cari anime berdasarkan nama
  Future<void> _handleSearchAnime(
    SearchAnimeEvent event,
    Emitter<AnimeState> emit,
  ) async {
    await _executeFetch(
      emit,
      () async => _fetchAnimeData(
        endpoint: 'anime',
        query: {'q': event.query, 'limit': 20},
      ),
    );
    // Tambahkan ke riwayat pencarian
    add(AddToHistoryEvent(event.query));
  }

  // 🔸 Fungsi reusable untuk fetch (supaya tidak nulis try-catch berulang)
  Future<void> _executeFetch(
    Emitter<AnimeState> emit,
    Future<List<dynamic>> Function() fetchFunction,
  ) async {
    emit(AnimeLoading());
    try {
      _animeList = await fetchFunction();
      emit(
        AnimeLoaded(
          _animeList,
          favorites: _favorites,
          searchHistory: _searchHistory,
        ),
      );
    } catch (e) {
      emit(AnimeError('Gagal memuat data: $e'));
    }
  }

  // 🔸 Filter berdasarkan genre
  void _handleFilterByGenre(
    FilterByGenreEvent event,
    Emitter<AnimeState> emit,
  ) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;
    final filtered = _animeList.where((anime) {
      final genres = anime['genres'] as List<dynamic>?;
      return genres?.any(
            (g) =>
                g['name'].toString().toLowerCase() == event.genre.toLowerCase(),
          ) ??
          false;
    }).toList();

    emit(
      currentState.copyWith(filteredList: filtered, currentGenre: event.genre),
    );
  }

  // 🔸 Filter berdasarkan rating minimum
  void _handleFilterByRating(
    FilterByRatingEvent event,
    Emitter<AnimeState> emit,
  ) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;
    final filtered = _animeList.where((anime) {
      final score = (anime['score'] ?? 0.0).toDouble();
      return score >= event.minRating;
    }).toList();

    emit(
      currentState.copyWith(filteredList: filtered, minRating: event.minRating),
    );
  }

  // 🔸 Urutkan berdasarkan rating
  void _handleSortByRating(SortByRatingEvent event, Emitter<AnimeState> emit) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;
    final listToSort = currentState.filteredList ?? _animeList;

    final sorted = List<dynamic>.from(listToSort)
      ..sort((a, b) {
        final aScore = (a['score'] ?? 0.0).toDouble();
        final bScore = (b['score'] ?? 0.0).toDouble();
        return event.ascending
            ? aScore.compareTo(bScore)
            : bScore.compareTo(aScore);
      });

    emit(
      currentState.copyWith(
        filteredList: sorted,
        sortAscending: event.ascending,
      ),
    );
  }

  // 🔸 Tambah ke favorit
  void _handleAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<AnimeState> emit,
  ) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;

    // Cek apakah sudah ada di favorit
    final exists = _favorites.any(
      (fav) => fav['mal_id'] == event.anime['mal_id'],
    );
    if (!exists) {
      _favorites.add(event.anime);
      emit(currentState.copyWith(favorites: List.from(_favorites)));
    }
  }

  // 🔸 Hapus dari favorit
  void _handleRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<AnimeState> emit,
  ) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;

    _favorites.removeWhere((fav) => fav['mal_id'].toString() == event.animeId);
    emit(currentState.copyWith(favorites: List.from(_favorites)));
  }

  // 🔸 Ambil daftar favorit
  void _handleFetchFavorites(
    FetchFavoritesEvent event,
    Emitter<AnimeState> emit,
  ) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;
    emit(currentState.copyWith(filteredList: _favorites));
  }

  // 🔸 Tambah ke riwayat pencarian
  void _handleAddToHistory(AddToHistoryEvent event, Emitter<AnimeState> emit) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;

    // Hindari duplikat dan batasi jumlah riwayat
    _searchHistory.removeWhere((item) => item['query'] == event.query);
    _searchHistory.insert(0, {
      'query': event.query,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }

    emit(currentState.copyWith(searchHistory: List.from(_searchHistory)));
  }

  // 🔸 Ambil riwayat pencarian
  void _handleFetchHistory(FetchHistoryEvent event, Emitter<AnimeState> emit) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;
    emit(currentState.copyWith(searchHistory: List.from(_searchHistory)));
  }

  // 🔸 Hapus riwayat pencarian
  void _handleClearHistory(ClearHistoryEvent event, Emitter<AnimeState> emit) {
    if (state is! AnimeLoaded) return;
    final currentState = state as AnimeLoaded;

    _searchHistory.clear();
    emit(currentState.copyWith(searchHistory: []));
  }

  // 🔸 Reset filter dan urutan
  void _handleReset(ResetFilterEvent event, Emitter<AnimeState> emit) {
    if (state is! AnimeLoaded) return;
    emit(
      AnimeLoaded(
        _animeList,
        favorites: _favorites,
        searchHistory: _searchHistory,
      ),
    );
  }

  // 🔸 Reset semua pengaturan
  void _handleResetSettings(
    ResetSettingsEvent event,
    Emitter<AnimeState> emit,
  ) {
    _favorites.clear();
    _searchHistory.clear();
    emit(AnimeLoaded(_animeList, favorites: [], searchHistory: []));
  }
}
