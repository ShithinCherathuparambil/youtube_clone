import 'package:flutter/material.dart';

import 'app_route_path.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final location = routeInformation.uri.path;
    if (location.startsWith('/library')) {
      return const AppRoutePath.home(1);
    }
    if (location.startsWith('/downloads')) {
      return const AppRoutePath.home(2);
    }
    return const AppRoutePath.home(0);
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    switch (configuration.tabIndex) {
      case 1:
        return RouteInformation(uri: Uri.parse('/library'));
      case 2:
        return RouteInformation(uri: Uri.parse('/downloads'));
      default:
        return RouteInformation(uri: Uri.parse('/'));
    }
  }
}
