part of 'courses_cubit.dart';

typedef CourseSummary = ({Course course, int percent});

@immutable
sealed class CoursesState {
  const CoursesState();
}

final class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

final class CoursesError extends CoursesState {
  const CoursesError();
}

/// An empty [courses] list is the empty state.
final class CoursesLoaded extends CoursesState {
  const CoursesLoaded({required this.courses, required this.continueItem});

  final List<CourseSummary> courses;

  /// Null hides the Continue watching card.
  final ContinueItem? continueItem;
}
