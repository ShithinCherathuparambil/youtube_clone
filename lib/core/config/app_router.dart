import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/home_feed_page.dart';
import '../../presentation/pages/shorts_page.dart';
import '../../presentation/pages/subscriptions_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../../presentation/pages/watch_page.dart';
import '../../presentation/pages/downloads_page.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/auth_page.dart';
import '../../presentation/pages/main_navigation_page.dart';

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
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/auth',
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
              path: '/home',
              builder: (context, state) => const HomeFeedPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorShortsKey,
          routes: [
            GoRoute(
              path: '/shorts',
              builder: (context, state) => const ShortsPage(),
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
              path: '/subscriptions',
              builder: (context, state) => const SubscriptionsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLibraryKey,
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'downloads',
                  builder: (context, state) => const DownloadsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/watch',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return WatchPage(
          videoUrl:
              args['videoUrl'] as String? ??
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          title: args['title'] as String? ?? 'Video',
        );
      },
    ),
  ],
);
