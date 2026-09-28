import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../logic/video_player_cubit.dart';

/// 1.0 → "1x", 1.25 → "1.25x".
String speedLabel(double speed) =>
    '${speed == speed.truncateToDouble() ? speed.toInt() : speed}x';

/// 1x / 1.25x / 1.5x / 2x pills; the selected one is `primary`.
class SpeedSelector extends StatelessWidget {
  const SpeedSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final double selected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: Space.spacing8,
      runSpacing: Space.spacing8,
      children: [
        for (final speed in VideoPlayerCubit.speeds)
          Semantics(
            selected: speed == selected,
            button: true,
            child: Material(
              color: speed == selected ? c.primary : c.surface,
              shape: StadiumBorder(
                side: BorderSide(
                  color: speed == selected ? c.primary : c.lineStrong,
                ),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelected(speed),
                child: ConstrainedBox(
                  // 44px touch target.
                  constraints: const BoxConstraints(
                    minWidth: 64,
                    minHeight: 44,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.spacing12,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        speedLabel(speed),
                        style: ThaheenText.numeric.copyWith(
                          fontSize: 14,
                          color: speed == selected ? c.onPrimary : c.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
