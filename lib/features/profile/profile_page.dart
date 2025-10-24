import 'package:flutter/material.dart';

import '../../widgets/animated_gradient_scaffold.dart';
import '../../core/router/app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1D29),
              const Color(0xFF2D1B69),
              const Color(0xFF11998E),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            // User Profile Card
            _buildUserProfileCard(context, cs),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(context, cs),
            const SizedBox(height: 24),

            // Account Settings Section
            _buildSectionHeader(
                context, 'Account Settings', Icons.account_circle),
            const SizedBox(height: 12),
            _buildSettingsCard(context, cs, [
              _buildSettingsItem(
                context,
                Icons.person_outline,
                'Personal Information',
                'Update your profile details',
                () => _showPersonalInfo(context),
              ),
              _buildSettingsItem(
                context,
                Icons.notifications_outlined,
                'Notifications',
                'Manage your notification preferences',
                () => _showNotifications(context),
              ),
              _buildSettingsItem(
                context,
                Icons.language_outlined,
                'Language & Region',
                'Change language and region settings',
                () => _showLanguageSettings(context),
              ),
            ]),
            const SizedBox(height: 24),

            // Privacy & Security Section
            _buildSectionHeader(context, 'Privacy & Security', Icons.security),
            const SizedBox(height: 12),
            _buildSettingsCard(context, cs, [
              _buildSettingsItem(
                context,
                Icons.lock_outline,
                'Privacy Settings',
                'Control your data and privacy',
                () => _showPrivacySettings(context),
              ),
              _buildSettingsItem(
                context,
                Icons.location_off_outlined,
                'Location Services',
                'Manage location tracking',
                () => _showLocationSettings(context),
              ),
              _buildSettingsItem(
                context,
                Icons.data_usage_outlined,
                'Data Usage',
                'View and manage your data',
                () => _showDataUsage(context),
              ),
            ]),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(context, 'Support', Icons.help_outline),
            const SizedBox(height: 12),
            _buildSettingsCard(context, cs, [
              _buildSettingsItem(
                context,
                Icons.help_center_outlined,
                'Help Center',
                'Get help and find answers',
                () => _showHelpCenter(context),
              ),
              _buildSettingsItem(
                context,
                Icons.support_agent,
                'Contact Support',
                'Get in touch with our team',
                () => _showContactSupport(context),
              ),
              _buildSettingsItem(
                context,
                Icons.bug_report_outlined,
                'Report a Bug',
                'Help us improve the app',
                () => _showBugReport(context),
              ),
            ]),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'About', Icons.info_outline),
            const SizedBox(height: 12),
            _buildSettingsCard(context, cs, [
              _buildSettingsItem(
                context,
                Icons.info_outline,
                'About Ceylon Trails',
                'Learn more about our app',
                () => _showAbout(context),
              ),
              _buildSettingsItem(
                context,
                Icons.description_outlined,
                'Terms of Service',
                'Read our terms and conditions',
                () => _showTerms(context),
              ),
              _buildSettingsItem(
                context,
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'Read our privacy policy',
                () => _showPrivacyPolicy(context),
              ),
            ]),
            const SizedBox(height: 24),

            // Sign Out Button
            _buildSignOutButton(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  cs.primary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            'Guest User',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // User Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              'Not signed in',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign In Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  cs.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showSignIn(context),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(context, 'Trips', '0', Icons.route),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(context, 'Locations', '0', Icons.location_on),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child:
                _buildStatItem(context, 'Distance', '0 km', Icons.straighten),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, ColorScheme cs, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, ColorScheme cs) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: OutlinedButton.icon(
        onPressed: () => _showSignOutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Dialog and navigation methods
  void _showSettings(BuildContext context) {
    // Show settings dialog
  }

  void _showPersonalInfo(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.personalInfo);
  }

  void _showNotifications(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.notifications);
  }

  void _showLanguageSettings(BuildContext context) {
    // Show language selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language & Region'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('සිංහල'),
              leading: const Text('🇱🇰'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('தமிழ்'),
              leading: const Text('🇱🇰'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.privacySettings);
  }

  void _showLocationSettings(BuildContext context) {
    // Show location settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services'),
        content: const Text(
            'Manage your location tracking preferences in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataUsage(BuildContext context) {
    // Show data usage dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Usage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Data: 25.3 MB'),
            Text('Cache: 12.1 MB'),
            Text('User Data: 8.7 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Clear Cache'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.helpCenter);
  }

  void _showContactSupport(BuildContext context) {
    // Show contact support dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Support'),
              subtitle: Text('support@ceylontrails.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone Support'),
              subtitle: Text('+94 11 234 5678'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBugReport(BuildContext context) {
    // Show bug report dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Describe the issue you encountered...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug report submitted!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.about);
  }

  void _showTerms(BuildContext context) {
    // Show terms dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service content would go here. This is a placeholder for the actual terms and conditions.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Show privacy policy dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy content would go here. This is a placeholder for the actual privacy policy.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignIn(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.signIn);
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle sign out
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
