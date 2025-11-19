# Fitur Hapus Riwayat Pencarian dan Sinkronisasi

## Tujuan
Membuat fitur agar pengguna dapat menghapus salah satu entri riwayat pencarian, dan ketika menekan kembali search bar, daftar riwayat yang muncul sudah tersinkron (entri yang dihapus tidak muncul lagi kecuali melakukan pencarian baru).

## Masalah yang Ditemukan
- Saat menghapus satu riwayat, riwayat lainnya ikut terhapus (bug UI/state).
- Saat menekan kembali search bar setelah hapus, entri yang dihapus muncul lagi (sinkronisasi tidak sempurna).
- Saat menekan item riwayat, tidak melakukan pencarian (tidak menuju ke hasil pencarian).

## Langkah-langkah Implementasi
- [ ] Modifikasi `anime_bloc.dart` untuk memuat ulang riwayat dari service setelah penghapusan, memastikan sinkronisasi.
- [ ] Modifikasi `dashboard_page.dart` untuk menggunakan dialog konfirmasi penghapusan riwayat.
- [ ] Modifikasi `dashboard_page.dart` untuk memperbaiki onTap item riwayat agar melakukan pencarian seperti input manual.
- [ ] Modifikasi `_onSearch` di `dashboard_page.dart` untuk menambahkan parameter `clearAfter` agar tidak selalu clear controller.
- [ ] Test fitur: hapus satu riwayat, tekan kembali search bar, pastikan entri hilang; tekan item riwayat, pastikan pencarian berjalan.

## File yang Akan Diedit
- `lib/bloc/anime_bloc.dart`
- `lib/pages/dashboard_page.dart`
