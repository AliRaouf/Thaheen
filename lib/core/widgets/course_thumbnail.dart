import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 16:9 course image. Without one (or if the asset is missing) it shows the
/// brand's dashed circles instead of a grey box. Callers clip the corners.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    this.image,
    this.disc,
    this.discSize = 52,
    this.glow = false,
  });

  /// Asset path, e.g. `assets/images/anatomy.png`.
  final String? image;

  /// Icon in the centre disc. Defaults to a book on the placeholder only.
  final IconData? disc;
  final double discSize;

  final bool glow;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final image = this.image;
    final orbit = CustomPaint(painter: _OrbitPainter(c.brand));
    final discIcon = disc ?? (image == null ? Icons.menu_book_outlined : null);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: c.surfaceTint,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => orbit,
              )
            else
              orbit,
            // Dim real artwork behind a play disc so the disc stands out.
            if (image != null && disc != null) ColoredBox(color: c.scrim),
            if (discIcon != null)
              Center(
                child: Container(
                  width: discSize,
                  height: discSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.brand,
                    boxShadow: glow ? c.shadowGlow : null,
                  ),
                  child: Icon(
                    discIcon,
                    size: discSize * 0.46,
                    color: c.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Two dashed circles, drawn like the design's 160×90 SVG with "slice" fit.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.max(size.width / 160, size.height / 90);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    final center = size.center(Offset.zero);
    for (final r in const [30.0, 44.0]) {
      final rect = Rect.fromCircle(center: center, radius: r * scale);
      // 4-unit dashes, 5-unit gaps, as arc angles.
      final dash = 4 / r;
      final gap = 5 / r;
      for (var a = 0.0; a < 2 * math.pi; a += dash + gap) {
        canvas.drawArc(rect, a, dash, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.color != color;
}
