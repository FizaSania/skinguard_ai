import 'package:flutter_test/flutter_test.dart';

import 'package:skinguard_ai/core/constants/app_assets.dart';
import 'package:skinguard_ai/core/widgets/form_fields.dart';
import 'package:skinguard_ai/data/mock/mock_scan_data.dart';
import 'package:skinguard_ai/models/skin_concern.dart';
import 'package:skinguard_ai/models/skin_scan.dart';
import 'package:skinguard_ai/models/skincare_plan.dart';
import 'package:skinguard_ai/models/user_profile.dart';
import 'package:skinguard_ai/providers/plan_provider.dart';
import 'package:skinguard_ai/providers/scan_provider.dart';
import 'package:skinguard_ai/providers/user_provider.dart';
import 'package:skinguard_ai/services/analysis_service.dart';
import 'package:skinguard_ai/services/auth_service.dart';
import 'package:skinguard_ai/services/plan_service.dart';
import 'package:skinguard_ai/services/profile_service.dart';
import 'package:skinguard_ai/services/recommendation_service.dart';
import 'package:skinguard_ai/services/scan_service.dart';

UserProfile _profile({List<String>? allergies, SkinType? skin}) => UserProfile(
      id: 'u',
      fullName: 'Test User',
      email: 't@example.com',
      skinType: skin ?? SkinType.oily,
      allergies: allergies,
    );

