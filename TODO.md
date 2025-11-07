# TODO: Perbaikan Filter pada Halaman Popular dan Favorit

## Langkah-langkah yang akan dilakukan:
1. Tambahkan event SortFavoritesEvent di anime_event.dart untuk mengurutkan favorit.
2. Tambahkan properti sortFavoritesAscending di AnimeState untuk menyimpan status urutan favorit.
3. Tambahkan handler untuk SortFavoritesEvent di AnimeBloc.
4. Perbarui popular_page.dart untuk menggunakan BLoC untuk sorting (hapus sorting lokal, gunakan SortByRatingEvent).
5. Perbarui favorite_page.dart untuk menggunakan BLoC untuk sorting favorit (hapus sorting lokal, gunakan SortFavoritesEvent).
6. Perbarui fungsi reset untuk menggunakan event BLoC yang sesuai.
7. Test filter setelah perubahan.

## Status:
- [ ] Tambah SortFavoritesEvent
- [ ] Tambah sortFavoritesAscending ke AnimeState
- [ ] Tambah handler di AnimeBloc
- [ ] Update popular_page.dart
- [ ] Update favorite_page.dart
- [ ] Update reset functions
- [ ] Test filter
