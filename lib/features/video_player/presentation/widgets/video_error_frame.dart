import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Missing or corrupt video. Drawn inside the same 16:9 frame as the video so
/// the page doesn't jump, and the rest of the page stays usable.
class VideoErrorFrame extends StatelessWidget {
  const VideoErrorFrame({
    super.key,
    required this.onRetry,
    required this.onBack,
  });

  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The player background is dark in both themes, so use the dark
    // theme's button colours here.
    const onStage = ThaheenColors.dark;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: c.playerStage,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.dangerSoft,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 22,
                    color: c.danger,
                  ),
                ),
                Text(
                  'video_error_title'.tr(),
                  textAlign: TextAlign.center,
                  style: ThaheenText.title.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                    color: c.onScrim,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    'video_error_body'.tr(),
                    textAlign: TextAlign.center,
                    style: ThaheenText.numeric.copyWith(
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: c.onScrim.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                Wrap(
                  spacing: Space.spacing8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: onStage.primary,
                        foregroundColor: onStage.onPrimary,
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text('retry'.tr()),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: c.onScrim,
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: onBack,
                      child: Text('back_to_course'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
