import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/theme/theme_cubit.dart';
import '../navigation/app_route_information_parser.dart';
import '../navigation/app_router_delegate.dart';

class YoutubeCloneApp extends StatefulWidget {
  const YoutubeCloneApp({super.key});

  @override
  State<YoutubeCloneApp> createState() => _YoutubeCloneAppState();
}

class _YoutubeCloneAppState extends State<YoutubeCloneApp> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
    _routeInformationParser = AppRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => sl<DownloadManagerCubit>()..loadCachedDownloads(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'YouTube Clone',
            themeMode: themeMode,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeInformationParser,
          );
        },
      ),
    );
  }
}
