import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

/// Heading with the site's blue brush underline.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.spacing4.h,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Approximates the site's painted brush stroke; swap for the real
            // asset if one is available.
            PositionedDirectional(
              start: -2,
              end: -2,
              bottom: 1,
              height: 7,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.skewX(-0.21)..rotateZ(-0.017),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.brand.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(2),
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(3),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Text(title, style: ThaheenText.titleLg.copyWith(color: c.ink)),
          ],
        ),
        if (subtitle != null)
          Text(subtitle!, style: ThaheenText.body.copyWith(color: c.inkSubtle)),
      ],
    );
  }
}
