import 'package:flutter/material.dart';

import '../../widgets/animated_bottom_bar.dart';
import '../../widgets/animated_gradient_scaffold.dart';
import '../plan/choose_location_page.dart';
import '../schedule/schedule_viewer_page.dart';
import '../profile/profile_page.dart';
import 'plan_home_page.dart';

/// Bottom-navigation shell with 4 tabs:
/// Home, Explore, Schedule, Profile
class RootShellPage extends StatefulWidget {
  const RootShellPage({super.key});

  @override
  State<RootShellPage> createState() => _RootShellPageState();
}

class _RootShellPageState extends State<RootShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const PlanHomePage(),
      const ChooseLocationPage(), // Explore
      const ScheduleViewerPage(), // Schedule (ongoing trips)
      const ProfilePage(), // Profile
    ];

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: pages[_index],
      bottomNav: AnimatedBottomBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }

  static const _titles = [
    'Ceylon Trails',
    'Explore',
    'Ongoing Schedule',
    'Profile',
  ];
}
