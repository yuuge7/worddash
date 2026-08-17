import '../models/app_language.dart';
import '../models/word_category.dart';
import 'words_en_animals.dart';
import 'words_en_general.dart';
import 'words_ro_animals.dart';
import 'words_ro_general.dart';
import 'words_en_food.dart';
import 'words_ro_food.dart';
import 'words_en_nature.dart';
import 'words_ro_nature.dart';
import 'words_en_sports.dart';
import 'words_ro_sports.dart';
import 'words_en_tech.dart';
import 'words_ro_tech.dart';
import 'words_en_places.dart';
import 'words_ro_places.dart';
import 'words_en_countries.dart';
import 'words_ro_countries.dart';
import 'words_cities.dart';

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
  WordCategory(
    id: 'food',
    icon: '🍔',
    displayName: {
      AppLanguage.en: 'Food',
      AppLanguage.ro: 'Mâncare',
    },
    words: {
      AppLanguage.en: wordsEnFood,
      AppLanguage.ro: wordsRoFood,
    },
  ),
  WordCategory(
    id: 'nature',
    icon: '🌲',
    displayName: {
      AppLanguage.en: 'Nature',
      AppLanguage.ro: 'Natură',
    },
    words: {
      AppLanguage.en: wordsEnNature,
      AppLanguage.ro: wordsRoNature,
    },
  ),
  WordCategory(
    id: 'sports',
    icon: '⚽',
    displayName: {
      AppLanguage.en: 'Sports',
      AppLanguage.ro: 'Sporturi',
    },
    words: {
      AppLanguage.en: wordsEnSports,
      AppLanguage.ro: wordsRoSports,
    },
  ),
  WordCategory(
    id: 'tech',
    icon: '💻',
    displayName: {
      AppLanguage.en: 'Tech',
      AppLanguage.ro: 'Tehno',
    },
    words: {
      AppLanguage.en: wordsEnTech,
      AppLanguage.ro: wordsRoTech,
    },
  ),
  WordCategory(
    id: 'places',
    icon: '🌍',
    displayName: {
      AppLanguage.en: 'Places',
      AppLanguage.ro: 'Locuri',
    },
    words: {
      AppLanguage.en: wordsEnPlaces,
      AppLanguage.ro: wordsRoPlaces,
    },
  ),
  WordCategory(
    id: 'countries',
    icon: '🗺️',
    displayName: {
      AppLanguage.en: 'Countries',
      AppLanguage.ro: 'Țări',
    },
    words: {
      AppLanguage.en: wordsEnCountries,
      AppLanguage.ro: wordsRoCountries,
    },
  ),
  WordCategory(
    id: 'cities',
    icon: '🏙️',
    displayName: {
      AppLanguage.en: 'Cities',
      AppLanguage.ro: 'Orașe',
    },
    words: {
      AppLanguage.en: wordsCities,
      AppLanguage.ro: wordsCities,
    },
  ),
];
