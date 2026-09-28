import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/models/course.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../logic/video_player_cubit.dart';

/// The pinned bar under the player. Three cases:
/// - last lesson: a "back to course" button;
/// - lesson completed: an enabled "next lesson" button;
/// - not completed yet: a greyed-out button that explains why when tapped.
class NextLessonBar extends StatelessWidget {
  const NextLessonBar({super.key, required this.state, required this.onNext});

  final VideoPlayerReady state;
  final void Function(Course course, Lesson lesson) onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final next = state.nextLesson;

    final List<Widget> children;
    if (next == null) {
      children = [
        FilledButton(
          style: ThaheenTheme.largeButton,
          onPressed: context.pop,
          child: Text('back_to_course'.tr()),
        ),
      ];
    } else if (state.canGoNext) {
      children = [
        FilledButton.icon(
          style: ThaheenTheme.largeButton,
          onPressed: () => onNext(state.course, next),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded), // mirrors in RTL
          label: Text('next_lesson'.tr()),
        ),
      ];
    } else {
      children = [
        Text(
          'next_hint'.tr(),
          textAlign: TextAlign.center,
          style: ThaheenText.numeric.copyWith(
            fontWeight: FontWeight.w400,
            height: 20 / 13,
            color: c.inkSecondary,
          ),
        ),
        FilledButton.icon(
          style: ThaheenTheme.largeButton.copyWith(
            backgroundColor: WidgetStatePropertyAll(c.surfaceSunken),
            foregroundColor: WidgetStatePropertyAll(c.inkDisabled),
          ),
          onPressed: () => showAppSnackBar(
            context,
            'next_hint'.tr(),
            icon: Icons.lock_outline_rounded,
          ),
          icon: const Icon(Icons.lock_outline_rounded),
          label: Text('next_lesson'.tr()),
        ),
      ];
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
        boxShadow: c.shadowBar,
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.symmetric(
          horizontal: Space.spacing16.w,
          vertical: Space.spacing12.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Space.spacing8.h,
          children: children,
        ),
      ),
    );
  }
}
