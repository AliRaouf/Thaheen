class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.sections,
    this.thumbnail,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String,
    title: json['title'] as String,
    instructor: json['instructor'] as String,
    thumbnail: json['thumbnail'] as String?,
    sections: [
      for (final s in json['sections'] as List? ?? const [])
        CourseSection.fromJson(s as Map<String, dynamic>),
    ],
  );

  final String id;
  final String title;
  final String instructor;
  final String? thumbnail;
  final List<CourseSection> sections;

  List<Lesson> get lessons => [
    for (final section in sections) ...section.lessons,
  ];

  CourseSection sectionOf(String lessonId) =>
      sections.firstWhere((s) => s.lessons.any((l) => l.id == lessonId));
}

class CourseSection {
  const CourseSection({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) => CourseSection(
    id: json['id'] as String,
    title: json['title'] as String,
    lessons: [
      for (final l in json['lessons'] as List? ?? const [])
        Lesson.fromJson(l as Map<String, dynamic>),
    ],
  );
  final String id;
  final String title;
  final List<Lesson> lessons;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.video,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    title: json['title'] as String,
    duration: Duration(seconds: json['durationSec'] as int),
    video: json['video'] as String,
  );

  final String id;
  final String title;
  final Duration duration;
  final String video;
}
