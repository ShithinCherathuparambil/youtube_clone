import 'package:flutter/material.dart';

import 'app_route_path.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final location = routeInformation.uri.path;
    if (location.startsWith('/shorts')) {
      return const AppRoutePath.home(1);
    }
    if (location.startsWith('/subscriptions')) {
      return const AppRoutePath.home(3);
    }
    if (location.startsWith('/library')) {
      return const AppRoutePath.home(4);
    }
    return const AppRoutePath.home(0);
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    switch (configuration.tabIndex) {
      case 1:
        return RouteInformation(uri: Uri.parse('/shorts'));
      case 3:
        return RouteInformation(uri: Uri.parse('/subscriptions'));
      case 4:
        return RouteInformation(uri: Uri.parse('/library'));
      default:
        return RouteInformation(uri: Uri.parse('/'));
    }
  }
}
