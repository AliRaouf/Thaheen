part of 'video_player_cubit.dart';

@immutable
sealed class VideoPlayerState {
  const VideoPlayerState();
}

final class VideoPlayerLoading extends VideoPlayerState {
  const VideoPlayerLoading();
}

/// The course or lesson couldn't be found. A bad video file is
/// [VideoPlayerReady.videoFailed] instead.
final class VideoPlayerLoadError extends VideoPlayerState {
  const VideoPlayerLoadError();
}

/// Opened before the previous lesson was completed (e.g. a direct link).
/// The screen explains the lock and offers a way back.
final class VideoPlayerLocked extends VideoPlayerState {
  const VideoPlayerLocked();
}

final class VideoPlayerReady extends VideoPlayerState {
  const VideoPlayerReady({
    required this.course,
    required this.section,
    required this.lesson,
    required this.nextLesson,
    required this.nextStatus,
    required this.resumeFrom,
    required this.position,
    required this.duration,
    required this.completed,
    required this.speed,
    this.videoFailed = false,
  });

  final Course course;
  final CourseSection section;
  final Lesson lesson;

  /// Null on the course's last lesson.
  final Lesson? nextLesson;
  final LessonStatus? nextStatus;

  /// Seek here once the controller initialises. Zero means start over.
  final Duration resumeFrom;
  final Duration position;
  final Duration duration;
  final bool completed;
  final double speed;
  final bool videoFailed;

  /// The unlock rule: next is enabled only once this lesson is completed.
  bool get canGoNext => completed && nextLesson != null;

  VideoPlayerReady copyWith({
    Duration? position,
    Duration? duration,
    bool? completed,
    double? speed,
    bool? videoFailed,
    LessonStatus? nextStatus,
  }) => VideoPlayerReady(
    course: course,
    section: section,
    lesson: lesson,
    nextLesson: nextLesson,
    nextStatus: nextStatus ?? this.nextStatus,
    resumeFrom: resumeFrom,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    completed: completed ?? this.completed,
    speed: speed ?? this.speed,
    videoFailed: videoFailed ?? this.videoFailed,
  );
}
