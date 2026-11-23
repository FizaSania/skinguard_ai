import 'package:flutter/material.dart';

import 'app/app.dart';
import 'providers/settings_provider.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsProvider.load();
  // All services are mock implementations for the static frontend.
  // See lib/services/app_services.dart to plug in real backend / ML / DB.
  runApp(SkinGuardApp(services: AppServices(), settings: settings));
}