ScanProvider _scans({bool fail = false}) => ScanProvider(
      MockScanService(),
      MockSkinAnalysisService(stageDelay: Duration.zero)
        ..simulateFailure = fail,
    );

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b.co'), isNull);
    });
    test('password needs 8 chars with letter and number', () {
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('abcdefgh'), isNotNull);
      expect(Validators.password('abcdefg1'), isNull);
    });
    test('phone', () {
      expect(Validators.phone('12'), isNotNull);
      expect(Validators.phone('+92 300 1234567'), isNull);
    });
  });

  group('ScanSession', () {
    test('full face has one null capture target', () {
      final s = ScanSession(id: '1', createdAt: DateTime(2026))
        ..type = ScanType.fullFace;
      expect(s.captureTargets, [null]);
      expect(s.allImagesCaptured, isFalse);
    });

    test('patch targets follow face-map order', () {
      final s = ScanSession(
          id: '1',
          createdAt: DateTime(2026),
          type: ScanType.patch,
          regions: {FaceRegion.chin, FaceRegion.forehead});
      expect(s.captureTargets, [FaceRegion.forehead, FaceRegion.chin]);
    });

    test('questionnaire completeness', () {
      final a = FullFaceAnswers();
      expect(a.isComplete, isFalse);
      a.goals.add(SkincareGoal.hydration);
      a.generalSensitivity = false;
      a.dailySunscreen = true;
      a.routineSatisfaction = 3;
      expect(a.isComplete, isTrue);

      final p = PatchAnswers();
      expect(p.isPage1Complete, isFalse);
      p.symptoms.add(PatchSymptom.redness);
      p.duration = PatchDuration.underOneWeek;
      expect(p.isPage1Complete, isTrue);
    });
  });

  group('ScanProvider', () {
    test('multi-region capture keeps images per region', () {
      final scans = _scans()..startNewScan();
      scans.setType(ScanType.patch);
      scans.toggleRegion(FaceRegion.forehead);
      scans.toggleRegion(FaceRegion.nose);
      expect(scans.nextMissingIndex, 0);

      scans.setImage(FaceRegion.forehead, AppAssets.sampleSkin, isSample: true);
      expect(scans.nextMissingIndex, 1);
      scans.setImage(FaceRegion.nose, 'nose.jpg');
      expect(scans.nextMissingIndex, isNull);
      expect(scans.current.allImagesCaptured, isTrue);
      expect(scans.current.imageFor(FaceRegion.nose)!.path, 'nose.jpg');

      // Deselecting a region drops its photo.
      scans.toggleRegion(FaceRegion.nose);
      expect(scans.current.images.length, 1);
    });

    test('switching mode discards incompatible images', () {
      final scans = _scans()..startNewScan();
      scans.setType(ScanType.fullFace);
      scans.setImage(null, 'face.jpg');
      scans.toggleRegion(FaceRegion.chin);
      scans.setType(ScanType.patch);
      expect(scans.current.images, isEmpty);
      expect(scans.current.regions, {FaceRegion.chin});
    });

    test('analysis returns findings only for captured regions', () async {
      final scans = _scans()..startNewScan();
      scans.setType(ScanType.patch);
      scans.toggleRegion(FaceRegion.forehead);
      scans.toggleRegion(FaceRegion.lips);
      scans.setImage(FaceRegion.forehead, 'f.jpg');
      scans.setImage(FaceRegion.lips, 'l.jpg');

      final events = await scans.analyzeCurrent().toList();
      final result = events.last.result!;
      expect(result.isDemo, isTrue);
      expect(result.findings.map((f) => f.region),
          [FaceRegion.forehead, FaceRegion.lips]);
      expect(scans.history.first.id, scans.current.id);
      expect(scans.current.status, ScanStatus.completed);
    });

    test('analysis failure surfaces an error', () async {
      final scans = _scans(fail: true)..startNewScan();
      scans.setType(ScanType.fullFace);
      scans.setImage(null, 'face.jpg');
      await expectLater(
          scans.analyzeCurrent(), emitsThrough(emitsError(isA<AnalysisException>())));
      expect(scans.current.status, ScanStatus.failed);
    });
  });

  group('UserProvider allergies', () {
    late UserProvider users;
    setUp(() async {
      users = UserProvider(MockAuthService(), MockProfileService());
      await users.register(
          fullName: 'A B', email: 'ab@example.com', phone: '1234567', password: 'abcdefg1');
    });

    test('custom allergy is stored verbatim and de-duplicated', () {
      expect(users.addCustomAllergy('  Lanolin '), isTrue);
      expect(users.profile.allergies, ['Lanolin']);
      expect(users.addCustomAllergy('lanolin'), isFalse);
      expect(users.addCustomAllergy('   '), isFalse);
      expect(users.profile.isCustomAllergy('Lanolin'), isTrue);
    });

    test('typing a predefined allergy reuses its spelling', () {
      users.addCustomAllergy('fragrance');
      expect(users.profile.allergies, ['Fragrance']);
      users.toggleAllergy('Fragrance');
      expect(users.profile.allergies, isEmpty);
    });
  });

  group('Recommendations', () {
    final service = MockRecommendationService();
    final acne = AnalysisResult(
      scanId: 's',
      findings: const [MockScanData.fullFaceFinding],
      generatedAt: DateTime(2026),
      isDemo: true,
    );

    test('products with allergy ingredients are excluded', () {
      final bundle = service.build(
          profile: _profile(allergies: ['Fragrance', 'Salicylic Acid']),
          result: acne);
      final names = bundle.recommendations.map((r) => r.product.name);
      expect(names, isNot(contains('BHA Clarifying Toner')));
      expect(names, contains('Gentle Gel Cleanser'));
      expect(bundle.ingredientsToAvoid, ['Fragrance', 'Salicylic Acid']);
      expect(bundle.excludedProducts.map((p) => p.name),
          contains('BHA Clarifying Toner'));
    });

    test('environmental allergies do not filter products', () {
      final bundle = service.build(
          profile: _profile(allergies: ['Pollen allergy']), result: acne);
      expect(bundle.excludedProducts, isEmpty);
      expect(bundle.ingredientsToAvoid, isEmpty);
    });

    test('custom allergy is matched verbatim', () {
      final bundle = service.build(
          profile: _profile(allergies: ['Glycerin']), result: acne);
      for (final r in bundle.recommendations) {
        expect(r.product.allIngredients, isNot(contains('Glycerin')));
      }
    });

    test('primary concern drives the bundle', () {
      final bundle = service.build(profile: _profile(), result: acne);
      expect(bundle.primaryConcern, 'Acne');
      expect(bundle.ingredientsToLookFor, contains('Niacinamide'));
    });
  });

  group('PlanProvider', () {
    test('completion counter updates', () async {
      final plan = PlanProvider(MockPlanService());
      await plan.load();
      expect(plan.totalCount, 5);
      expect(plan.completedCount, 0);
      plan.toggleTask('m1');
      plan.toggleTask('e2');
      expect(plan.completedCount, 2);
      plan.toggleTask('m1');
      expect(plan.completedCount, 1);
    });

    test('custom tasks can be added and removed', () async {
      final plan = PlanProvider(MockPlanService());
      await plan.load();
      expect(plan.addTask('  ', RoutinePeriod.evening), isFalse);
      expect(plan.addTask('Eye cream', RoutinePeriod.evening), isTrue);
      final task = plan.tasksFor(RoutinePeriod.evening).last;
      expect(task.isCustom, isTrue);
      plan.removeTask(task.id);
      expect(plan.totalCount, 5);
    });
  });
}
