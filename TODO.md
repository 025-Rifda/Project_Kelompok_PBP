- [x] Edit lib/main.dart: Add import for 'package:flutter_web_plugins/url_strategy.dart' and call usePathUrlStrategy() in main()
- [x] Edit lib/core/router.dart: Change routerNeglect to false
>>>>>>> Stashed changes
=======
# TODO: Remove '#' from URLs in Flutter Web App

<<<<<<< Updated upstream
- [x] Edit lib/main.dart: Add import for 'package:flutter_web_plugins/url_strategy.dart' and call usePathUrlStrategy() in main()
- [x] Edit lib/core/router.dart: Change routerNeglect to false
=======
- [x] Edit lib/main.dart: Add import for 'package:flutter_web_plugins/url_strategy.dart' and call usePathUrlStrategy() in main()
- [x] Edit lib/core/router.dart: Change routerNeglect to false
>>>>>>> Stashed changes
=======
## Langkah-langkah yang perlu diselesaikan:

- [x] Tambahkan go_router ke dependencies di pubspec.yaml
- [x] Buat file router.dart untuk konfigurasi GoRouter
- [x] Update main.dart untuk menggunakan GoRouter sebagai router utama
- [x] Update sidebar.dart untuk navigasi menggunakan GoRouter
- [x] Update dashboard_page.dart untuk navigasi ke detail page menggunakan GoRouter
- [x] Update detail_page.dart untuk back navigation menggunakan GoRouter
- [x] Test semua navigasi untuk memastikan berfungsi dengan baik

## Fix Back Button on Detail Page

- [x] Update back button in detail_page.dart to use context.pop() for proper navigation
- [x] Update dashboard_page.dart to use context.push() for detail navigation

## Add Reset to Top Anime Feature

- [x] Add resetToTop parameter to FetchTopAnimeEvent
- [x] Update _handleFetchTopAnime to handle resetToTop flag
- [x] Update sidebar.dart to trigger FetchTopAnimeEvent with resetToTop: true on Dashboard menu tap
- [x] Update dashboard_page.dart mobile drawer to trigger FetchTopAnimeEvent with resetToTop: true on Dashboard menu tap
>>>>>>> Stashed changes
