// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'state/plan_provider.dart';
import 'state/trip_provider.dart';

/// The root application widget.
/// Keeps theme, routing, and providers in one place so `main.dart` stays tiny.
class CeylonTrailsApp extends StatelessWidget {
  const CeylonTrailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // App-wide state
        ChangeNotifierProvider(create: _createPlanProvider),
        ChangeNotifierProvider(create: _createTripProvider),
      ],
      child: MaterialApp(
        title: 'Ceylon Trails',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        onGenerateRoute: AppRouter.onGenerateRoute,
        // Start inside the bottom-nav shell for the demo
        initialRoute: AppRoutes.shell,
      ),
    );
  }

  // These tiny factories keep hot reload happy and avoid re-creating providers.
  static PlanProvider _createPlanProvider(BuildContext _) => PlanProvider();
  static TripProvider _createTripProvider(BuildContext _) => TripProvider();
}
