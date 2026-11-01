import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plan_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/user_provider.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import 'routes.dart';

class SkinGuardApp extends StatelessWidget {
  const SkinGuardApp({
    super.key,
    required this.services,
    this.initialRoute = AppRoutes.splash,
  });

  final AppServices services;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: services),
        ChangeNotifierProvider(
            create: (_) => UserProvider(services.auth, services.profile)),
        ChangeNotifierProvider(
            create: (_) => ScanProvider(services.scan, services.analysis)),
        ChangeNotifierProvider(create: (_) => PlanProvider(services.plan)),
      ],
      child: MaterialApp(
        title: 'SkinGuard AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
