import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen/core/data/course_repository.dart';
import 'package:thaheen/core/data/progress_repository.dart';
import 'package:thaheen/core/data/settings_store.dart';
import 'package:thaheen/core/domain/course_progress.dart';
import 'package:thaheen/core/domain/models/course.dart';
import 'package:thaheen/core/domain/models/lesson_progress.dart';
import 'package:thaheen/core/utils/duration_format.dart';
import 'package:thaheen/features/video_player/logic/video_player_cubit.dart';

Lesson _lesson(String id) => Lesson(
  id: id,
  title: id,
  duration: const Duration(seconds: 100),
  video: '',
);

// Two sections, so unlock is tested across the section boundary.
final _course = Course(
  id: 'c1',
  title: 'Course',
  instructor: 'Dr',
  sections: [
    CourseSection(
      id: 's1',
      title: 'S1',
      lessons: [_lesson('l1'), _lesson('l2')],
    ),
    CourseSection(id: 's2', title: 'S2', lessons: [_lesson('l3')]),
  ],
);

LessonProgress _progress(int seconds, {bool completed = false}) =>
    LessonProgress(
      position: Duration(seconds: seconds),
      duration: const Duration(seconds: 100),
      completed: completed,
      updatedAt: DateTime(2026),
    );

class _FakeCourses implements CourseRepository {
  @override
  Future<List<Course>> getCourses() async => [_course];
  @override
  Future<Course> getCourse(String id) async => _course;
}

class _JsonBundle extends CachingAssetBundle {
  _JsonBundle(this.json);
  final String json;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(utf8.encode(json));
}

void main() {
  group('90% completion rule', () {
    test('completes at 90%, not before', () {
      const d = Duration(seconds: 100);
      expect(reachedCompletion(const Duration(seconds: 89), d), isFalse);
      expect(reachedCompletion(const Duration(seconds: 90), d), isTrue);
    });

    test('an unknown (zero) duration never completes', () {
      expect(reachedCompletion(Duration.zero, Duration.zero), isFalse);
    });
  });

  group('unlock rule', () {
    test('only the first lesson is open on a fresh course', () {
      expect(lessonStatuses(_course, {}), {
        'l1': LessonStatus.notStarted,
        'l2': LessonStatus.locked,
        'l3': LessonStatus.locked,
      });
    });

    test('in progress does not unlock the next lesson', () {
      final s = lessonStatuses(_course, {'l1': _progress(40)});
      expect(s['l1'], LessonStatus.inProgress);
      expect(s['l2'], LessonStatus.locked);
    });

    test('completing a lesson unlocks the next, across sections', () {
      final s = lessonStatuses(_course, {
        'l1': _progress(95, completed: true),
        'l2': _progress(95, completed: true),
      });
      expect(s['l3'], LessonStatus.notStarted);
    });
  });

  group('progress %', () {
    test('counts completed lessons only, rounded', () {
      expect(courseProgressPercent(_course, {}), 0);
      expect(
        courseProgressPercent(_course, {
          'l1': _progress(95, completed: true),
          'l2': _progress(50),
        }),
        33,
      );
    });

    test('a course with no lessons is 0%, not a division by zero', () {
      const empty = Course(id: 'e', title: 'E', instructor: 'Dr', sections: []);
      expect(courseProgressPercent(empty, {}), 0);
    });
  });

  test('continue watching picks the latest unfinished lesson', () {
    final older = _progress(10);
    final newer = LessonProgress(
      position: const Duration(seconds: 20),
      duration: const Duration(seconds: 100),
      completed: false,
      updatedAt: DateTime(2027),
    );
    final item = continueWatching(
      [_course],
      {'l1': older, 'l2': newer, 'l3': _progress(95, completed: true)},
    );
    expect(item?.lesson.id, 'l2');
  });

  test('formatDuration', () {
    expect(formatDuration(const Duration(seconds: 72)), '01:12');
    expect(formatDuration(const Duration(hours: 1, seconds: 5)), '1:00:05');
  });

  test('the catalogue rejects duplicate lesson ids', () {
    const json = '''
{"courses": [
  {"id": "a", "title": "A", "instructor": "Dr", "sections": [{"id": "s", "title": "S",
    "lessons": [{"id": "l1", "title": "L", "durationSec": 1, "video": "v"}]}]},
  {"id": "b", "title": "B", "instructor": "Dr", "sections": [{"id": "s", "title": "S",
    "lessons": [{"id": "l1", "title": "L", "durationSec": 1, "video": "v"}]}]}
]}''';
    expect(
      AssetCourseRepository(bundle: _JsonBundle(json)).getCourses(),
      throwsFormatException,
    );
  });

  group('VideoPlayerCubit', () {
    late SharedPreferences prefs;
    late PrefsProgressRepository progress;
    late VideoPlayerCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      progress = PrefsProgressRepository(prefs);
      cubit = VideoPlayerCubit(_FakeCourses(), progress, SettingsStore(prefs));
      await cubit.load('c1', 'l1');
    });

    test('completes at 90%, unlocks next, and survives a restart', () async {
      const d = Duration(seconds: 100);
      cubit.onProgress(const Duration(seconds: 50), d);
      expect((cubit.state as VideoPlayerReady).canGoNext, isFalse);

      cubit.onProgress(const Duration(seconds: 90), d);
      final s = cubit.state as VideoPlayerReady;
      expect(s.completed, isTrue);
      expect(s.canGoNext, isTrue);
      expect(s.nextStatus, LessonStatus.notStarted);

      // A new repository reads what the old one persisted.
      expect(PrefsProgressRepository(prefs).all['l1']?.completed, isTrue);
    });

    test('refuses to open a locked lesson', () async {
      await cubit.load('c1', 'l2');
      expect(cubit.state, isA<VideoPlayerLocked>());
    });

    test('resumes an unfinished lesson from its saved position', () async {
      cubit.onProgress(
        const Duration(seconds: 30),
        const Duration(seconds: 100),
      );
      await cubit.close();

      final reopened = VideoPlayerCubit(
        _FakeCourses(),
        progress,
        SettingsStore(prefs),
      );
      await reopened.load('c1', 'l1');
      expect(
        (reopened.state as VideoPlayerReady).resumeFrom,
        const Duration(seconds: 30),
      );
    });
  });
}
