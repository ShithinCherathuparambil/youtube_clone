import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'error_view.dart';

class ConnectionErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const ConnectionErrorView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      message: 'Please check your internet connection and try again.',
      icon: FontAwesomeIcons.wifi,
      onRetry: onRetry,
    );
  }
}
