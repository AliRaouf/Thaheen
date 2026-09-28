import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/course_repository.dart';
import '../../../core/data/progress_repository.dart';
import '../../../core/data/settings_store.dart';
import '../../../core/domain/course_progress.dart';
import '../../../core/domain/models/course.dart';
import '../../../core/domain/models/lesson_progress.dart';

part 'video_player_state.dart';

/// Player rules only: resume, saving, the 90% completion and the unlock of the
/// next lesson. The screen owns the `VideoPlayerController` and reports to it
/// through [onProgress] and [onVideoError].
class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit(this._courses, this._progress, this._settings)
    : super(const VideoPlayerLoading());

  static const speeds = [1.0, 1.25, 1.5, 2.0];

  /// Positions are written at most this often, plus on completion and close.
  static const _saveEvery = Duration(seconds: 5);

  final CourseRepository _courses;
  final ProgressRepository _progress;
  final SettingsStore _settings;
  Duration _lastSaved = Duration.zero;

  Future<void> load(String courseId, String lessonId) async {
    emit(const VideoPlayerLoading());
    try {
      final course = await _courses.getCourse(courseId);
      final lesson = course.lessons.firstWhere((l) => l.id == lessonId);
      final statuses = lessonStatuses(course, _progress.all);
      // The unlock rule holds even when a route opens the lesson directly.
      if (statuses[lessonId] == LessonStatus.locked) {
        emit(const VideoPlayerLocked());
        return;
      }
      final saved = _progress.all[lessonId];
      final resumeFrom = saved == null || saved.completed
          ? Duration.zero
          : saved.position;
      final next = nextLesson(course, lessonId);
      _lastSaved = resumeFrom;
      emit(
        VideoPlayerReady(
          course: course,
          section: course.sectionOf(lessonId),
          lesson: lesson,
          nextLesson: next,
          nextStatus: next == null ? null : statuses[next.id],
          resumeFrom: resumeFrom,
          position: resumeFrom,
          duration: saved?.duration ?? lesson.duration,
          completed: saved?.completed ?? false,
          speed: _settings.playbackSpeed,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(const VideoPlayerLoadError());
    }
  }

  /// Call from the controller's listener with its position and real duration.
  void onProgress(Duration position, Duration duration) {
    final s = state;
    if (s is! VideoPlayerReady) return;
    final justCompleted = !s.completed && reachedCompletion(position, duration);
    var next = s.copyWith(
      position: position,
      duration: duration,
      completed: s.completed || justCompleted,
    );
    if (justCompleted || (position - _lastSaved).abs() >= _saveEvery) {
      _save(next);
      if (justCompleted) {
        next = next.copyWith(nextStatus: _statusOf(s.course, s.nextLesson));
      }
    }
    emit(next);
  }

  void setSpeed(double speed) {
    final s = state;
    if (s is! VideoPlayerReady) return;
    _settings.setPlaybackSpeed(speed);
    emit(s.copyWith(speed: speed));
  }

  /// Missing or corrupt file. The rest of the screen stays usable.
  void onVideoError() {
    final s = state;
    if (s is VideoPlayerReady) emit(s.copyWith(videoFailed: true));
  }

  /// The screen re-creates its controller when `videoFailed` turns false.
  void retry() {
    final s = state;
    if (s is VideoPlayerReady) emit(s.copyWith(videoFailed: false));
  }

  LessonStatus? _statusOf(Course course, Lesson? lesson) =>
      lesson == null ? null : lessonStatuses(course, _progress.all)[lesson.id];

  Future<void> _save(VideoPlayerReady s) {
    _lastSaved = s.position;
    return _progress.save(
      s.lesson.id,
      LessonProgress(
        position: s.position,
        duration: s.duration,
        completed: s.completed,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Call when playback pauses and when the app goes to the background, so a
  /// kill from the background loses nothing.
  Future<void> saveNow() async {
    final s = state;
    if (s is VideoPlayerReady && s.position != _lastSaved) await _save(s);
  }

  @override
  Future<void> close() async {
    await saveNow();
    return super.close();
  }
}
