/// The two languages WordDash can be played in.
///
/// Adding a new language later means: add a value here, add its word
/// lists under lib/data/, and add its UI strings in
/// lib/services/localization.dart.
enum AppLanguage {
  en,
  ro;

  String get flagEmoji {
    switch (this) {
      case AppLanguage.en:
        return '🇬🇧';
      case AppLanguage.ro:
        return '🇷🇴';
    }
  }

  String get label {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.ro:
        return 'Română';
    }
  }
}
