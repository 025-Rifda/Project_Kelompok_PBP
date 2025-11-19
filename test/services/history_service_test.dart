import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_api/services/history_service.dart';
import 'package:flutter_application_api/models/anime_model.dart';

void main() {
  const anime = Anime(
    malId: 1,
    title: 'Test Anime',
    imageUrl: 'https://example.com/image.jpg',
    score: 8.5,
    year: 2023,
    synopsis: 'Synopsis',
    genres: ['Action', 'Drama'],
  );

  const anotherAnime = Anime(
    malId: 2,
    title: 'Another Anime',
    imageUrl: 'https://example.com/another.jpg',
    score: 7.5,
    year: 2022,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryService', () {
    test('addToHistory inserts at top with timestamp and caps at 50', () async {
      await HistoryService.addToHistory(anime);
      final history = await HistoryService.getHistory();

      expect(history, isNotEmpty);
      expect(history.first['mal_id'], anime.malId);
      expect(history.first['title'], anime.title);
      final ts = history.first['timestamp'] as String;
      expect(() => DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(ts), returnsNormally);

      for (var i = 0; i < 60; i++) {
        await HistoryService.addToHistory(Anime(
          malId: i + 3,
          title: 'Anime $i',
          imageUrl: 'url-$i',
        ));
      }
      final capped = await HistoryService.getHistory();
      expect(capped.length, 50);
    });

    test('re-adding anime moves to top and updates timestamp', () async {
      await HistoryService.addToHistory(anime);
      await Future.delayed(const Duration(milliseconds: 5));
      await HistoryService.addToHistory(anotherAnime);
      final historyBefore = await HistoryService.getHistory();
      final oldTs =
          historyBefore.firstWhere((item) => item['mal_id'] == anime.malId)['timestamp'];

      await Future.delayed(const Duration(milliseconds: 1100));
      await HistoryService.addToHistory(anime);
      final historyAfter = await HistoryService.getHistory();

      expect(historyAfter.first['mal_id'], anime.malId);
      expect(historyAfter.first['timestamp'] != oldTs, isTrue);
      expect(historyAfter.any((item) => item['mal_id'] == anotherAnime.malId), isTrue);
    });

    test('removeFromHistory deletes specific entry', () async {
      await HistoryService.addToHistory(anime);
      await HistoryService.addToHistory(anotherAnime);

      await HistoryService.removeFromHistory(anime.malId);
      final history = await HistoryService.getHistory();
      expect(history.any((item) => item['mal_id'] == anime.malId), isFalse);
      expect(history.any((item) => item['mal_id'] == anotherAnime.malId), isTrue);
    });

    test('clearHistory empties the storage', () async {
      await HistoryService.addToHistory(anime);
      await HistoryService.clearHistory();
      final history = await HistoryService.getHistory();
      expect(history, isEmpty);
    });

    test('isInHistory reports presence correctly', () async {
      await HistoryService.addToHistory(anime);
      expect(await HistoryService.isInHistory(anime.malId), isTrue);
      expect(await HistoryService.isInHistory(999), isFalse);
    });
  });
}
