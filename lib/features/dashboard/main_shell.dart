import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/plan_provider.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Bottom-navigation shell: Home · Analyze · History · Profile.
///
/// "Analyze" opens the scan flow on top of the shell instead of being a
/// tab, so the scan always has its own back stack.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  /// 0 = Home, 1 = History, 2 = Profile.
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    // FUTURE DATABASE INTEGRATION: these load from the backend instead of
    // the in-memory mock services.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().loadHistory();
      context.read<PlanProvider>().load();
    });
  }

  void _selectTab(int tab) => setState(() => _tab = tab);

  void _startAnalysis() {
    context.read<ScanProvider>().ensureDraft();
    Navigator.pushNamed(context, AppRoutes.scanSelection);
  }

  // Bottom-nav index → tab index (Analyze is an action, not a tab).
  int get _navIndex => _tab == 0 ? 0 : _tab + 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(onSelectTab: _selectTab, onStartAnalysis: _startAnalysis),
          HistoryScreen(onStartAnalysis: _startAnalysis),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.background,
            indicatorColor: AppColors.primarySoft,
            labelTextStyle: WidgetStateProperty.all(
                AppTextStyles.small.copyWith(color: AppColors.textPrimary)),
          ),
          child: NavigationBar(
            height: 68,
            selectedIndex: _navIndex,
            onDestinationSelected: (i) {
              if (i == 1) {
                _startAnalysis();
              } else {
                _selectTab(i == 0 ? 0 : i - 1);
              }
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.face_retouching_natural_outlined),
                  label: 'Analyze'),
              NavigationDestination(
                  icon: Icon(Icons.history_rounded), label: 'History'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
