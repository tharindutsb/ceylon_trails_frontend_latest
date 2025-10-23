import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../widgets/animated_gradient_scaffold.dart';
import '../../widgets/glass_card.dart';

/// ---------------------------------------------------------------------------
/// Splash → quickly forwards to Sign-in (or straight to app if you prefer).
/// ---------------------------------------------------------------------------
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Auto-forward to sign-in after a very short delay.
    // (If you add persisted auth, decide here where to go.)
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedGradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route_rounded, size: 64, color: cs.primary),
            const SizedBox(height: 12),
            const Text('Ceylon Trails',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('loading…', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Sign-in screen (Google button + Guest).
/// Google button is wired for DEMO (mock); you can swap to real google_sign_in.
/// ---------------------------------------------------------------------------
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Plan beautiful day trips across Sri Lanka',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover places, check suitability for your group,\n'
                  'and build a smart schedule in minutes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _FeatureRow(
                  icon: Icons.explore_rounded,
                  text: 'Curated locations and categories',
                ),
                const SizedBox(height: 8),
                _FeatureRow(
                  icon: Icons.check_circle_outline,
                  text: 'Simple, explainable predictions',
                ),
                const SizedBox(height: 8),
                _FeatureRow(
                  icon: Icons.event_note_rounded,
                  text: 'Drag-and-drop schedule builder',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Google sign-in (mock in demo)
          _GoogleButton(
            onTap: () async {
              // TODO: integrate real google_sign_in here.
              // For demo, pretend success and go to app shell.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed in with Google (demo)')),
              );
              Navigator.pushReplacementNamed(context, AppRoutes.shell);
            },
          ),

          const SizedBox(height: 12),

          // Continue as guest
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.shell);
            },
            icon: const Icon(Icons.lock_open_rounded),
            label: const Text('Continue as guest'),
          ),

          const SizedBox(height: 26),

          // Tiny legal
          Text(
            'By continuing you agree to the Terms & Privacy Policy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(.6), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cs.primary.withOpacity(.15),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        icon: Image.asset(
          'assets/icons/google.png',
          width: 18,
          height: 18,
          // If you don't have an asset yet, fallback to an icon
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.g_mobiledata_rounded, size: 22),
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
