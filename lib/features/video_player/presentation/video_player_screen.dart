import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/domain/models/course.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/clamped_app_bar.dart';
import '../../../core/widgets/state_view.dart';
import '../logic/video_player_cubit.dart';
import 'fullscreen.dart';
import 'widgets/next_lesson_bar.dart';
import 'widgets/player_details.dart';
import 'widgets/player_view.dart';
import 'widgets/speed_selector.dart';
import 'widgets/video_error_frame.dart';

/// Owns the `VideoPlayerController` and reports position, pauses and errors
/// to [VideoPlayerCubit], which holds the rules (resume, 90%, unlock).
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _fullscreen = false;
  bool _wasPlaying = false;

  VideoPlayerCubit get _cubit => context.read<VideoPlayerCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Saved here because the "next lesson" button in the completion snackbar
  /// can be tapped after this page is closed, when `context` is unusable.
  late GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    if (_fullscreen) exitFullscreen();
    super.dispose();
  }

  /// Pause and save when the app goes to the background, so progress
  /// survives if the OS kills the app there.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _controller?.pause();
    _cubit.saveNow();
  }

  Future<void> _load(VideoPlayerReady s) async {
    _disposeController();
    final controller = VideoPlayerController.asset(s.lesson.video);
    setState(() => _controller = controller);
    try {
      await controller.initialize();
      // initialize() takes a while. If the page closed or retry created a
      // new controller in the meantime, this one is stale: stop here.
      if (_controller != controller) return;
      await controller.seekTo(s.resumeFrom);
      await controller.setPlaybackSpeed(s.speed);
      controller.addListener(_onTick);
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      // Missing or corrupt file.
      if (_controller == controller) _onFailed();
    }
  }

  /// Runs on every controller update (several times a second).
  void _onTick() {
    final value = _controller?.value;
    if (value == null) return;
    if (value.hasError) {
      _onFailed();
      return;
    }
    _cubit.onProgress(value.position, value.duration);
    final justPaused = _wasPlaying && !value.isPlaying;
    if (justPaused) _cubit.saveNow();
    _wasPlaying = value.isPlaying;
  }

  void _onFailed() {
    _disposeController();
    if (!mounted) return;
    setState(() {});
    _cubit.onVideoError();
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.removeListener(_onTick);
      controller.dispose();
    }
  }

  void _setSpeed(double speed) {
    _cubit.setSpeed(speed);
    _controller?.setPlaybackSpeed(speed);
  }

  Future<void> _toggleFullscreen() async {
    // A snackbar would sit across the video in landscape.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _fullscreen = !_fullscreen);
    await (_fullscreen ? enterFullscreen() : exitFullscreen());
  }

  void _goTo(Course course, Lesson lesson) =>
      _router.go(AppRoutes.lesson(course.id, lesson.id));

  void _openSpeedSheet(double selected) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.spacing16),
          child: Labeled(
            'speed'.tr(),
            SpeedSelector(
              selected: selected,
              onSelected: (speed) {
                _setSpeed(speed);
                Navigator.pop(sheetContext);
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The lesson just became ready (first load, or after "retry").
  bool _shouldCreateController(VideoPlayerState before, VideoPlayerState now) {
    if (now is! VideoPlayerReady || now.videoFailed) return false;
    return before is! VideoPlayerReady || before.videoFailed;
  }

  /// This update crossed the 90% mark.
  bool _justCompleted(VideoPlayerState before, VideoPlayerState now) {
    if (before is! VideoPlayerReady || now is! VideoPlayerReady) return false;
    return !before.completed && now.completed;
  }

  /// Skip rebuilds when only the position changed (several times a second).
  /// PlayerView listens to the controller directly for the time and seek bar.
  bool _shouldRebuild(VideoPlayerState before, VideoPlayerState now) {
    if (before is! VideoPlayerReady || now is! VideoPlayerReady) return true;
    return before.completed != now.completed ||
        before.speed != now.speed ||
        before.videoFailed != now.videoFailed ||
        before.nextStatus != now.nextStatus;
  }

  void _showCompletedSnackBar(VideoPlayerReady state) {
    final next = state.nextLesson;
    showAppSnackBar(
      context,
      'lesson_completed'.tr(),
      icon: Icons.check_circle_outline_rounded,
      actionLabel: next == null ? null : 'next_lesson'.tr(),
      onAction: next == null ? null : () => _goTo(state.course, next),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on language switch (`.tr()` alone doesn't)
    return MultiBlocListener(
      listeners: [
        BlocListener<VideoPlayerCubit, VideoPlayerState>(
          listenWhen: _shouldCreateController,
          listener: (_, state) => _load(state as VideoPlayerReady),
        ),
        BlocListener<VideoPlayerCubit, VideoPlayerState>(
          listenWhen: _justCompleted,
          listener: (context, state) =>
              _showCompletedSnackBar(state as VideoPlayerReady),
        ),
      ],
      child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
        buildWhen: _shouldRebuild,
        builder: (context, state) => switch (state) {
          VideoPlayerLoading() => _page(title: '', children: [_stage(null)]),
          VideoPlayerLoadError() => _page(
            title: '',
            children: [
              Padding(
                padding: EdgeInsets.all(Space.spacing16.w),
                child: StateView.error(title: 'lesson_not_found'.tr()),
              ),
            ],
          ),
          VideoPlayerLocked() => _page(
            title: '',
            children: [
              Padding(
                padding: EdgeInsets.all(Space.spacing16.w),
                child: StateView.empty(
                  icon: Icons.lock_outline_rounded,
                  title: 'locked_hint'.tr(),
                  actionLabel: 'back_to_course'.tr(),
                  onAction: context.pop,
                ),
              ),
            ],
          ),
          VideoPlayerReady() when _fullscreen => PopScope(
            // Back leaves fullscreen first, not the page.
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _toggleFullscreen();
            },
            child: Scaffold(
              backgroundColor: context.colors.playerStage,
              body: Center(child: _stage(state)),
            ),
          ),
          VideoPlayerReady() => _page(
            title: state.course.title,
            bottomBar: NextLessonBar(state: state, onNext: _goTo),
            children: [
              _stage(state),
              Padding(
                padding: EdgeInsets.all(Space.spacing16.w),
                child: PlayerDetails(
                  state: state,
                  onSpeed: _setSpeed,
                  onNext: _goTo,
                ),
              ),
            ],
          ),
        },
      ),
    );
  }

  Widget _page({
    required String title,
    required List<Widget> children,
    Widget? bottomBar,
  }) => Scaffold(
    appBar: ClampedAppBar(
      AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: Space.spacing4.w,
        titleTextStyle: ThaheenText.titleSm.copyWith(color: context.colors.ink),
        title: Row(
          spacing: Space.spacing4.w,
          children: [
            AppBackButton(tooltip: 'back_to_course'.tr()),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    ),
    body: ListView(children: children),
    // Text scaling is capped like the app bar's, so the pinned bar can't
    // cover the screen at the largest text sizes.
    bottomNavigationBar: bottomBar == null
        ? null
        : MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: bottomBar,
          ),
  );

  /// The 16:9 area: a spinner, the video, or the video error.
  Widget _stage(VideoPlayerReady? state) {
    final controller = _controller;
    if (state != null && state.videoFailed) {
      return VideoErrorFrame(onRetry: _cubit.retry, onBack: context.pop);
    }
    if (state == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: context.colors.playerStage,
          child: Center(
            child: CircularProgressIndicator(color: context.colors.brand),
          ),
        ),
      );
    }
    return PlayerView(
      controller: controller,
      speed: state.speed,
      fullscreen: _fullscreen,
      title: state.lesson.title,
      resumeFrom: _fullscreen ? Duration.zero : state.resumeFrom,
      onToggleFullscreen: _toggleFullscreen,
      onSpeedTap: () => _openSpeedSheet(state.speed),
    );
  }
}
