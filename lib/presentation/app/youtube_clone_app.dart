import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';
import '../../core/config/app_router.dart';
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/theme/theme_cubit.dart';
import '../bloc/auth/auth_bloc.dart';

class YoutubeCloneApp extends StatelessWidget {
  const YoutubeCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(
          create: (_) => sl<DownloadManagerCubit>()..loadCachedDownloads(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
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
            ),
          );
        },
      ),
    );
  }
}
