import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/course_repository.dart';
import '../../../core/data/progress_repository.dart';
import '../../../core/domain/course_progress.dart';
import '../../../core/domain/models/course.dart';
import '../../../core/domain/models/lesson_progress.dart';

part 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  CourseDetailsCubit(this.courseId, this._courses, this._progress)
    : super(const CourseDetailsLoading()) {
    _progressSub = _progress.changes.listen((_) => _emitLoaded());
  }

  final String courseId;
  final CourseRepository _courses;
  final ProgressRepository _progress;
  late final StreamSubscription<void> _progressSub;
  Course? _course;

  /// Also the retry action of the error state.
  Future<void> load() async {
    emit(const CourseDetailsLoading());
    try {
      _course = await _courses.getCourse(courseId);
      _emitLoaded();
    } catch (e, s) {
      addError(e, s);
      emit(const CourseDetailsError());
    }
  }

  void _emitLoaded() {
    final course = _course;
    if (course == null) return;
    final progress = _progress.all;
    emit(
      CourseDetailsLoaded(
        course: course,
        statuses: lessonStatuses(course, progress),
        progress: progress,
        percent: courseProgressPercent(course, progress),
      ),
    );
  }

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }
}
