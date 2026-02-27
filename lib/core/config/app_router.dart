import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/video.dart';
import '../../presentation/pages/home_feed_page.dart';
import '../../presentation/pages/shorts_page.dart';
import '../../presentation/pages/subscriptions_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../../presentation/pages/watch_page.dart';
import '../../presentation/pages/downloads_page.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/auth_page.dart';
import '../../presentation/pages/main_navigation_page.dart';
import '../../presentation/pages/search_page.dart';
import '../../presentation/pages/channel_profile_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/edit_profile_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorShortsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellShorts');
final GlobalKey<NavigatorState> _shellNavigatorSubscriptionsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSubscriptions');
final GlobalKey<NavigatorState> _shellNavigatorLibraryKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellLibrary');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: SplashPage.route,
  routes: [
    GoRoute(
      path: SplashPage.route,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AuthPage.route,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AuthPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, navigationShell) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: MainNavigationPage(navigationShell: navigationShell),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: HomeFeedPage.route,
              builder: (context, state) => const HomeFeedPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorShortsKey,
          routes: [
            GoRoute(
              path: ShortsPage.route,
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>? ?? {};
                return ShortsPage(
                  initialVideos: args['initialVideos'] as List<Vido>?,
                  initialIndex: args['initialIndex'] as int?,
                  nextPageToken: args['nextPageToken'] as String?,
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/add',
              // Temporary placeholder for Add Action
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSubscriptionsKey,
          routes: [
            GoRoute(
              path: SubscriptionsPage.route,
              builder: (context, state) => const SubscriptionsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLibraryKey,
          routes: [
            GoRoute(
              path: ProfilePage.route,
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: DownloadsPage.route,
                  builder: (context, state) => const DownloadsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: SettingsPage.route,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: EditProfilePage.route,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return EditProfilePage(
          currentName: args['name'],
          currentHandle: args['handle'],
          currentImagePath: args['imagePath'],
        );
      },
    ),
    GoRoute(
      path: WatchPage.route,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final Map<String, dynamic> args =
            state.extra as Map<String, dynamic>? ?? {};
        final videoUrl =
            args['videoUrl'] as String? ??
            state.uri.queryParameters['videoUrl'] ??
            '';
        final title =
            args['title'] as String? ??
            state.uri.queryParameters['title'] ??
            '';
        final id =
            args['id'] as String? ?? state.uri.queryParameters['id'] ?? '';
        final channelName =
            args['channelName'] as String? ??
            state.uri.queryParameters['channelName'];
        final channelId =
            args['channelId'] as String? ??
            state.uri.queryParameters['channelId'];
        return WatchPage(
          videoUrl: videoUrl,
          title: title,
          id: id,
          channelName: channelName,
          channelId: channelId,
        );
      },
    ),
    GoRoute(
      path: SearchPage.route,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: ShortsPage.route,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return ShortsPage(
          initialVideos: args['initialVideos'] as List<Vido>?,
          initialIndex: args['initialIndex'] as int?,
          nextPageToken: args['nextPageToken'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/channel/:channelId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final channelId = state.pathParameters['channelId']!;
        return ChannelProfilePage(channelId: channelId);
      },
    ),
  ],
);
