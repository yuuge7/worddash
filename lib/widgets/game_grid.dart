import 'package:flutter/material.dart';

import '../models/letter_status.dart';
import 'letter_tile.dart';

/// Renders the full guess grid: completed guesses, the row currently
/// being typed, and empty rows for remaining attempts.
class GameGrid extends StatelessWidget {
  final int wordLength;
  final int maxAttempts;
  final List<String> guesses;
  final List<List<LetterStatus>> guessStatuses;
  final String currentGuess;

  const GameGrid({
    super.key,
    required this.wordLength,
    required this.maxAttempts,
    required this.guesses,
    required this.guessStatuses,
    required this.currentGuess,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var r = 0; r < maxAttempts; r++) {
      if (r < guesses.length) {
        rows.add(_row(guesses[r].split(''), guessStatuses[r]));
      } else if (r == guesses.length) {
        final letters = List<String>.generate(
          wordLength,
          (i) => i < currentGuess.length ? currentGuess[i] : '',
        );
        rows.add(_row(letters, List.filled(wordLength, LetterStatus.initial)));
      } else {
        rows.add(_row(List.filled(wordLength, ''),
            List.filled(wordLength, LetterStatus.initial)));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }

  Widget _row(List<String> letters, List<LetterStatus> statuses) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        letters.length,
        (i) => LetterTile(letter: letters[i], status: statuses[i]),
      ),
    );
  }
}
