import 'package:flutter/material.dart';

/// App bars are fixed-height chrome, so their text scaling is capped (as iOS
/// does for navigation bars). Without it, titles and the 44pt controls clip at
/// the largest accessibility text sizes. Page content still scales fully.
class ClampedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClampedAppBar(this.appBar, {super.key});

  final AppBar appBar;

  @override
  Size get preferredSize => appBar.preferredSize;

  @override
  Widget build(BuildContext context) =>
      MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: appBar);
}
