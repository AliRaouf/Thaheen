import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

/// Completion as a pill bar. Fills from the inline start, so it grows right to
/// left in Arabic (unlike the video scrubber, which stays LTR).
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.percent,
    this.small = false,
    this.showLabel = true,
  });

  /// 0–100, already rounded.
  final int percent;
  final bool small;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = percent.clamp(0, 100);
    final done = value == 100;
    return Semantics(
      value: '$value%',
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.pill),
              child: Container(
                height: small ? 4 : 6,
                color: c.surfaceTint,
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: value / 100,
                  heightFactor: 1,
                  child: ColoredBox(color: done ? c.success : c.brand),
                ),
              ),
            ),
          ),
          if (showLabel) ...[
            SizedBox(width: Space.spacing8.w),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 36.w),
              child: Text(
                '$value%',
                textAlign: TextAlign.end,
                style: ThaheenText.numeric.copyWith(
                  fontWeight: FontWeight.w600,
                  color: done ? c.successStrong : c.title,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
