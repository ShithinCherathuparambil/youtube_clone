import 'package:flutter/material.dart';

import '../pages/downloads_page.dart';
import '../pages/home_feed_page.dart';
import '../pages/library_page.dart';
import 'app_route_path.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  AppRouterDelegate();

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final PageStorageBucket _bucket = PageStorageBucket();
  int _currentTab = 0;

  @override
  AppRoutePath get currentConfiguration => AppRoutePath.home(_currentTab);

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _currentTab = configuration.tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('YouTube Clone'),
            ),
            body: PageStorage(
              bucket: _bucket,
              child: IndexedStack(
                index: _currentTab,
                children: const [
                  HomeFeedPage(),
                  LibraryPage(),
                  DownloadsPage(),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentTab,
              onTap: (index) {
                _currentTab = index;
                notifyListeners();
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Library'),
                BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Downloads'),
              ],
            ),
          ),
        ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}
