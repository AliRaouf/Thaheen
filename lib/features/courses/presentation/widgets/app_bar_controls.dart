import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';

/// Sun/moon button. The icon shows the theme a tap switches *to*.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return IconButton.filledTonal(
      tooltip: (isDark ? 'theme_to_light' : 'theme_to_dark').tr(),
      style: IconButton.styleFrom(
        fixedSize: Size.square(44.r),
        shape: const CircleBorder(),
      ),
      onPressed: () => context.read<ThemeCubit>().toggleTheme(brightness),
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}

/// "EN | ع" pill. The current language is highlighted.
///
/// It stays left-to-right in both languages, so the two options don't swap
/// sides when the layout flips.
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.colors.surfaceSunken,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Segment(
              label: 'EN',
              semanticLabel: 'english'.tr(),
              selected: !isArabic,
              onTap: () => context.setLocale(const Locale('en')),
            ),
            _Segment(
              label: 'ع',
              semanticLabel: 'arabic'.tr(),
              selected: isArabic,
              onTap: () => context.setLocale(const Locale('ar')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // In dark mode `surface` is darker than the pill, so the selected
    // circle uses `lineStrong` to still look raised.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color? circleColor;
    if (!selected) {
      circleColor = null;
    } else if (isDark) {
      circleColor = c.lineStrong;
    } else {
      circleColor = c.surface;
    }
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: selected ? null : onTap,
        // 44×44 tap area around a smaller highlighted circle.
        child: SizedBox.square(
          dimension: 44.r,
          child: Padding(
            padding: EdgeInsets.all(4.r),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: circleColor,
                shape: const StadiumBorder(),
              ),
              child: Center(
                child: Text(
                  label,
                  style: ThaheenText.label.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? c.ink : c.inkSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
