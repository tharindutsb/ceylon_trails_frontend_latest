import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'state/plan_provider.dart';
import 'state/trip_provider.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CeylonTrailsApp());
}

class CeylonTrailsApp extends StatelessWidget {
  const CeylonTrailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: MaterialApp(
        title: 'Ceylon Trails',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark, // your dark neon theme
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.shell, // <- start in the bottom-nav shell
      ),
    );
  }
}
