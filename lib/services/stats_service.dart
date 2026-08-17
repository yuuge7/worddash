import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_language.dart';
import '../models/word_category.dart';

class LanguageStats {
  int played = 0;
  int won = 0;
  int streak = 0;
  int bestStreak = 0;
  Map<int, int> guessDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

  LanguageStats();

  LanguageStats.fromJson(Map<String, dynamic> json) {
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
/// separated by language, and persists them locally on-device.
class StatsService extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  final Map<AppLanguage, LanguageStats> _stats = {
    for (var lang in AppLanguage.values) lang: LanguageStats(),
  };

  LanguageStats getStatsFor(AppLanguage language) => _stats[language]!;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    
    for (var lang in AppLanguage.values) {
      final jsonStr = _prefs?.getString('stats_v2_${lang.name}');
      if (jsonStr != null) {
        try {
          _stats[lang] = LanguageStats.fromJson(jsonDecode(jsonStr));
        } catch (e) {
          // Fallback to empty if corrupt
          _stats[lang] = LanguageStats();
        }
      } else {
        _stats[lang] = LanguageStats();
      }
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
        stat.played += 1;
        if (won) {
          stat.won += 1;
          stat.streak += 1;
          if (stat.streak > stat.bestStreak) stat.bestStreak = stat.streak;
          
          if (guesses >= 1 && guesses <= 6) {
            stat.guessDistribution[guesses] = (stat.guessDistribution[guesses] ?? 0) + 1;
          }
        } else {
          stat.streak = 0;
        }
        
        await _prefs?.setString('stats_v2_${lang.name}', jsonEncode(stat.toJson()));
      }
    }
    notifyListeners();
  }

  String exportStats() {
    final Map<String, dynamic> data = {};
    for (var lang in AppLanguage.values) {
      data[lang.name] = _stats[lang]!.toJson();
    }
    return jsonEncode(data);
  }

  Future<bool> importStats(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr);
      if (data is Map<String, dynamic>) {
        bool importedAny = false;
        for (var lang in AppLanguage.values) {
          if (data.containsKey(lang.name)) {
            _stats[lang] = LanguageStats.fromJson(data[lang.name] as Map<String, dynamic>);
            await _prefs?.setString('stats_v2_${lang.name}', jsonEncode(_stats[lang]!.toJson()));
            importedAny = true;
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
