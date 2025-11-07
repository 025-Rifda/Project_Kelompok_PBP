# TODO: Tambahkan Halaman Login dan Register Setelah Splash

## Langkah-langkah Implementasi:
- [x] Buat halaman login (`lib/pages/login_page.dart`) dengan field username, password, tombol login, dan opsi register
- [x] Buat halaman register (`lib/pages/register_page.dart`) dengan field username, email, password, konfirmasi password, dan tombol register
- [x] Update router (`lib/core/router.dart`) untuk menambahkan rute '/login' dan '/register'
- [x] Modifikasi splash page (`lib/pages/splash_page.dart`) untuk navigasi ke '/login' alih-alih '/dashboard'
- [x] Test alur aplikasi: Splash -> Login -> Dashboard (atau Register -> Login -> Dashboard)
- [x] Tambahkan SharedPreferences untuk menyimpan username setelah login
- [x] Update dashboard untuk menampilkan username yang disimpan
