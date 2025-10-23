import 'package:flutter/material.dart';

/// Subtle animated radial gradients behind your page.
/// Use it like a Scaffold wrapper.
class AnimatedGradientScaffold extends StatelessWidget {
  const AnimatedGradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNav,
    this.fab,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNav;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-.8 + .6 * v, -.9),
                radius: 1.1,
                colors: [cs.secondary.withOpacity(.18), Colors.transparent],
              ),
            ),
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(.95 - .5 * v, .9),
                radius: 1.2,
                colors: [cs.primary.withOpacity(.14), Colors.transparent],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNav,
          floatingActionButton: fab,
        ),
      ],
    );
  }
}
