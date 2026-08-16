import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/app_language.dart';
import '../models/letter_status.dart';
import '../models/word_category.dart';
import 'stats_service.dart';

/// Drives a single round and hands out new rounds on demand - this is
/// what makes play unlimited instead of one word per day. Call
/// [startNewRound] again after a round ends (or from a fresh category)
/// to get another random word.
class GameController extends ChangeNotifier {
  final StatsService statsService;
  GameController({required this.statsService});

  static const int maxAttempts = 6;
  final Random _random = Random();

  WordCategory? _category;
  AppLanguage _language = AppLanguage.en;
  late String _targetWord;
  final List<String> _guesses = [];
  final List<List<LetterStatus>> _guessStatuses = [];
  String _currentGuess = '';
  GameStatus _status = GameStatus.playing;
  final Map<String, LetterStatus> _keyboardStatuses = {};
  final List<String> _recentWords = [];
  String? _lastError;

  WordCategory? get category => _category;
  AppLanguage get language => _language;
  int get wordLength => _targetWord.length;
  List<String> get guesses => List.unmodifiable(_guesses);
  List<List<LetterStatus>> get guessStatuses =>
      List.unmodifiable(_guessStatuses);
  String get currentGuess => _currentGuess;
  GameStatus get status => _status;
  Map<String, LetterStatus> get keyboardStatuses =>
      Map.unmodifiable(_keyboardStatuses);
  String get targetWord => _targetWord;
  String? get lastError => _lastError;

  /// Starts a brand new round. Pass [category]/[language] to switch,
  /// or omit them to reroll within the current selection.
  void startNewRound({WordCategory? category, AppLanguage? language}) {
    _category = category ?? _category;
    _language = language ?? _language;
    final pool = _category?.wordsFor(_language) ?? const [];
    if (pool.isEmpty) {
      throw StateError('Category has no words for the selected language.');
    }

    // Avoid repeating the last few words so back-to-back rounds feel
    // fresh; once the pool is nearly exhausted, allow repeats again.
    final avoidCount = min(_recentWords.length, max(0, pool.length - 2));
    final candidates = pool
        .where((w) => !_recentWords.take(avoidCount).contains(w))
        .toList();
    final chosenFrom = candidates.isNotEmpty ? candidates : pool;
    _targetWord = chosenFrom[_random.nextInt(chosenFrom.length)];

    _recentWords.insert(0, _targetWord);
    if (_recentWords.length > 10) _recentWords.removeLast();

    _guesses.clear();
    _guessStatuses.clear();
    _currentGuess = '';
    _status = GameStatus.playing;
    _keyboardStatuses.clear();
    _lastError = null;
    notifyListeners();
  }

  void addLetter(String letter) {
    if (_status != GameStatus.playing) return;
    if (_currentGuess.length >= wordLength) return;
    _currentGuess += letter.toUpperCase();
    _lastError = null;
    notifyListeners();
  }

  void removeLetter() {
    if (_status != GameStatus.playing) return;
    if (_currentGuess.isEmpty) return;
    _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
    notifyListeners();
  }

  void submitGuess() {
    if (_status != GameStatus.playing) return;
    if (_currentGuess.length != wordLength) {
      _lastError = 'notEnoughLetters';
      notifyListeners();
      return;
    }

    final evaluation = _evaluate(_currentGuess, _targetWord);
    _guesses.add(_currentGuess);
    _guessStatuses.add(evaluation);
    _mergeKeyboardStatuses(_currentGuess, evaluation);

    final won = _currentGuess == _targetWord;
    final guessedWord = _currentGuess;
    _currentGuess = '';

    if (won) {
      _status = GameStatus.won;
      statsService.recordResult(won: true);
    } else if (_guesses.length >= maxAttempts) {
      _status = GameStatus.lost;
      statsService.recordResult(won: false);
    }
    _lastError = null;
    notifyListeners();
    // guessedWord kept for potential future use (e.g. share/history).
    assert(guessedWord.length == wordLength);
  }

  /// Standard Wordle-style two-pass evaluation so duplicate letters are
  /// scored correctly (a repeated letter is only marked "present" as
  /// many times as it actually remains in the target word).
  List<LetterStatus> _evaluate(String guess, String target) {
    final result = List<LetterStatus>.filled(target.length, LetterStatus.absent);
    final targetLetters = target.split('');
    final guessLetters = guess.split('');
    final remaining = <String, int>{};

    for (var i = 0; i < target.length; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        result[i] = LetterStatus.correct;
      } else {
        remaining[targetLetters[i]] = (remaining[targetLetters[i]] ?? 0) + 1;
      }
    }
    for (var i = 0; i < guess.length; i++) {
      if (result[i] == LetterStatus.correct) continue;
      final letter = guessLetters[i];
      final left = remaining[letter] ?? 0;
      if (left > 0) {
        result[i] = LetterStatus.present;
        remaining[letter] = left - 1;
      } else {
        result[i] = LetterStatus.absent;
      }
    }
    return result;
  }

  void _mergeKeyboardStatuses(String guess, List<LetterStatus> evaluation) {
    const rank = {
      LetterStatus.absent: 0,
      LetterStatus.present: 1,
      LetterStatus.correct: 2,
      LetterStatus.initial: -1,
    };
    for (var i = 0; i < guess.length; i++) {
      final letter = guess[i];
      final incoming = evaluation[i];
      final existing = _keyboardStatuses[letter] ?? LetterStatus.initial;
      if (rank[incoming]! > rank[existing]!) {
        _keyboardStatuses[letter] = incoming;
      }
    }
  }
}
