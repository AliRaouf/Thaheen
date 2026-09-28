import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/course_details/logic/course_details_cubit.dart';
import '../../features/course_details/presentation/course_details_screen.dart';
import '../../features/courses/logic/courses_cubit.dart';
import '../../features/courses/presentation/courses_screen.dart';
import '../../features/video_player/logic/video_player_cubit.dart';
import '../../features/video_player/presentation/video_player_screen.dart';

/// Path builders, so screens never hand-write URLs.
abstract class AppRoutes {
  static const courses = '/';
  static String course(String courseId) => '/courses/$courseId';
  static String lesson(String courseId, String lessonId) =>
      '/courses/$courseId/lessons/$lessonId';
}

/// Without this key, going from lesson 1 to lesson 2 reuses the same page
/// (go_router sees the same route pattern), so the old cubit and video stay.
/// Keying by the full URL makes lesson 2 a new page with a new cubit, and the
/// old cubit's close() saves lesson 1's progress.
Page<void> _page(GoRouterState state, Widget child) =>
    MaterialPage<void>(key: ValueKey(state.matchedLocation), child: child);

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.courses,
      builder: (context, state) => BlocProvider(
        create: (context) =>
            CoursesCubit(context.read(), context.read())..load(),
        child: const CoursesScreen(),
      ),
      routes: [
        GoRoute(
          path: 'courses/:courseId',
          pageBuilder: (context, state) => _page(
            state,
            BlocProvider(
              create: (context) => CourseDetailsCubit(
                state.pathParameters['courseId']!,
                context.read(),
                context.read(),
              )..load(),
              child: const CourseDetailsScreen(),
            ),
          ),
          routes: [
            GoRoute(
              path: 'lessons/:lessonId',
              pageBuilder: (context, state) => _page(
                state,
                BlocProvider(
                  create: (context) =>
                      VideoPlayerCubit(
                        context.read(),
                        context.read(),
                        context.read(),
                      )..load(
                        state.pathParameters['courseId']!,
                        state.pathParameters['lessonId']!,
                      ),
                  child: const VideoPlayerScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
