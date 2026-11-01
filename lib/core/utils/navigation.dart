import 'package:flutter/material.dart';

import '../../app/routes.dart';

/// Returns to an existing Results route if one is on the stack, otherwise
/// opens the latest result. Avoids stacking duplicate result screens.
void backToResults(BuildContext context) {
  var found = false;
  Navigator.popUntil(context, (route) {
    final name = route.settings.name;
    if (name == AppRoutes.results) {
      found = true;
      return true;
    }
    return name == AppRoutes.shell || route.isFirst;
  });
  if (!found) Navigator.pushNamed(context, AppRoutes.results);
}
