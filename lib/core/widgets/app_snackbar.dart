import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One friendly message at a time, 4 s (6 s with an action). Colours, shape
/// and floating placement come from the theme's `snackBarTheme`.
void showAppSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final c = context.colors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(seconds: actionLabel == null ? 4 : 6),
        content: Row(
          spacing: Space.spacing12,
          children: [
            if (icon != null) Icon(icon, size: 20, color: c.onSnackbar),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
}
