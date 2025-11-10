<<<<<<< Updated upstream
# TODO: Tambahkan Device Info dengan device_info_plus

## Langkah-langkah yang perlu dilakukan:
- [x] Tambahkan device_info_plus: ^12.1.0 ke dependencies di pubspec.yaml
- [x] Buat file lib/pages/device_info_page.dart untuk halaman informasi perangkat
- [x] Update lib/pages/settings_page.dart: Tambahkan item "Informasi Perangkat" di bagian "Aplikasi"
- [x] Update lib/core/router.dart: Tambahkan route baru untuk 'device-info' di bawah /settings
- [x] Jalankan flutter pub get untuk menginstall dependency baru
- [ ] Test halaman informasi perangkat di device/emulator
=======
- [x] Create lib/services/search_history_service.dart with methods: addQuery, getHistory, removeQuery, clearHistory.
- [x] Update AnimeBloc to load search history on init, use service for add/remove.
- [x] Update settings reset to clear search history via service.
- [x] Fix search history dropdown not disappearing after deleting items.
- [ ] Test persistence after app restart and ensure deleted items stay deleted.
>>>>>>> Stashed changes
