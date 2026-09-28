import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clamped_app_bar.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/state_view.dart';
import '../logic/courses_cubit.dart';
import 'widgets/app_bar_controls.dart';
import 'widgets/continue_card.dart';
import 'widgets/course_card.dart';

/// Home: greeting, Continue card, then one card per course.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on language switch (`.tr()` alone doesn't)
    return Scaffold(
      appBar: const _AppBar(),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) => ListView(
          padding: EdgeInsets.all(Space.spacing16.w).copyWith(
            // Custom padding replaces ListView's safe-area inset, so add the
            // bottom inset back to keep the last card above the home bar.
            bottom: Space.spacing24.h + MediaQuery.paddingOf(context).bottom,
          ),
          children: switch (state) {
            CoursesLoading() => [
              const StateView.loading(),
              SizedBox(height: Space.spacing16.h),
              const StateView.loading(),
            ],
            CoursesError() => [
              StateView.error(
                title: 'courses_error_title'.tr(),
                body: 'courses_error_body'.tr(),
                actionLabel: 'retry'.tr(),
                onAction: context.read<CoursesCubit>().load,
              ),
            ],
            CoursesLoaded() => _loadedContent(context, state),
          },
        ),
      ),
    );
  }

  List<Widget> _loadedContent(BuildContext context, CoursesLoaded state) {
    if (state.courses.isEmpty) {
      return [
        _Greeting('welcome'.tr()),
        SizedBox(height: Space.spacing24.h),
        SectionTitle('my_courses'.tr()),
        SizedBox(height: Space.spacing16.h),
        StateView.empty(
          icon: Icons.menu_book_outlined,
          title: 'no_courses_title'.tr(),
          body: 'no_courses_body'.tr(),
          actionLabel: 'refresh'.tr(),
          onAction: context.read<CoursesCubit>().load,
        ),
      ];
    }

    final continueItem = state.continueItem;
    var lessonCount = 0;
    for (final summary in state.courses) {
      lessonCount += summary.course.lessons.length;
    }

    return [
      _Greeting('greeting'.tr()),
      if (continueItem != null) ...[
        SizedBox(height: Space.spacing16.h),
        ContinueCard(
          item: continueItem,
          onTap: () => context.go(
            AppRoutes.lesson(continueItem.course.id, continueItem.lesson.id),
          ),
        ),
      ],
      SizedBox(height: Space.spacing24.h),
      SectionTitle(
        'my_courses'.tr(),
        subtitle:
            '${'courses_count'.plural(state.courses.length)} · '
            '${'lessons_count'.plural(lessonCount)}',
      ),
      for (final summary in state.courses) ...[
        SizedBox(height: Space.spacing16.h),
        CourseCard(
          course: summary.course,
          percent: summary.percent,
          onTap: () => context.push(AppRoutes.course(summary.course.id)),
        ),
      ],
    ];
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: ThaheenText.body.copyWith(color: context.colors.inkSecondary),
  );
}

/// Logo and app name, with the theme and language buttons at the end.
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    context.locale; // const widget: rebuild on language switch
    return ClampedAppBar(
      AppBar(
        titleSpacing: Space.spacing16.w,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Space.spacing8.w,
          children: [
            Image.asset(
              'assets/images/thaheen_mark.png',
              width: 32.r,
              height: 32.r,
              excludeFromSemantics: true,
            ),
            Text('app_name'.tr()),
          ],
        ),
        actionsPadding: EdgeInsetsDirectional.only(end: Space.spacing16.w),
        actions: [
          const ThemeToggleButton(),
          SizedBox(width: Space.spacing8.w),
          const LanguageSwitch(),
        ],
      ),
    );
  }
}
