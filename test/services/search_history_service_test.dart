import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_api/services/search_history_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SearchHistoryService', () {
    test('adds query to history at the top with timestamp', () async {
      await SearchHistoryService.addQuery('naruto');
      final history = await SearchHistoryService.getHistory();

      expect(history, isNotEmpty);
      expect(history.first['query'], 'naruto');
      // Validate timestamp format
      final ts = history.first['timestamp'] as String;
      expect(() => DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(ts), returnsNormally);
    });

    test('re-adding query moves it to top and updates timestamp', () async {
      await SearchHistoryService.addQuery('naruto');
      await Future.delayed(const Duration(milliseconds: 5));
      await SearchHistoryService.addQuery('bleach');
      final before = await SearchHistoryService.getHistory();
      final oldTs = before.firstWhere((e) => e['query'] == 'naruto')['timestamp'];

      // Ensure second boundary change for timestamp string format
      await Future.delayed(const Duration(milliseconds: 1100));
      await SearchHistoryService.addQuery('naruto');
      final after = await SearchHistoryService.getHistory();
      expect(after.first['query'], 'naruto');
      expect(after.map((e) => e['query']), contains('bleach'));
      expect(after.first['timestamp'] != oldTs, isTrue);
    });

    test('keeps maximum of 10 items', () async {
      for (var i = 0; i < 12; i++) {
        await SearchHistoryService.addQuery('q$i');
      }
      final history = await SearchHistoryService.getHistory();
      expect(history.length, 10);
      // Most recent should be q11
      expect(history.first['query'], 'q11');
      // Oldest kept should be q2
      expect(history.last['query'], 'q2');
    });

    test('removed query is tracked and not added again', () async {
      await SearchHistoryService.addQuery('one piece');
      await SearchHistoryService.removeQuery('one piece');

      await SearchHistoryService.addQuery('one piece');
      final history = await SearchHistoryService.getHistory();

      expect(history.any((e) => e['query'] == 'one piece'), isFalse);
    });

    test('clearHistory removes history and deleted list', () async {
      await SearchHistoryService.addQuery('naruto');
      await SearchHistoryService.removeQuery('naruto');
      await SearchHistoryService.clearHistory();

      final history = await SearchHistoryService.getHistory();
      final deleted = await SearchHistoryService.getDeletedQueries();
      expect(history, isEmpty);
      expect(deleted, isEmpty);
    });
  });
}
