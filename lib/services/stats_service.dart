import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks lightweight lifetime stats (games played/won, current and
/// best streak) and persists them locally on-device.
class StatsService extends ChangeNotifier {
  static const _kPlayed = 'stats_played';
  static const _kWon = 'stats_won';
  static const _kStreak = 'stats_streak';
  static const _kBestStreak = 'stats_best_streak';

  SharedPreferences? _prefs;

  int played = 0;
  int won = 0;
  int streak = 0;
  int bestStreak = 0;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    played = _prefs?.getInt(_kPlayed) ?? 0;
    won = _prefs?.getInt(_kWon) ?? 0;
    streak = _prefs?.getInt(_kStreak) ?? 0;
    bestStreak = _prefs?.getInt(_kBestStreak) ?? 0;
    notifyListeners();
  }

  Future<void> recordResult({required bool won}) async {
    played += 1;
    if (won) {
      this.won += 1;
      streak += 1;
      if (streak > bestStreak) bestStreak = streak;
    } else {
      streak = 0;
    }
    await _prefs?.setInt(_kPlayed, played);
    await _prefs?.setInt(_kWon, this.won);
    await _prefs?.setInt(_kStreak, streak);
    await _prefs?.setInt(_kBestStreak, bestStreak);
    notifyListeners();
  }
}
