import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

enum _Kind { loading, empty, error }

/// Loading, empty and error states. Replaces the content area, never the
/// whole screen.
class StateView extends StatelessWidget {
  /// Skeleton shaped like a course card. No spinner.
  const StateView.loading({super.key})
    : _kind = _Kind.loading,
      title = '',
      body = null,
      icon = null,
      actionLabel = null,
      onAction = null;

  const StateView.empty({
    super.key,
    required this.title,
    this.body,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  }) : _kind = _Kind.empty;

  /// Title says what failed, body says what to do, action retries.
  const StateView.error({
    super.key,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  }) : _kind = _Kind.error,
       icon = Icons.error_outline_rounded;

  final _Kind _kind;
  final String title;
  final String? body;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isError = _kind == _Kind.error;
    final body = this.body;
    final actionLabel = this.actionLabel;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: Space.spacing32.h,
        horizontal: Space.spacing24.w,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(Radii.small4),
      ),
      child: _kind == _Kind.loading
          ? _skeleton(c)
          : Semantics(
              liveRegion: isError,
              child: Column(
                spacing: Space.spacing12.h,
                children: [
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isError ? c.dangerSoft : c.surfaceTint,
                    ),
                    child: Icon(
                      icon,
                      size: 28.r,
                      color: isError ? c.danger : c.brand,
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: ThaheenText.title.copyWith(color: c.ink),
                  ),
                  if (body != null)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: Text(
                        body,
                        textAlign: TextAlign.center,
                        style: ThaheenText.body.copyWith(color: c.inkSecondary),
                      ),
                    ),
                  if (actionLabel != null && isError)
                    FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(actionLabel),
                    ),
                  if (actionLabel != null && !isError)
                    FilledButton.tonal(
                      onPressed: onAction,
                      child: Text(actionLabel),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _skeleton(ThaheenColors c) {
    Widget block({double? height, double widthFactor = 1}) =>
        FractionallySizedBox(
          widthFactor: widthFactor,
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: BorderRadius.circular(Radii.small4),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.spacing8.h,
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: block()),
        block(height: 16.h, widthFactor: 0.7),
        block(height: 12.h, widthFactor: 0.45),
      ],
    );
  }
}
