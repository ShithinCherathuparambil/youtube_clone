import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'slide_right_route.dart';

RouteFactory onAppGenerateRoute() => (settings) {
      Route<dynamic> getRoute(Widget child) {
        if (Platform.isIOS) {
          return CupertinoPageRoute(
            builder: (context) => child,
            settings: settings,
          );
        } else {
          return SlideRightRoute(child, settings.name);
        }
      }

      switch (settings.name) {
        // case SplashScreen.route:
        //   return getRoute(const SplashScreen());
     
        default:
          return null;
      }
    };
