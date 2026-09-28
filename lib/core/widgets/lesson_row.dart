import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../domain/models/course.dart';
import '../domain/models/lesson_progress.dart';
import '../theme/app_theme.dart';
import '../utils/duration_format.dart';

/// One lesson: status disc, title, duration and status word. Status always
/// pairs an icon with a word, never colour alone.
class LessonRow extends StatelessWidget {
  const LessonRow({
    super.key,
    required this.lesson,
    required this.status,
    required this.onTap,
    this.watchedPercent = 0,
    this.current = false,
  });

  final Lesson lesson;
  final LessonStatus status;

  /// Locked rows still call this, so the screen can explain the lock.
  final VoidCallback onTap;
  final int watchedPercent;

  /// The resume target, tinted `surfaceTint`. One per course.
  final bool current;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locked = status == LessonStatus.locked;
    final IconData icon;
    final Color fg;
    final Color bg;
    final String label;
    switch (status) {
      case LessonStatus.notStarted:
        icon = Icons.circle_outlined;
        fg = c.inkSecondary;
        bg = c.surfaceSunken;
        label = 'status.not_started'.tr();
      case LessonStatus.inProgress:
        icon = Icons.contrast_rounded;
        fg = c.brand;
        bg = current ? c.surface : c.surfaceTint;
        // The LRI/PDI marks keep "32%" in order: after Arabic letters the bidi
        // rules would otherwise render it "%32".
        label = watchedPercent > 0
            ? '${'status.in_progress'.tr()} \u2066$watchedPercent%\u2069'
            : 'status.in_progress'.tr();
      case LessonStatus.completed:
        icon = Icons.check_rounded;
        fg = c.onPrimary;
        bg = c.success;
        label = 'status.completed'.tr();
      case LessonStatus.locked:
        icon = Icons.lock_outline_rounded;
        fg = c.inkDisabled;
        bg = c.surfaceSunken;
        label = 'status.locked'.tr();
    }
    return Material(
      color: current ? c.surfaceTint : c.surface,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 64.h),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Space.spacing16.w,
              vertical: Space.spacing8.h,
            ),
            child: Row(
              spacing: Space.spacing12.w,
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
                  child: Icon(icon, size: 16.r, color: fg),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: ThaheenText.body.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 24 / 15,
                          color: locked ? c.inkDisabled : c.ink,
                        ),
                      ),
                      Text(
                        '${formatDuration(lesson.duration)} · $label',
                        style: ThaheenText.numeric.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 20 / 13,
                          color: c.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mirrors in RTL (points left in Arabic).
                if (!locked)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.r,
                    color: c.inkSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
