import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/domain/models/course.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/course_meta.dart';
import '../../../../core/widgets/course_thumbnail.dart';
import '../../../../core/widgets/progress_bar.dart';

/// One course in the list. The whole card opens Course details.
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.percent,
    required this.onTap,
  });

  final Course course;
  final int percent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CourseThumbnail(image: course.thumbnail),
            Padding(
              padding: EdgeInsets.all(Space.spacing12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Space.spacing8.h,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ThaheenText.cardTitle.copyWith(
                      color: context.colors.title,
                    ),
                  ),
                  CourseMeta(course),
                  ProgressBar(percent: percent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
