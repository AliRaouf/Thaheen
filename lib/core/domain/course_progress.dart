// Pure progress rules shared by every screen. No Flutter, no storage: unit-testable.

import 'models/course.dart';
import 'models/lesson_progress.dart';

/// A lesson completes automatically once this share of it has been watched.
const completionThreshold = 0.9;

/// Timeline rule: reaching 90% of the video completes it, even by seeking.
bool reachedCompletion(Duration position, Duration duration) =>
    duration > Duration.zero &&
    position.inMilliseconds >= duration.inMilliseconds * completionThreshold;

/// Status of every lesson in [course], keyed by lesson id.
///
/// Sequential unlock: a lesson is locked until the one before it (across
/// section boundaries) is completed. The first lesson is never locked.
Map<String, LessonStatus> lessonStatuses(
  Course course,
  Map<String, LessonProgress> progress,
) {
  final statuses = <String, LessonStatus>{};
  var previousCompleted = true;
  for (final lesson in course.lessons) {
    final p = progress[lesson.id];
    final completed = p?.completed ?? false;
    final started = p != null && p.position > Duration.zero;

    if (completed) {
      statuses[lesson.id] = LessonStatus.completed;
    } else if (!previousCompleted) {
      statuses[lesson.id] = LessonStatus.locked;
    } else if (started) {
      statuses[lesson.id] = LessonStatus.inProgress;
    } else {
      statuses[lesson.id] = LessonStatus.notStarted;
    }
    previousCompleted = completed;
  }
  return statuses;
}

/// Completed lessons as a whole-number percentage of the course.
int courseProgressPercent(Course course, Map<String, LessonProgress> progress) {
  final lessons = course.lessons;
  if (lessons.isEmpty) return 0;
  final done = lessons.where((l) => progress[l.id]?.completed ?? false).length;
  return (done * 100 / lessons.length).round();
}

/// The lesson after [lessonId] in watch order, or null if it is the last.
Lesson? nextLesson(Course course, String lessonId) {
  final lessons = course.lessons;
  final i = lessons.indexWhere((l) => l.id == lessonId);
  return i == -1 || i == lessons.length - 1 ? null : lessons[i + 1];
}

typedef ContinueItem = ({
  Course course,
  Lesson lesson,
  LessonProgress progress,
});

/// The most recently watched lesson that is started but not completed.
ContinueItem? continueWatching(
  List<Course> courses,
  Map<String, LessonProgress> progress,
) {
  ContinueItem? latest;
  for (final course in courses) {
    for (final lesson in course.lessons) {
      final p = progress[lesson.id];
      if (p == null || p.completed || p.position == Duration.zero) continue;
      if (latest == null || p.updatedAt.isAfter(latest.progress.updatedAt)) {
        latest = (course: course, lesson: lesson, progress: p);
      }
    }
  }
  return latest;
}
