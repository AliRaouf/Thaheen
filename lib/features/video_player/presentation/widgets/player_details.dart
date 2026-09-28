import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/domain/models/course.dart';
import '../../../../core/domain/models/lesson_progress.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/lesson_row.dart';
import '../../logic/video_player_cubit.dart';
import 'speed_selector.dart';

/// Below the video: title and status, course · section, speed, next lesson.
class PlayerDetails extends StatelessWidget {
  const PlayerDetails({
    super.key,
    required this.state,
    required this.onSpeed,
    required this.onNext,
  });

  final VideoPlayerReady state;
  final ValueChanged<double> onSpeed;
  final void Function(Course course, Lesson lesson) onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final next = state.nextLesson;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.spacing20.h,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Space.spacing4.h,
          children: [
            // Wrap puts the badge under the title when text is very large.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Space.spacing12.w,
              runSpacing: Space.spacing4.h,
              children: [
                Text(
                  state.lesson.title,
                  style: ThaheenText.title.copyWith(color: c.ink),
                ),
                _StatusBadge(completed: state.completed),
              ],
            ),
            Text(
              '${state.course.title} · ${state.section.title}',
              style: ThaheenText.bodySm.copyWith(color: c.inkSecondary),
            ),
          ],
        ),
        Labeled(
          'speed'.tr(),
          SpeedSelector(selected: state.speed, onSelected: onSpeed),
        ),
        if (next != null)
          Labeled(
            'next_lesson'.tr(),
            Material(
              color: c.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.small4),
                side: BorderSide(color: c.line),
              ),
              child: LessonRow(
                lesson: next,
                status: state.nextStatus ?? LessonStatus.locked,
                onTap: () {
                  if (state.canGoNext) {
                    onNext(state.course, next);
                  } else {
                    showAppSnackBar(
                      context,
                      'locked_hint'.tr(),
                      icon: Icons.lock_outline_rounded,
                    );
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// A small grey label above [child].
class Labeled extends StatelessWidget {
  const Labeled(this.label, this.child, {super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    spacing: Space.spacing8,
    children: [
      Text(
        label,
        style: ThaheenText.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colors.inkSecondary,
        ),
      ),
      child,
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = completed ? c.successStrong : c.title;
    final bg = completed ? c.successSoft : c.surfaceTint;
    final icon = completed ? Icons.check_rounded : Icons.contrast_rounded;
    final label = completed
        ? 'status.completed'.tr()
        : 'status.in_progress'.tr();
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.spacing8,
        vertical: 2,
      ),
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Space.spacing4,
        children: [
          Icon(icon, size: 14, color: fg),
          Text(label, style: ThaheenText.caption.copyWith(color: fg)),
        ],
      ),
    );
  }
}
