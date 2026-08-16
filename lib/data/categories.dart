import '../models/app_language.dart';
import '../models/word_category.dart';
import 'words_en_animals.dart';
import 'words_en_general.dart';
import 'words_ro_animals.dart';
import 'words_ro_general.dart';

/// Every category available in the game. This is the single place you
/// touch to add a new niche - see README.md "Adding words or a
/// category" for the full walkthrough.
final List<WordCategory> categories = [
  WordCategory(
    id: 'general',
    icon: '🔤',
    displayName: {
      AppLanguage.en: 'General',
      AppLanguage.ro: 'General',
    },
    words: {
      AppLanguage.en: wordsEnGeneral,
      AppLanguage.ro: wordsRoGeneral,
    },
  ),
  WordCategory(
    id: 'animals',
    icon: '🐾',
    displayName: {
      AppLanguage.en: 'Animals',
      AppLanguage.ro: 'Animale',
    },
    words: {
      AppLanguage.en: wordsEnAnimals,
      AppLanguage.ro: wordsRoAnimals,
    },
  ),
];
