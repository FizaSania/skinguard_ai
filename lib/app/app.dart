import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plan_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/user_provider.dart';
import '../services/app_services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'routes.dart';

class SkinGuardApp extends StatelessWidget {
  const SkinGuardApp({
    super.key,
    required this.services,
    this.settings,
    this.initialRoute = AppRoutes.splash,
  });

  final AppServices services;
  final SettingsProvider? settings;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: services),
        ChangeNotifierProvider(create: (_) => settings ?? SettingsProvider()),
        ChangeNotifierProvider(
            create: (_) => UserProvider(services.auth, services.profile)),
        ChangeNotifierProvider(
            create: (_) => ScanProvider(services.scan, services.analysis)),
        ChangeNotifierProvider(create: (_) => PlanProvider(services.plan)),
      ],
      child: _ThemedApp(initialRoute: initialRoute),
    );
  }
}

/// Applies the appearance and text-size settings to the whole app.
class _ThemedApp extends StatefulWidget {
  const _ThemedApp({required this.initialRoute});

  final String initialRoute;

  @override
  State<_ThemedApp> createState() => _ThemedAppState();
}

class _ThemedAppState extends State<_ThemedApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => setState(() {});

  bool _resolveDark(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark,
      };

  /// Many widgets are `const`, so a palette change must refresh them
  /// explicitly. Open pages and form input are preserved.
  void _refreshAllWidgets() {
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    if (mounted) (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final dark = _resolveDark(settings.themeMode);
    if (dark != AppColors.isDark) {
      AppColors.setDark(dark);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _refreshAllWidgets());
    }

    return MaterialApp(
      title: 'SkinGuard AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current(),
      themeAnimationDuration: Duration.zero,
      initialRoute: widget.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(settings.textSize.scale)),
        child: child!,
      ),
    );
  }
}
