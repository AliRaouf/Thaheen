import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../domain/models/course.dart';
import '../theme/app_theme.dart';

/// Instructor and lesson count, as on the course card and details header.
class CourseMeta extends StatelessWidget {
  const CourseMeta(this.course, {super.key});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final style = ThaheenText.bodySm.copyWith(
      color: context.colors.inkSecondary,
    );
    Widget item(IconData icon, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Space.spacing4.w,
      children: [
        Icon(icon, size: 16.r, color: style.color),
        Text(label, style: style),
      ],
    );
    return Wrap(
      spacing: Space.spacing12.w,
      runSpacing: Space.spacing4.h,
      children: [
        item(Icons.person_outline_rounded, course.instructor),
        item(
          Icons.smart_display_outlined,
          'lessons_count'.plural(course.lessons.length),
        ),
      ],
    );
  }
}
