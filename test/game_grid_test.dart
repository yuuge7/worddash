import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worddash/data/categories.dart';
import 'package:worddash/models/app_language.dart';
import 'package:worddash/models/letter_status.dart';
import 'package:worddash/services/game_controller.dart';
import 'package:worddash/widgets/game_grid.dart';

/// The grid is laid out one tile per letter, so the widest word in the
/// data decides whether it still fits. A widget test fails on overflow,
/// which is exactly what we want to catch here.
void main() {
  int longestWord() {
    var longest = 0;
    for (final category in categories) {
      for (final language in AppLanguage.values) {
        for (final word in category.wordsFor(language)) {
          if (word.length > longest) longest = word.length;
        }
      }
    }
    return longest;
  }

  testWidgets('grid renders the longest word without overflowing',
      (tester) async {
    final wordLength = longestWord();
    expect(wordLength, greaterThan(0));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GameGrid(
          wordLength: wordLength,
          maxAttempts: GameController.maxAttempts,
          guesses: const [],
          guessStatuses: const <List<LetterStatus>>[],
          currentGuess: '',
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });
}
