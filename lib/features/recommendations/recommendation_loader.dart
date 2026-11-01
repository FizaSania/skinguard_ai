import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/layout.dart';
import '../../models/recommendation.dart';
import '../../providers/scan_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/app_services.dart';

/// Loads a [RecommendationBundle] for the current user + latest result and
/// reloads it when allergies, skin type or the latest scan change.
class RecommendationLoader extends StatefulWidget {
  const RecommendationLoader({super.key, required this.builder});

  final Widget Function(BuildContext context, RecommendationBundle bundle)
      builder;

  @override
  State<RecommendationLoader> createState() => _RecommendationLoaderState();
}

class _RecommendationLoaderState extends State<RecommendationLoader> {
  Future<RecommendationBundle>? _future;
  String? _signature;

  void _reloadIfNeeded() {
    final profile = context.watch<UserProvider>().profile;
    final scans = context.watch<ScanProvider>();
    final result = scans.latestResult;
    final signature = [
      profile.skinType?.name,
      ...profile.allergies,
      result?.scanId,
    ].join('|');
    if (signature == _signature && _future != null) return;
    _signature = signature;
    // FUTURE RECOMMENDATION INTEGRATION: the service call becomes an API
    // request; this widget already handles loading and error states.
    _future = context
        .read<AppServices>()
        .recommendations
        .getRecommendations(profile: profile, result: result);
  }

  @override
  Widget build(BuildContext context) {
    _reloadIfNeeded();
    return FutureBuilder<RecommendationBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return PageLayout(children: [
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load recommendations',
              message: '${snapshot.error}',
              actionLabel: 'Retry',
              onAction: () => setState(() => _signature = null),
            ),
          ]);
        }
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return widget.builder(context, snapshot.data!);
      },
    );
  }
}
