import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// Back chevron with a 44pt tap target. It mirrors in RTL, so it points
/// right in Arabic.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.tooltip});

  final String? tooltip;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip ?? 'back'.tr(),
    onPressed: context.pop,
    icon: const Icon(Icons.arrow_back_ios_new_rounded),
    iconSize: 20.r,
    color: context.colors.ink,
    style: IconButton.styleFrom(
      fixedSize: Size.square(44.r),
      shape: const CircleBorder(),
    ),
  );
}
