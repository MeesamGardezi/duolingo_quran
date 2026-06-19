# Quran Journey 🌙

A Duolingo-style Flutter app for learning, understanding, and memorizing the Quran — one ayah at a time.

## Features

- **1 ayah per lesson** — focused, fast, completable in 2 minutes
- **Surahs ordered by length** — start with the shortest (Al-Asr, Al-Kawthar, Al-Ikhlas) and build up
- **4 exercise types per ayah:**
  - **Intro card** — See the Arabic, transliteration, and full English meaning
  - **Word match** — Tap the correct meaning for individual Arabic words
  - **Verse translation** — Pick the correct meaning of the full ayah from 4 options
  - **Fill in the blank** — Identify the missing Arabic word in the ayah
  - **Word order** — Arrange the word meanings in the right sequence
- **XP, streaks, hearts** — just like Duolingo
- **Progress tracking** — per surah, per verse, offline with SharedPreferences
- **All 114 surahs listed** — detailed data for Juz Amma surahs to start

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0

### Run
```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
  main.dart                    # Entry point
  app.dart                     # MaterialApp + Provider setup
  models/
    surah.dart                 # Surah, Verse, QuranWord models
    exercise.dart              # Exercise types + LessonSession
    user_progress.dart         # XP, streaks, per-surah progress
  data/
    quran_repository.dart      # Loads JSON, orders lessons by surah length
  providers/
    app_provider.dart          # State management (ChangeNotifier)
  services/
    exercise_generator.dart    # Generates exercises from verse data
    progress_service.dart      # SharedPreferences persistence
  screens/
    home/
      home_screen.dart         # Lesson path + daily stats
      surah_list_screen.dart   # All 114 surahs view
    lesson/
      lesson_screen.dart       # Main lesson runner
      lesson_complete_screen.dart  # XP + confetti celebration
    exercises/
      exercise_base.dart       # Shared widgets (OptionButton, FeedbackBar)
      translation_match.dart   # Word → meaning exercise
      multiple_choice.dart     # Verse → translation exercise (+ intro)
      fill_in_blank.dart       # Missing word exercise
      word_order.dart          # Arrange meanings exercise
  theme/
    app_theme.dart             # Colors + typography
  widgets/
    arabic_text.dart           # ArabicText + ArabicVerseCard
    progress_bar.dart          # Lesson progress bar + XP bar

assets/
  data/
    surah_info.json            # All 114 surah metadata
    quran_data.json            # Full verse data (currently Juz Amma + Al-Fatiha)
```

## Adding More Quran Data

To add more surahs, add entries to `assets/data/quran_data.json` following the existing structure:

```json
{
  "number": 2,
  "name": "Al-Baqarah",
  "arabicName": "البقرة",
  "meaning": "The Cow",
  "totalVerses": 286,
  "revelationType": "Medinan",
  "verses": [
    {
      "number": 1,
      "arabic": "...",
      "translation": "...",
      "transliteration": "...",
      "words": [
        { "arabic": "...", "transliteration": "...", "meaning": "..." }
      ]
    }
  ]
}
```

The app automatically integrates new surahs into the lesson path sorted by verse count.
