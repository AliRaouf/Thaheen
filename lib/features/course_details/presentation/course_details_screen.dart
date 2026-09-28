import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/clamped_app_bar.dart';
import '../../../core/domain/models/course.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/course_meta.dart';
import '../../../core/widgets/course_thumbnail.dart';
import '../../../core/widgets/lesson_row.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/state_view.dart';
import '../logic/course_details_cubit.dart';

/// Header (thumbnail, title, meta, progress), then each section's lessons.
class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on language switch (`.tr()` alone doesn't)
    return Scaffold(
      appBar: ClampedAppBar(
        AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: Space.spacing4.w,
          titleTextStyle: ThaheenText.titleSm.copyWith(
            color: context.colors.ink,
          ),
          title: Row(
            spacing: Space.spacing4.w,
            children: [const AppBackButton(), Text('course_details'.tr())],
          ),
        ),
      ),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (context, state) => ListView(
          padding: EdgeInsets.all(Space.spacing16.w).copyWith(
            // Custom padding replaces ListView's safe-area inset, so add the
            // bottom inset back to keep the last card above the home bar.
            bottom: Space.spacing24.h + MediaQuery.paddingOf(context).bottom,
          ),
          children: switch (state) {
            CourseDetailsLoading() => const [StateView.loading()],
            CourseDetailsError() => [
              StateView.error(
                title: 'course_error_title'.tr(),
                body: 'courses_error_body'.tr(),
                actionLabel: 'retry'.tr(),
                onAction: context.read<CourseDetailsCubit>().load,
              ),
            ],
            CourseDetailsLoaded() => [
              _Header(state),
              SizedBox(height: Space.spacing24.h),
              if (state.course.lessons.isEmpty)
                StateView.empty(
                  icon: Icons.smart_display_outlined,
                  title: 'no_lessons'.tr(),
                  body: 'no_lessons_body'.tr(),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Space.spacing24.h,
                  children: [
                    for (final section in state.course.sections)
                      _Section(state, section),
                  ],
                ),
            ],
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.state);

  final CourseDetailsLoaded state;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Space.spacing12.h,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(Radii.small4),
        child: CourseThumbnail(image: state.course.thumbnail),
      ),
      Text(
        state.course.title,
        style: ThaheenText.title.copyWith(color: context.colors.ink),
      ),
      CourseMeta(state.course),
      ProgressBar(percent: state.percent),
    ],
  );
}

/// Section title with its "1 of 3 completed" counter, then its lessons.
class _Section extends StatelessWidget {
  const _Section(this.state, this.section);

  final CourseDetailsLoaded state;
  final CourseSection section;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = state.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Space.spacing8.h),
          // Wrap puts the counter under the title when text is very large.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.spacing12.w,
            children: [
              Text(
                section.title,
                style: ThaheenText.titleSm.copyWith(color: c.ink),
              ),
              Text(
                'section_progress'.tr(
                  args: [
                    '${state.completedIn(section)}',
                    '${section.lessons.length}',
                  ],
                ),
                style: ThaheenText.numeric.copyWith(
                  fontWeight: FontWeight.w400,
                  color: c.inkSecondary,
                ),
              ),
            ],
          ),
        ),
        if (section.lessons.isEmpty)
          StateView.empty(
            icon: Icons.smart_display_outlined,
            title: 'no_lessons'.tr(),
          )
        else
          Material(
            color: c.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.small4),
              side: BorderSide(color: c.line),
            ),
            child: Column(
              children: [
                for (final lesson in section.lessons) ...[
                  if (lesson != section.lessons.first) const Divider(),
                  LessonRow(
                    lesson: lesson,
                    status: state.statusOf(lesson),
                    watchedPercent: state.watchedPercent(lesson),
                    current: lesson == current,
                    onTap: () {
                      if (state.isLocked(lesson)) {
                        showAppSnackBar(
                          context,
                          'locked_hint'.tr(),
                          icon: Icons.lock_outline_rounded,
                        );
                      } else {
                        context.push(
                          AppRoutes.lesson(state.course.id, lesson.id),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
