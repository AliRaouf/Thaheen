# Thaheen: Mini Offline LMS

A small, Arabic-first student app for Thaheen (ذهين): browse courses, open a course, and watch its video lessons with saved progress, sequential unlocking and auto-completion at 90%. Everything runs offline from bundled assets.

- **APK:** [Download from Google Drive](https://drive.google.com/file/d/1Mhy4M-YsNWvQfLPFd7BNVy3sOvJxU_bx/view?usp=sharing)
- **Time spent:** about 5 hours

## Running it

Requires Flutter stable (built with 3.47.5, Dart ^3.13).

```bash
flutter pub get
flutter run          # iOS simulator or Android emulator
flutter test         # unit tests for the progress rules and the player cubit
```

No setup, keys or network are needed. The catalogue (`assets/data/courses.json`), the videos (`assets/videos/`), the fonts and the translations are all bundled.

## What's in it

| Requirement | Where |
|---|---|
| Courses list with thumbnail, title, instructor, lesson count, progress % | `features/courses` |
| "Continue watching" card for the latest unfinished lesson | `ContinueCard`, `continueWatching()` |
| Sections and lessons with duration and status | `features/course_details`, `LessonRow` |
| Sequential unlock across section boundaries, friendly message on a locked tap | `lessonStatuses()`, `showAppSnackBar` |
| Play/pause, ±10 s, seek bar, time/duration, 1x–2x speed | `features/video_player/presentation/widgets` |
| Fullscreen landscape, same position | `fullscreen.dart` |
| Resume from the last position | `VideoPlayerCubit.load` |
| Auto-complete at 90%, "Next lesson" respects the unlock rule | `reachedCompletion()`, `VideoPlayerReady.canGoNext` |
| Progress survives restarts | `PrefsProgressRepository` |
| Arabic RTL, Arabic/English switch | `easy_localization`, `assets/translations` |
| Loading, empty and error states (no red screens) | `StateView`, player error frame |
| Unit tests for the 90%, unlock and progress % rules | `test/progress_test.dart` |

Bonus items done: dark mode, the Arabic/English switch, and remembering the last playback speed.

## Architecture

Three layers, split by what they're allowed to import:

```
lib/
  core/
    domain/        models + progress rules. Plain Dart: no Flutter, no storage.
      models/      Course, CourseSection, Lesson, LessonProgress, LessonStatus
      course_progress.dart   90% rule, unlock rule, progress %, next lesson, continue watching
    data/          where things come from
      course_repository.dart     reads the bundled JSON catalogue
      progress_repository.dart   saves watch progress (SharedPreferences)
      settings_store.dart        theme mode and playback speed
    router/        go_router routes; each route creates its screen's cubit
    theme/         design tokens (colour, type, spacing) + ThemeCubit
    widgets/       UI shared by more than one screen
  features/
    courses/        logic/ (cubit + state)   presentation/ (screen + widgets)
    course_details/ logic/                   presentation/
    video_player/   logic/                   presentation/
```

- **Dependency direction:** `presentation → logic (cubits) → domain ← data`. The domain imports nothing outside itself, so the rules the task cares about (90%, unlock, progress %) are plain functions, tested without Flutter.
- **Repositories are abstract classes** (`CourseRepository`, `ProgressRepository`) with one implementation each. Tests use a fake catalogue; swapping the JSON for an API wouldn't touch a cubit.
- **One source of truth for progress.** `ProgressRepository` emits after every save, and the Courses and Course details cubits listen. Coming back from the player updates the Continue card, the course % and the lesson statuses immediately, with no manual refresh.

### State management: Bloc (Cubit)

Each screen has one Cubit with a sealed state class (`Loading`, `Error`, `Loaded`/`Ready`):
- Every screen has to handle every state, because a Dart `switch` over a sealed class won't compile with one missing. That's how loading, empty and error states are enforced rather than remembered.
- Cubits over Blocs: the screens send simple commands (`load`, `setSpeed`, `onProgress`), so events would add ceremony without adding anything.
- Cubits are plain Dart objects, so they're unit-tested directly (see the player tests).

### The video player

The player is split in two:
- `VideoPlayerCubit` holds the **rules**: where to resume, when to save, the 90% completion, and whether "Next lesson" is allowed. It never touches the video plugin.
- `VideoPlayerScreen` owns the `VideoPlayerController`. It forwards position updates, pauses, errors and backgrounding to the cubit.

That keeps the rules testable without a real player. Other details:
- **Saving:** progress is saved every 5 s of playback, immediately on completion, on pause, when the app goes to the background, and when the page closes.
- **Rebuilds:** the page doesn't rebuild on every position update. Only the controls listen to the controller.
- **Unlock enforced twice:** once in the UI (tapping a locked row) and once in the cubit. Opening a locked lesson through a route shows a locked state instead of playing it.

### Navigation: go_router

Routes are nested (`/`, `/courses/:courseId`, `/courses/:courseId/lessons/:lessonId`), so jumping straight to a lesson from the Continue card still builds the natural back stack. Each route creates its screen's cubit from the path parameters. Moving to the next lesson opens a fresh player page, and closing the old one saves its progress.

### Local storage: SharedPreferences

Progress is a small map of lesson id → `{position, duration, completed, updatedAt}`, a few hundred bytes for this catalogue. SharedPreferences stores it as one JSON string:
- **No schema or codegen:** Hive/Isar would need adapters or generated code, and sqflite would need tables and migrations, all for one small map read once at startup.
- **Simple reads:** everything is loaded into memory at startup, so reads are synchronous.
- **Where it stops fitting:** thousands of lessons, or querying progress by course, would justify sqflite or Isar. The `ProgressRepository` abstraction keeps that swap local.

If the saved JSON is unreadable, the app starts with empty progress rather than crashing.

### Data shape

The catalogue follows the suggested JSON shape, with two deliberate changes:
- **Globally unique ids.** Progress is keyed by lesson id alone, so ids are prefixed per course (`anatomy-l1`, not `l1`). The repository rejects a catalogue with duplicate course or lesson ids and shows the error state, rather than silently mixing two lessons' progress.
- **`thumbnail` is optional.** Without an image (or if the file is missing), cards show the brand's placeholder art instead of a grey box.

### Non-obvious bits in the code

- **Each lesson page is keyed by its URL** (`app_router.dart`). go_router reuses a page when the route *pattern* is the same, so without the key, "next lesson" would keep the old page and cubit. With the key, the next lesson gets a fresh page, and the old cubit's `close()` saves its progress.
- **The player screen keeps a `GoRouter` reference.** The "next lesson" action in the completion snackbar can be tapped after the page is gone, when `context` can't be used anymore.
- **Stale controllers are ignored.** `initialize()` is async. If the user leaves or retries meanwhile, a newer controller has replaced it, so the old one stops there.
- **`context.locale;` at the top of `build`.** `.tr()` doesn't rebuild a widget when the language changes; reading `context.locale` does.
- **Text scaling is capped at 1.3× only on fixed-size chrome** (app bars, the player controls, the pinned bottom bar). Page content still scales fully.
- **Theme colours** live in a `ThemeExtension` so widgets read them with `context.colors`. Its `lerp` just switches palettes halfway through Material's theme fade instead of blending each colour.

## Arabic and RTL

- **Language and direction:** Arabic is the default and the layout is RTL throughout (start/end paddings, directional icons mirror). English switches the layout to LTR.
- **Plurals:** real Arabic plural forms («درس واحد، درسان، 6 دروس، 11 درساً») via `easy_localization` with `ignorePluralRules: false`.
- **Video controls stay LTR** in both languages (time on the left, scrubber filling left to right), following Material's rule that media controls aren't mirrored. The rest of the player page mirrors.
- **Percentages keep their order.** After Arabic letters, «32%» renders as «%32» under the Unicode bidi rules. Percentages inside Arabic sentences are wrapped in LTR isolate marks.
- **Fonts:** Sahel for headings and IBM Plex Sans Arabic for everything else, bundled as `.ttf` so they work offline.

## States and errors

- **Loading:** skeleton cards shaped like the content.
- **Error:** an explanation and a retry.
- **Empty:** a calm message. A course with no lessons shows an empty state in place of the list.
- **Missing or corrupt video:** the error appears inside the 16:9 video frame, with retry and back-to-course; the rest of the page stays usable.

## Tests

`test/progress_test.dart`, 13 tests:
- **90% rule:** completes at 90%, not at 89%; a zero duration never completes.
- **Unlock rule:** only the first lesson is open on a fresh course; in progress doesn't unlock the next; completing unlocks the next, including across sections.
- **Progress %:** counts completed lessons only, rounded; an empty course is 0%, not a division by zero.
- **Continue watching:** picks the most recent unfinished lesson.
- **Catalogue:** rejects duplicate lesson ids.
- **Player cubit** (real SharedPreferences mock, fake catalogue):
  - completes at 90%, unlocks the next lesson, and the result survives a "restart" (a new repository reading the same storage);
  - refuses a locked lesson;
  - resumes from the saved position.

## Trade-offs and known issues

- **90% means reaching 90% of the timeline.** Seeking past 90% completes the lesson. Counting only seconds actually watched is stricter, but it was a product decision I didn't want to make alone. The rule lives in one function (`reachedCompletion`), so it's a small change.
- **Lesson lists show the JSON `durationSec`,** while the 90% rule uses the video file's real duration. They can drift if the JSON is wrong.
- **Course content is Arabic only.** The English switch translates the interface, not course titles or instructor names.
- **Models parse their own JSON.** Separate data-transfer objects would duplicate every field for one bundled file.
- **Three royalty-free sample clips (5–9 MB each) are reused across the lessons**, and the JSON durations match them.
- **Course thumbnails are placeholder images.** Their banners don't match the course topics (the anatomy course shows a biochemistry banner); they're there to show how real artwork looks on the cards.
- **Up to 5 s of progress can be lost** if the app is killed while in the foreground; backgrounding saves immediately.
- **iOS logs a "Failed to change device orientation" line** on each fullscreen toggle, and the rotation still succeeds. It comes from the order in which Flutter's engine updates the allowed orientations on iOS 16+.
- **Tested on the iOS simulator** (iPhone 17 Pro) and on a real Android phone with the release APK.

## With more time

- Widget tests for the empty and error states, and an integration test that drives the player to 90%.
- A stricter "watched time" completion rule, if the product wants it.
- Search courses and per-lesson notes (the remaining bonus items).
- Typed translation keys (easy_localization code generation) instead of string keys.
- Real course thumbnails, and bilingual course content in the JSON.
- Add App Icon and Native splash screen
- Polish UI/UX
