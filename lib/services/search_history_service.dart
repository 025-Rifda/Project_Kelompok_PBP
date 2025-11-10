import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _searchHistoryKey = 'search_history';
  static const String _deletedQueriesKey = 'deleted_queries';

  // Menambah query ke riwayat pencarian
  static Future<void> addQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    final deletedQueries = await getDeletedQueries();

    // Jika query sudah dihapus sebelumnya, jangan tambah lagi
    if (deletedQueries.contains(query)) return;

    // Hapus jika sudah ada (untuk update timestamp)
    history.removeWhere((item) => item['query'] == query);

    // Tambah ke awal list
    final historyItem = {
      'query': query,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };

    history.insert(0, historyItem);

    // Simpan maksimal 10 item
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setString(_searchHistoryKey, jsonEncode(history));
  }

  // Mendapatkan riwayat pencarian
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_searchHistoryKey);

    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Menghapus query dari riwayat pencarian
  static Future<void> removeQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    final deletedQueries = await getDeletedQueries();

    history.removeWhere((item) => item['query'] == query);
    deletedQueries.add(query);

    await prefs.setString(_searchHistoryKey, jsonEncode(history));
    await prefs.setStringList(_deletedQueriesKey, deletedQueries.toList());
  }

  // Menghapus semua riwayat pencarian
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
    await prefs.remove(_deletedQueriesKey);
  }

  // Mendapatkan daftar query yang sudah dihapus
  static Future<Set<String>> getDeletedQueries() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedList = prefs.getStringList(_deletedQueriesKey) ?? [];
    return Set<String>.from(deletedList);
  }
}
