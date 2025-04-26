import 'package:flutter/material.dart';

class NavigationHelper {
  static Future<void> navigateSafely(
    BuildContext context,
    Widget destination, {
    bool replace = false,
  }) async {
    if (!context.mounted) return;

    if (replace) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }
}
