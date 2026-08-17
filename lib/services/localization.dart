import '../models/app_language.dart';

/// Small hand-rolled string table for the UI chrome (menus, buttons,
/// dialogs). Word lists themselves live under lib/data/, not here.
///
/// This is intentionally simple (a Dart map) rather than Flutter's
/// full intl/ARB pipeline, to keep the project approachable. If the
/// app grows more UI text than this, migrating to flutter_localizations
/// + gen-l10n is the natural next step - the AppLanguage enum this is
/// keyed on will still fit that setup.
class Strings {
  final AppLanguage language;
  const Strings(this.language);

  static const Map<String, Map<AppLanguage, String>> _table = {
    'appTitle': {AppLanguage.en: 'WordDash', AppLanguage.ro: 'WordDash'},
    'chooseCategory': {
      AppLanguage.en: 'Choose a category',
      AppLanguage.ro: 'Alege o categorie',
    },
    'wordsCount': {
      AppLanguage.en: 'words',
      AppLanguage.ro: 'cuvinte',
    },
    'youWon': {AppLanguage.en: 'You got it!', AppLanguage.ro: 'Ai ghicit!'},
    'youLost': {
      AppLanguage.en: 'Out of guesses',
      AppLanguage.ro: 'Ai rămas fără încercări',
    },
    'theWordWas': {
      AppLanguage.en: 'The word was',
      AppLanguage.ro: 'Cuvântul era',
    },
    'playAgain': {
      AppLanguage.en: 'Next word',
      AppLanguage.ro: 'Cuvântul următor',
    },
    'backToCategories': {
      AppLanguage.en: 'Categories',
      AppLanguage.ro: 'Categorii',
    },
    'notEnoughLetters': {
      AppLanguage.en: 'Not enough letters',
      AppLanguage.ro: 'Nu sunt destule litere',
    },
    'notInWordList': {
      AppLanguage.en: 'Not in word list',
      AppLanguage.ro: 'Cuvânt necunoscut',
    },
    'streak': {AppLanguage.en: 'Streak', AppLanguage.ro: 'Serie'},
    'played': {AppLanguage.en: 'Played', AppLanguage.ro: 'Jocuri'},
    'won': {AppLanguage.en: 'Won', AppLanguage.ro: 'Câștigate'},
    'stats': {AppLanguage.en: 'Stats', AppLanguage.ro: 'Statistici'},
    'settings': {AppLanguage.en: 'Settings', AppLanguage.ro: 'Setări'},
    'theme': {AppLanguage.en: 'Theme', AppLanguage.ro: 'Temă'},
    'themeSystem': {AppLanguage.en: 'System', AppLanguage.ro: 'Sistem'},
    'themeLight': {AppLanguage.en: 'Light', AppLanguage.ro: 'Luminos'},
    'themeDark': {AppLanguage.en: 'Dark', AppLanguage.ro: 'Întunecat'},
    'data': {AppLanguage.en: 'Data', AppLanguage.ro: 'Date'},
    'exportStats': {AppLanguage.en: 'Export Stats', AppLanguage.ro: 'Exportă statistici'},
    'importStats': {AppLanguage.en: 'Import Stats', AppLanguage.ro: 'Importă statistici'},
    'statsExported': {AppLanguage.en: 'Stats exported!', AppLanguage.ro: 'Statistici exportate!'},
    'invalidData': {AppLanguage.en: 'Invalid data', AppLanguage.ro: 'Date invalide'},
    'importSuccess': {AppLanguage.en: 'Stats imported!', AppLanguage.ro: 'Statistici importate!'},
  };

  String call(String key) =>
      _table[key]?[language] ?? _table[key]?[AppLanguage.en] ?? key;
}
