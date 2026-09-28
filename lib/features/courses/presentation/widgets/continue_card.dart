import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/domain/course_progress.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/course_thumbnail.dart';
import '../../../../core/widgets/progress_bar.dart';

/// Resumes the most recent unfinished lesson.
class ContinueCard extends StatelessWidget {
  const ContinueCard({super.key, required this.item, required this.onTap});

  final ContinueItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = item.progress;
    final left = p.duration - p.position;
    final remaining = 'remaining'.tr(
      args: [formatDuration(left.isNegative ? Duration.zero : left)],
    );
    final radius = BorderRadius.circular(Radii.large14.r);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: c.shadowCard),
      child: Material(
        color: c.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: c.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(Space.spacing12.r),
            child: Row(
              spacing: Space.spacing12.w,
              children: [
                SizedBox(
                  width: 112.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Radii.small4),
                    child: CourseThumbnail(
                      image: item.course.thumbnail,
                      disc: Icons.play_arrow_rounded,
                      discSize: 40.r,
                      glow: true,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'continue_watching'.tr(),
                        style: ThaheenText.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: c.primary,
                        ),
                      ),
                      Text(
                        item.lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ThaheenText.cardTitle.copyWith(
                          height: 24 / 16,
                          color: c.ink,
                        ),
                      ),
                      Text(
                        // FSI/PDI marks keep the course title's direction
                        // from reordering the rest of the line.
                        '\u2068${item.course.title}\u2069 · $remaining',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ThaheenText.bodySm.copyWith(
                          fontSize: 13,
                          height: 20 / 13,
                          color: c.inkSecondary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: Space.spacing4.h),
                        child: ProgressBar(
                          percent: (p.fraction * 100).round(),
                          small: true,
                          showLabel: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
