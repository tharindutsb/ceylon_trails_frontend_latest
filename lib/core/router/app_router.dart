import 'package:flutter/material.dart';

import '../../features/auth/sign_in_page.dart';
import '../../features/home/root_shell_page.dart';
import '../../features/plan/group_details_page.dart';
import '../../features/plan/trip_duration_page.dart';
import '../../features/plan/choose_location_page.dart';
import '../../features/plan/review_predict_page.dart';
import '../../features/schedule/build_schedule_page.dart';
import '../../features/schedule/schedule_viewer_page.dart';
import '../../features/schedule/trip_overview_page.dart';
import '../../features/tracking/live_tracking_page.dart';
import '../../features/profile/settings_pages.dart';

class AppRoutes {
  // Auth flow
  static const splash = '/splash';
  static const signIn = '/sign-in';

  // Bottom-nav shell (Home / Explore / Schedule / Profile)
  static const shell = '/';

  // Planning flow
  static const group = '/group';
  static const tripDuration = '/trip-duration';
  static const choose = '/choose';
  static const review = '/review';
  static const schedule = '/schedule';
  static const build = '/build';
  static const scheduleViewer = '/schedule-viewer';
  static const overview = '/overview';
  static const liveTracking = '/live-tracking';

  // Profile & Settings
  static const personalInfo = '/personal-info';
  static const notifications = '/notifications';
  static const languageSettings = '/language-settings';
  static const privacySettings = '/privacy-settings';
  static const locationSettings = '/location-settings';
  static const dataUsage = '/data-usage';
  static const helpCenter = '/help-center';
  static const contactSupport = '/contact-support';
  static const bugReport = '/bug-report';
  static const about = '/about';
  static const terms = '/terms';
  static const privacyPolicy = '/privacy-policy';
}

class AppRouter {
  static Route onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());

      case AppRoutes.shell:
        return MaterialPageRoute(builder: (_) => const RootShellPage());

      case AppRoutes.group:
        return MaterialPageRoute(builder: (_) => const GroupDetailsPage());

      case AppRoutes.tripDuration:
        return MaterialPageRoute(builder: (_) => const TripDurationPage());

      case AppRoutes.choose:
        return MaterialPageRoute(builder: (_) => const ChooseLocationPage());

      case AppRoutes.review:
        return MaterialPageRoute(builder: (_) => const ReviewPredictPage());

      case AppRoutes.build:
        return MaterialPageRoute(builder: (_) => const BuildSchedulePage());

      case AppRoutes.scheduleViewer:
        return MaterialPageRoute(builder: (_) => const ScheduleViewerPage());

      case AppRoutes.overview:
        return MaterialPageRoute(builder: (_) => const TripOverviewPage());

      case AppRoutes.liveTracking:
        return MaterialPageRoute(builder: (_) => const LiveTrackingPage());

      // Profile & Settings routes
      case AppRoutes.personalInfo:
        return MaterialPageRoute(builder: (_) => const PersonalInfoPage());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case AppRoutes.privacySettings:
        return MaterialPageRoute(builder: (_) => const PrivacySettingsPage());
      case AppRoutes.helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterPage());
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
