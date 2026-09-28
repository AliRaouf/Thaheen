import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/lesson_progress.dart';

abstract class ProgressRepository {
  Map<String, LessonProgress> get all;

  Stream<Map<String, LessonProgress>> get changes;

  Future<void> save(String lessonId, LessonProgress progress);
}

class PrefsProgressRepository implements ProgressRepository {
  PrefsProgressRepository(this._prefs)
    : _progress = _decode(_prefs.getString(_key));

  static const _key = 'lesson_progress';

  final SharedPreferences _prefs;
  final Map<String, LessonProgress> _progress;
  final _changes = StreamController<Map<String, LessonProgress>>.broadcast();

  @override
  Map<String, LessonProgress> get all => Map.unmodifiable(_progress);

  @override
  Stream<Map<String, LessonProgress>> get changes => _changes.stream;

  @override
  Future<void> save(String lessonId, LessonProgress progress) async {
    _progress[lessonId] = progress;
    _changes.add(all);
    await _prefs.setString(
      _key,
      jsonEncode(_progress.map((id, p) => MapEntry(id, p.toJson()))),
    );
  }

  static Map<String, LessonProgress> _decode(String? raw) {
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>).map(
        (id, p) =>
            MapEntry(id, LessonProgress.fromJson(p as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }
}
