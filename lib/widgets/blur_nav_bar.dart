import 'dart:ui';
import 'package:flutter/material.dart';

/// Minimal frosted bottom bar shell. Put any row of actions inside [child].
class BlurNavBar extends StatelessWidget {
  const BlurNavBar({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding ?? const EdgeInsets.fromLTRB(14, 8, 14, 14),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(.55),
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(.07))),
          ),
          child: child,
        ),
      ),
    );
  }
}
