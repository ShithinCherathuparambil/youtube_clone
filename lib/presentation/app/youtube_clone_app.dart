import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:youtube_clone/l10n/app_localizations.dart';

import '../../injection_container.dart';
import '../../core/config/app_router.dart';
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/theme/theme_cubit.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/language/language_cubit.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/search/search_bloc.dart';

class YoutubeCloneApp extends StatelessWidget {
  const YoutubeCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<LanguageCubit>()),
        BlocProvider(create: (_) => sl<ProfileCubit>()..loadProfile()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<SearchBloc>()),
        BlocProvider(
          create: (_) => sl<DownloadManagerCubit>()..loadCachedDownloads(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale?>(
            builder: (context, locale) {
              return ScreenUtilInit(
                designSize: const Size(375, 812),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) => MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'YouTube Clone',
                  themeMode: themeMode,
                  theme: ThemeData.light(useMaterial3: true),
                  darkTheme: ThemeData.dark(useMaterial3: true),
                  routerConfig: appRouter,
                  locale: locale,
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: LanguageCubit.supportedLocales,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
