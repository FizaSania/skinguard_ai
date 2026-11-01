import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/app_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // All services are mock implementations for the static frontend.
  // See lib/services/app_services.dart to plug in real backend / ML / DB.
  runApp(SkinGuardApp(services: AppServices()));
}
