import 'app_language.dart';

/// A themed pack of words (a "niche"), available in one or more languages.
///
/// To add a new category: create a words file under lib/data/ for each
/// language you support, then register a WordCategory for it in
/// lib/data/categories.dart. Nothing else needs to change - the home
/// screen and game screen both read from the category list.
class WordCategory {
  final String id;
  final String icon;
  final Map<AppLanguage, String> displayName;
  final Map<AppLanguage, List<String>> words;

  const WordCategory({
    required this.id,
    required this.icon,
    required this.displayName,
    required this.words,
  });

  /// Whether this category has any words available for [language].
  bool supports(AppLanguage language) =>
      (words[language]?.isNotEmpty ?? false);

  String nameFor(AppLanguage language) =>
      displayName[language] ?? displayName[AppLanguage.en] ?? id;

  List<String> wordsFor(AppLanguage language) => words[language] ?? const [];
}
