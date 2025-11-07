import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_model.dart';

class HistoryService {
  static const String _historyKey = 'anime_history';

  // Menambah anime ke history
  static Future<void> addToHistory(Anime anime) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Hapus jika sudah ada (untuk update timestamp)
    history.removeWhere((item) => item['mal_id'] == anime.malId);

    // Tambah ke awal list
    final historyItem = {
      'mal_id': anime.malId,
      'title': anime.title,
      'image_url': anime.imageUrl,
      'score': anime.score,
      'year': anime.year,
      'genres': anime.genres,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };

    history.insert(0, historyItem);

    // Simpan maksimal 50 item
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Mendapatkan history
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);

    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Menghapus item dari history
  static Future<void> removeFromHistory(int malId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.removeWhere((item) => item['mal_id'] == malId);
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Menghapus semua history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Mengecek apakah anime sudah ada di history
  static Future<bool> isInHistory(int malId) async {
    final history = await getHistory();
    return history.any((item) => item['mal_id'] == malId);
  }
}
