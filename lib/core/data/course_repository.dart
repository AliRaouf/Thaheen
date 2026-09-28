import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();

  Future<Course> getCourse(String id);
}

class AssetCourseRepository implements CourseRepository {
  AssetCourseRepository({
    AssetBundle? bundle,
    this.path = 'assets/data/courses.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String path;
  List<Course>? _cache;

  @override
  Future<List<Course>> getCourses() async =>
      _cache ??= _parse(await _bundle.loadString(path));

  static List<Course> _parse(String raw) {
    final courses = [
      for (final course in jsonDecode(raw)['courses'] as List)
        Course.fromJson(course as Map<String, dynamic>),
    ];
    // Routes use course ids and progress is keyed by lesson id alone, so a
    // duplicate would mix two lessons' progress. Fail loudly instead.
    bool unique(Iterable<String> ids) => ids.toSet().length == ids.length;
    if (!unique(courses.map((course) => course.id)) ||
        !unique(
          courses.expand((course) => course.lessons).map((lesson) => lesson.id),
        )) {
      throw const FormatException('Course and lesson ids must be unique');
    }
    return courses;
  }

  @override
  Future<Course> getCourse(String id) async =>
      (await getCourses()).firstWhere((course) => course.id == id);
}
