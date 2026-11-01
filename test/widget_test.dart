import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skinguard_ai/app/app.dart';
import 'package:skinguard_ai/app/routes.dart';
import 'package:skinguard_ai/services/analysis_service.dart';
import 'package:skinguard_ai/services/app_services.dart';
import 'package:skinguard_ai/theme/app_text_styles.dart';

Widget _app({String initialRoute = AppRoutes.splash}) => SkinGuardApp(
      services: AppServices(
        analysis: MockSkinAnalysisService(
            stageDelay: const Duration(milliseconds: 20)),
      ),
      initialRoute: initialRoute,
    );

Future<void> _tap(WidgetTester tester, Finder finder) async {
  // Lazily built list items may not exist until scrolled to.
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200,
        scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _loginAsDemo(WidgetTester tester) async {
  await tester.pumpWidget(_app(initialRoute: AppRoutes.login));
  await tester.pumpAndSettle();
  await _tap(tester, find.text('Fill demo'));
  await _tap(tester, find.widgetWithText(FilledButton, 'Log In'));
  // Dashboard loads mock history / plan.
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => AppTextStyles.useGoogleFonts = false);

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
  });

  testWidgets('Splash → Get Started opens login', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.text('Get Started'), findsOneWidget);
    await _tap(tester, find.text('Get Started'));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('Login validates empty and invalid input', (tester) async {
    await tester.pumpWidget(_app(initialRoute: AppRoutes.login));
    await tester.pumpAndSettle();
    await _tap(tester, find.widgetWithText(FilledButton, 'Log In'));
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login_email')), 'not-an-email');
    await _tap(tester, find.widgetWithText(FilledButton, 'Log In'));
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('Demo login reaches dashboard and tiles navigate',
      (tester) async {
    await _loginAsDemo(tester);
    expect(find.text('Your personal skincare assistant'), findsOneWidget);
    expect(find.text('Quick Access'), findsOneWidget);

    await _tap(tester, find.text('Lifestyle Guide'));
    expect(find.text('Sleep'), findsOneWidget);
    await _tap(tester, find.byTooltip('Back'));

    await _tap(tester, find.text('My Plan Tracker'));
    expect(find.text('2 of 5 done today'), findsNothing);
    expect(find.text('0 of 5 done today'), findsOneWidget);
    await _tap(tester, find.text('Cleanse with Gentle Gel Cleanser').first);
    expect(find.text('1 of 5 done today'), findsOneWidget);
    await _tap(tester, find.byTooltip('Back'));

    // Bottom navigation
    await _tap(tester, find.text('History'));
    expect(find.text('Scan history'), findsOneWidget);
    await _tap(tester, find.text('Profile'));
    expect(find.text('Skin profile'), findsOneWidget);
  });

  testWidgets('Sign up validates and leads to onboarding', (tester) async {
    await tester.pumpWidget(_app(initialRoute: AppRoutes.signup));
    await tester.pumpAndSettle();
    await _tap(tester, find.widgetWithText(FilledButton, 'Create Account'));
    expect(find.text('Full name is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('signup_name')), 'Sara Ali');
    await tester.enterText(
        find.byKey(const Key('signup_email')), 'sara@example.com');
    await tester.enterText(find.byKey(const Key('signup_phone')), '03001234567');
    await tester.enterText(find.byKey(const Key('signup_password')), 'abc12345');
    await _tap(tester, find.widgetWithText(FilledButton, 'Create Account'));
    expect(find.text('Help us profile you'), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
  });

  testWidgets('Patch flow captures each region and shows demo results',
      (tester) async {
    await _loginAsDemo(tester);
    await _tap(tester, find.text('Start Skin Analysis'));
    expect(find.text('Select patch area'), findsOneWidget);

    // Patch mode requires a region.
    await _tap(tester, find.text('Detailed Patch'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.textContaining('Select at least one face region'),
        findsOneWidget);

    await _tap(tester, find.text('Forehead').last);
    await _tap(tester, find.text('Nose').last);
    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.text('Patch details'), findsOneWidget);

    await _tap(tester, find.text('Redness'));
    await _tap(tester, find.text('1–4 weeks'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.textContaining('Page 2 of 2'), findsOneWidget);

    await _tap(tester, find.text('No product'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));

    // Region 1: Forehead
    expect(find.text('Forehead'), findsWidgets);
    await _tap(tester, find.text('Use sample image (demo)'));
    expect(find.text('Review your photo'), findsOneWidget);
    expect(find.text('Region: Forehead'), findsOneWidget);
    await _tap(tester, find.text('Next region'));

    // Region 2: Nose
    expect(find.text('1 of 2 regions captured'), findsOneWidget);
    await _tap(tester, find.text('Use sample image (demo)'));
    expect(find.text('Region: Nose'), findsOneWidget);
    await _tap(tester, find.widgetWithText(FilledButton, 'Continue'));

    // Analyzing → results
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('Analysis complete'), findsOneWidget);
    await _tap(tester, find.text('View Results'));
    expect(find.text('Skin Analysis'), findsOneWidget);
    expect(find.text('Demo result'), findsOneWidget);
    // Only the two captured regions have findings.
    expect(find.widgetWithText(Material, 'Forehead'), findsWidgets);
    expect(find.text('Left Cheek'), findsNothing);

    await _tap(tester, find.text('Heatmap'));
    expect(find.text('Demo heatmap – placeholder'), findsOneWidget);
  });

  testWidgets('Full face flow validates questionnaire', (tester) async {
    await _loginAsDemo(tester);
    await _tap(tester, find.text('Start Skin Analysis'));
    await _tap(tester, find.text('Full Face'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.text('Full face details'), findsOneWidget);

    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.text('Choose your primary goal.'), findsOneWidget);

    await _tap(tester, find.text('Hydration'));
    await _tap(tester, find.text('Yes').first);
    await _tap(tester, find.text('No').last);
    await _tap(tester, find.byTooltip('4 stars'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.text('Full face'), findsOneWidget); // camera title
  });
}
