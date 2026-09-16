import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_language.dart';
import '../models/word_category.dart';

class GameStats {
  int played = 0;
  int won = 0;
  int streak = 0;
  int bestStreak = 0;
  Map<int, int> guessDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

  GameStats();

  GameStats.fromJson(Map<String, dynamic> json) {
    played = json['played'] as int? ?? 0;
    won = json['won'] as int? ?? 0;
    streak = json['streak'] as int? ?? 0;
    bestStreak = json['bestStreak'] as int? ?? 0;
    if (json['guessDistribution'] is Map) {
      final dist = json['guessDistribution'] as Map;
      for (var i = 1; i <= 6; i++) {
        guessDistribution[i] = dist[i.toString()] as int? ?? 0;
      }
    }
  }

  int get winRate => played > 0 ? (won / played * 100).round() : 0;

  void record({required bool won, required int guesses}) {
    played += 1;
    if (won) {
      this.won += 1;
      streak += 1;
      if (streak > bestStreak) bestStreak = streak;

      if (guesses >= 1 && guesses <= 6) {
        guessDistribution[guesses] = (guessDistribution[guesses] ?? 0) + 1;
      }
    } else {
      streak = 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'played': played,
      'won': won,
      'streak': streak,
      'bestStreak': bestStreak,
      'guessDistribution': guessDistribution.map((k, v) => MapEntry(k.toString(), v)),
    };
  }
}

/// Tracks lifetime stats (games played/won, streaks, guess distributions)
/// per language overall and per category within each language, and
/// persists them locally on-device.
class StatsService extends ChangeNotifier {
  static const _languagePrefix = 'stats_v2_';
  static const _categoryPrefix = 'stats_v2_cat_';

  SharedPreferences? _prefs;

  final Map<AppLanguage, GameStats> _stats = {
    for (var lang in AppLanguage.values) lang: GameStats(),
  };

  /// categoryId -> language -> stats. Only holds categories that have
  /// been played (or imported).
  final Map<String, Map<AppLanguage, GameStats>> _categoryStats = {};

  GameStats getStatsFor(AppLanguage language) => _stats[language]!;

  GameStats getCategoryStatsFor(String categoryId, AppLanguage language) =>
      _categoryStats[categoryId]?[language] ?? GameStats();

  static String _languageKey(AppLanguage lang) => '$_languagePrefix${lang.name}';

  static String _categoryKey(String categoryId, AppLanguage lang) =>
      '$_categoryPrefix${categoryId}_${lang.name}';

  static GameStats _decode(String jsonStr) {
    try {
      return GameStats.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      // Fallback to empty if corrupt
      return GameStats();
    }
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    for (var lang in AppLanguage.values) {
      final jsonStr = _prefs?.getString(_languageKey(lang));
      _stats[lang] = jsonStr != null ? _decode(jsonStr) : GameStats();
    }

    _categoryStats.clear();
    final languagesByName = AppLanguage.values.asNameMap();
    for (final key in _prefs?.getKeys() ?? const <String>{}) {
      if (!key.startsWith(_categoryPrefix)) continue;
      // Key is stats_v2_cat_<categoryId>_<lang>; split on the last '_'
      // so category ids may contain underscores.
      final rest = key.substring(_categoryPrefix.length);
      final sep = rest.lastIndexOf('_');
      if (sep <= 0) continue;
      final lang = languagesByName[rest.substring(sep + 1)];
      final jsonStr = _prefs?.getString(key);
      if (lang == null || jsonStr == null) continue;
      _categoryStats.putIfAbsent(rest.substring(0, sep), () => {})[lang] =
          _decode(jsonStr);
    }
    notifyListeners();
  }

  Future<void> recordResult({
    required bool won,
    required int guesses,
    required WordCategory category,
    required AppLanguage currentLanguage,
  }) async {
    final currentWords = category.words[currentLanguage];
    if (currentWords == null) return; // Should not happen

    for (var lang in AppLanguage.values) {
      // If the category supports this language AND its word list is identical
      // to the current language's word list, update its stats too!
      if (category.words[lang] != null && category.words[lang] == currentWords) {
        final stat = _stats[lang]!;
        stat.record(won: won, guesses: guesses);
        await _prefs?.setString(_languageKey(lang), jsonEncode(stat.toJson()));

        final catStat = _categoryStats
            .putIfAbsent(category.id, () => {})
            .putIfAbsent(lang, GameStats.new);
        catStat.record(won: won, guesses: guesses);
        await _prefs?.setString(
            _categoryKey(category.id, lang), jsonEncode(catStat.toJson()));
      }
    }
    notifyListeners();
  }

  String exportStats() {
    final Map<String, dynamic> data = {};
    for (var lang in AppLanguage.values) {
      data[lang.name] = _stats[lang]!.toJson();
    }
    data['categories'] = {
      for (final cat in _categoryStats.entries)
        cat.key: {
          for (final entry in cat.value.entries)
            entry.key.name: entry.value.toJson(),
        },
    };
    return jsonEncode(data);
  }

  Future<bool> importStats(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr);
      if (data is Map<String, dynamic>) {
        bool importedAny = false;
        for (var lang in AppLanguage.values) {
          if (data.containsKey(lang.name)) {
            _stats[lang] = GameStats.fromJson(data[lang.name] as Map<String, dynamic>);
            await _prefs?.setString(_languageKey(lang), jsonEncode(_stats[lang]!.toJson()));
            importedAny = true;
          }
        }

        // Older exports have no 'categories' section; keep current
        // category stats in that case.
        final cats = data['categories'];
        if (cats is Map<String, dynamic>) {
          final languagesByName = AppLanguage.values.asNameMap();
          for (final cat in cats.entries) {
            if (cat.value is! Map<String, dynamic>) continue;
            for (final entry in (cat.value as Map<String, dynamic>).entries) {
              final lang = languagesByName[entry.key];
              if (lang == null) continue;
              final stat = GameStats.fromJson(entry.value as Map<String, dynamic>);
              _categoryStats.putIfAbsent(cat.key, () => {})[lang] = stat;
              await _prefs?.setString(
                  _categoryKey(cat.key, lang), jsonEncode(stat.toJson()));
              importedAny = true;
            }
          }
        }

        if (importedAny) {
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // JSON parse error or type error
    }
    return false;
  }
}
