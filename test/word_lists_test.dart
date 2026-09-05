import 'package:flutter_test/flutter_test.dart';
import 'package:worddash/data/categories.dart';
import 'package:worddash/models/app_language.dart';

/// Guards the word data itself. The on-screen keyboard only offers A-Z,
/// so any word containing something else would be unguessable, and the
/// grid is laid out per-letter so lengths have to stay sane.
void main() {
  final wordPattern = RegExp(r'^[A-Z]{4,8}$');

  for (final category in categories) {
    for (final language in AppLanguage.values) {
      final words = category.wordsFor(language);
      if (words.isEmpty) continue;

      test('${category.id}/${language.name}: words are A-Z, 4-9 letters', () {
        final bad = words.where((w) => !wordPattern.hasMatch(w)).toList();
        expect(bad, isEmpty, reason: 'unusable words: $bad');
      });

      test('${category.id}/${language.name}: no duplicate words', () {
        final seen = <String>{};
        final dupes = words.where((w) => !seen.add(w)).toList();
        expect(dupes, isEmpty, reason: 'duplicate words: $dupes');
      });
    }
  }

  test('every category supports both languages', () {
    for (final category in categories) {
      for (final language in AppLanguage.values) {
        expect(category.supports(language), isTrue,
            reason: '${category.id} has no words for ${language.name}');
      }
    }
  });
}
