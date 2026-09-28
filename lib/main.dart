import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/data/course_repository.dart';
import 'core/data/progress_repository.dart';
import 'core/data/settings_store.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait-only; the player's fullscreen is the one exception (fullscreen.dart).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsStore(prefs);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      ignorePluralRules: false, // real Arabic plurals: درسان، 3 دروس، 11 درساً
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<CourseRepository>(
            create: (_) => AssetCourseRepository(),
          ),
          RepositoryProvider<ProgressRepository>(
            create: (_) => PrefsProgressRepository(prefs),
          ),
          RepositoryProvider.value(value: settings),
        ],
        child: BlocProvider(
          create: (_) => ThemeCubit(settings),
          child: const ThaheenApp(),
        ),
      ),
    ),
  );
}

class ThaheenApp extends StatelessWidget {
  const ThaheenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // the design's phone frame
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        onGenerateTitle: (_) => 'app_name'.tr(),
        theme: ThaheenTheme.light,
        darkTheme: ThaheenTheme.dark,
        themeMode: context.watch<ThemeCubit>().state,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
