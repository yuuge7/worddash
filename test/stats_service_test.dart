import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worddash/data/categories.dart';
import 'package:worddash/models/app_language.dart';
import 'package:worddash/models/word_category.dart';
import 'package:worddash/services/stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  WordCategory byId(String id) => categories.firstWhere((c) => c.id == id);

  test('records stats per category and persists them', () async {
    final stats = StatsService();
    await stats.load();

    await stats.recordResult(
        won: true, guesses: 3, category: byId('animals'), currentLanguage: AppLanguage.en);
    await stats.recordResult(
        won: false, guesses: 6, category: byId('food'), currentLanguage: AppLanguage.en);

    expect(stats.getStatsFor(AppLanguage.en).played, 2);
    expect(stats.getCategoryStatsFor('animals', AppLanguage.en).won, 1);
    expect(stats.getCategoryStatsFor('animals', AppLanguage.en).guessDistribution[3], 1);
    expect(stats.getCategoryStatsFor('food', AppLanguage.en).played, 1);
    expect(stats.getCategoryStatsFor('food', AppLanguage.en).won, 0);
    expect(stats.getCategoryStatsFor('animals', AppLanguage.ro).played, 0);

    final reloaded = StatsService();
    await reloaded.load();
    expect(reloaded.getCategoryStatsFor('animals', AppLanguage.en).won, 1);
    expect(reloaded.getCategoryStatsFor('food', AppLanguage.en).played, 1);
  });

  test('shared word list counts for every language using it', () async {
    final stats = StatsService();
    await stats.load();

    await stats.recordResult(
        won: true, guesses: 2, category: byId('cities'), currentLanguage: AppLanguage.ro);

    expect(stats.getCategoryStatsFor('cities', AppLanguage.en).won, 1);
    expect(stats.getCategoryStatsFor('cities', AppLanguage.ro).won, 1);
  });

  test('export/import round trips category stats', () async {
    final source = StatsService();
    await source.load();
    await source.recordResult(
        won: true, guesses: 4, category: byId('tech'), currentLanguage: AppLanguage.ro);
    final json = source.exportStats();

    SharedPreferences.setMockInitialValues({});
    final target = StatsService();
    await target.load();
    expect(await target.importStats(json), isTrue);
    expect(target.getCategoryStatsFor('tech', AppLanguage.ro).guessDistribution[4], 1);
    expect(target.getStatsFor(AppLanguage.ro).won, 1);
  });
}
