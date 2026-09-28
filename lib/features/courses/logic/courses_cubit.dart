import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/course_repository.dart';
import '../../../core/data/progress_repository.dart';
import '../../../core/domain/course_progress.dart';
import '../../../core/domain/models/course.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._courses, this._progress) : super(const CoursesLoading()) {
    _progressSub = _progress.changes.listen((_) => _emitLoaded());
  }

  final CourseRepository _courses;
  final ProgressRepository _progress;
  late final StreamSubscription<void> _progressSub;
  List<Course>? _loaded;

  /// Also the retry action of the error state.
  Future<void> load() async {
    emit(const CoursesLoading());
    try {
      _loaded = await _courses.getCourses();
      _emitLoaded();
    } catch (e, s) {
      addError(e, s);
      emit(const CoursesError());
    }
  }

  void _emitLoaded() {
    final courses = _loaded;
    if (courses == null) return;
    final progress = _progress.all;
    emit(
      CoursesLoaded(
        courses: [
          for (final c in courses)
            (course: c, percent: courseProgressPercent(c, progress)),
        ],
        continueItem: continueWatching(courses, progress),
      ),
    );
  }

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }
}
