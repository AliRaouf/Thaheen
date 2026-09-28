enum LessonStatus { notStarted, inProgress, completed, locked }

class LessonProgress {
  const LessonProgress({
    required this.position,
    required this.duration,
    required this.completed,
    required this.updatedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
    position: Duration(milliseconds: json['positionMs'] as int),
    duration: Duration(milliseconds: json['durationMs'] as int),
    completed: json['completed'] as bool,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  final Duration position;
  final Duration duration;
  final bool completed;
  final DateTime updatedAt;

  /// Watched share, 0.0–1.0.
  double get fraction => duration == Duration.zero
      ? 0
      : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'positionMs': position.inMilliseconds,
    'durationMs': duration.inMilliseconds,
    'completed': completed,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
