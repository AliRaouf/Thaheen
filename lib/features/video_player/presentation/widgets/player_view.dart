import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_format.dart';
import 'speed_selector.dart';

/// The 16:9 video with its overlay controls.
///
/// The controls stay left-to-right in Arabic too: media controls are not
/// mirrored. Sizes are plain numbers, not screenutil, because the same widget
/// also fills the screen in landscape fullscreen.
class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    required this.controller,
    required this.speed,
    required this.fullscreen,
    required this.onToggleFullscreen,
    required this.onSpeedTap,
    this.title,
    this.resumeFrom = Duration.zero,
  });

  final VideoPlayerController controller;
  final double speed;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onSpeedTap;

  /// Shown in the overlay's top bar (fullscreen only).
  final String? title;

  /// If non-zero, a "resuming from 01:12" pill shows for 3 seconds.
  final Duration resumeFrom;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  static const _hideAfter = Duration(seconds: 3);

  bool _visible = true;
  bool _showResume = false;
  Timer? _hideTimer;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _poke();
    if (widget.resumeFrom > Duration.zero) {
      _showResume = true;
      _resumeTimer = Timer(_hideAfter, () {
        if (mounted) setState(() => _showResume = false);
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _resumeTimer?.cancel();
    super.dispose();
  }

  /// Shows the controls and hides them again after 3 s of playback.
  void _poke() {
    _hideTimer?.cancel();
    if (!_visible) setState(() => _visible = true);
    _hideTimer = Timer(_hideAfter, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _toggle() {
    if (_visible) {
      _hideTimer?.cancel();
      setState(() => _visible = false);
    } else {
      _poke();
    }
  }

  void _seekBy(Duration delta) {
    final v = widget.controller.value;
    var target = v.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > v.duration) target = v.duration;
    widget.controller.seekTo(target);
    _poke();
  }

  void _playPause() {
    final v = widget.controller.value;
    if (v.isPlaying) {
      widget.controller.pause();
    } else {
      if (v.position >= v.duration) widget.controller.seekTo(Duration.zero);
      widget.controller.play();
    }
    _poke();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Reduced motion: controls stay visible.
    final alwaysShow = MediaQuery.disableAnimationsOf(context);
    // The 16:9 frame can't grow, so large system text is capped here to keep
    // the controls from overflowing.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: ColoredBox(
        color: c.playerStage,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              final show = _visible || !value.isPlaying || alwaysShow;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggle,
                  ),
                  IgnorePointer(
                    ignoring: !show,
                    child: AnimatedOpacity(
                      opacity: show ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: _Overlay(
                        value: value,
                        speed: widget.speed,
                        title: widget.fullscreen ? widget.title : null,
                        fullscreen: widget.fullscreen,
                        onTapBackground: _toggle,
                        onPlayPause: _playPause,
                        onSeekBy: _seekBy,
                        onSeekTo: (p) {
                          widget.controller.seekTo(p);
                          _poke();
                        },
                        onScrubStart: () => _hideTimer?.cancel(),
                        onSpeedTap: widget.onSpeedTap,
                        onToggleFullscreen: widget.onToggleFullscreen,
                      ),
                    ),
                  ),
                  if (_showResume)
                    Positioned(
                      top: 12,
                      left: 0,
                      right: 0,
                      child: Center(child: _ResumePill(widget.resumeFrom)),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({
    required this.value,
    required this.speed,
    required this.title,
    required this.fullscreen,
    required this.onTapBackground,
    required this.onPlayPause,
    required this.onSeekBy,
    required this.onSeekTo,
    required this.onScrubStart,
    required this.onSpeedTap,
    required this.onToggleFullscreen,
  });

  final VideoPlayerValue value;
  final double speed;
  final String? title;
  final bool fullscreen;
  final VoidCallback onTapBackground;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeekBy;
  final ValueChanged<Duration> onSeekTo;
  final VoidCallback onScrubStart;
  final VoidCallback onSpeedTap;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final time = ThaheenText.numeric.copyWith(
      fontSize: 12,
      height: 16 / 12,
      color: c.onScrim,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapBackground,
      child: ColoredBox(
        color: c.scrim,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ThaheenText.label.copyWith(color: c.onScrim),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: Space.spacing32,
                children: [
                  _RoundButton(
                    icon: Icons.replay_10_rounded,
                    tooltip: 'rewind_10'.tr(),
                    onTap: () => onSeekBy(const Duration(seconds: -10)),
                  ),
                  Tooltip(
                    message: value.isPlaying ? 'pause'.tr() : 'play'.tr(),
                    child: Material(
                      color: c.brand,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onPlayPause,
                        child: SizedBox.square(
                          dimension: 60,
                          child: Icon(
                            value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 34,
                            color: c.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _RoundButton(
                    icon: Icons.forward_10_rounded,
                    tooltip: 'forward_10'.tr(),
                    onTap: () => onSeekBy(const Duration(seconds: 10)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 4, 4),
                child: Row(
                  spacing: Space.spacing8,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Text(formatDuration(value.position), style: time),
                    ),
                    Expanded(
                      child: _Scrubber(
                        value: value,
                        onSeekTo: onSeekTo,
                        onStart: onScrubStart,
                      ),
                    ),
                    Text(formatDuration(value.duration), style: time),
                    // Small chip, but the tap area is a full 44×44.
                    Semantics(
                      button: true,
                      label: 'speed'.tr(),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: onSpeedTap,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            child: Center(
                              widthFactor: 1,
                              child: DecoratedBox(
                                decoration: ShapeDecoration(
                                  color: c.onScrim.withValues(alpha: 0.16),
                                  shape: const StadiumBorder(),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Space.spacing8,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    speedLabel(speed),
                                    style: time.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _RoundButton(
                      icon: fullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      tooltip: fullscreen
                          ? 'exit_fullscreen'.tr()
                          : 'fullscreen'.tr(),
                      size: 24,
                      onTap: onToggleFullscreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seek bar. While dragging it shows the drag position, not the video's,
/// so the thumb doesn't jump back while the video catches up.
class _Scrubber extends StatefulWidget {
  const _Scrubber({
    required this.value,
    required this.onSeekTo,
    required this.onStart,
  });

  final VideoPlayerValue value;
  final ValueChanged<Duration> onSeekTo;
  final VoidCallback onStart;

  @override
  State<_Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<_Scrubber> {
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final max = widget.value.duration.inMilliseconds.toDouble();
    final pos = widget.value.position.inMilliseconds.toDouble();
    return Semantics(
      label: 'seek'.tr(),
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          activeTrackColor: c.brand,
          inactiveTrackColor: c.onScrim.withValues(alpha: 0.3),
          thumbColor: c.onScrim,
          overlayColor: c.onScrim.withValues(alpha: 0.12),
          trackShape: const RoundedRectSliderTrackShape(),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        ),
        child: Slider(
          max: max <= 0 ? 1 : max,
          value: (_dragMs ?? pos).clamp(0, max <= 0 ? 1 : max),
          onChangeStart: (_) => widget.onStart(),
          onChanged: (v) => setState(() => _dragMs = v),
          onChangeEnd: (v) {
            widget.onSeekTo(Duration(milliseconds: v.round()));
            setState(() => _dragMs = null);
          },
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 30,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onTap,
    iconSize: size,
    color: context.colors.onScrim,
    constraints: const BoxConstraints.tightFor(width: 44, height: 44),
    padding: EdgeInsets.zero,
    icon: Icon(icon),
  );
}

class _ResumePill extends StatelessWidget {
  const _ResumePill(this.from);

  final Duration from;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.spacing12,
        vertical: 4,
      ),
      decoration: ShapeDecoration(
        color: c.playerStage,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(Icons.history_rounded, size: 16, color: c.onScrim),
          Text(
            'resume_from'.tr(args: [formatDuration(from)]),
            style: ThaheenText.numeric.copyWith(color: c.onScrim),
          ),
        ],
      ),
    );
  }
}
