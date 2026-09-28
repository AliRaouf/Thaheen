part of 'course_details_cubit.dart';

@immutable
sealed class CourseDetailsState {
  const CourseDetailsState();
}

final class CourseDetailsLoading extends CourseDetailsState {
  const CourseDetailsLoading();
}

final class CourseDetailsError extends CourseDetailsState {
  const CourseDetailsError();
}

/// `course.lessons.isEmpty` (or a section's) is the empty state.
final class CourseDetailsLoaded extends CourseDetailsState {
  const CourseDetailsLoaded({
    required this.course,
    required this.statuses,
    required this.progress,
    required this.percent,
  });

  final Course course;
  final Map<String, LessonStatus> statuses;
  final Map<String, LessonProgress> progress;
  final int percent;

  LessonStatus statusOf(Lesson lesson) => statuses[lesson.id]!;

  /// How far into [lesson] the student is, 0–100.
  int watchedPercent(Lesson lesson) =>
      ((progress[lesson.id]?.fraction ?? 0) * 100).round();

  /// The resume target, tinted in the list: the first lesson not yet
  /// completed. The unlock rule makes it the only open, unfinished one.
  Lesson? get current => course.lessons
      .where((l) => statusOf(l) != LessonStatus.completed)
      .firstOrNull;

  /// Tapping a locked lesson shows the unlock message instead of navigating.
  bool isLocked(Lesson lesson) => statusOf(lesson) == LessonStatus.locked;

  /// Completed lessons in [section], for its header.
  int completedIn(CourseSection section) => section.lessons
      .where((l) => statusOf(l) == LessonStatus.completed)
      .length;
}
