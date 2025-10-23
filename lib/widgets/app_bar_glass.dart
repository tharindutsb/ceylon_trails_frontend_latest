import 'dart:ui';
import 'package:flutter/material.dart';

/// A frosted AppBar wrapper that feels “glass”. Use like:
/// AppBarGlass(title: Text('Title'), actions: [...])
class AppBarGlass extends StatelessWidget implements PreferredSizeWidget {
  const AppBarGlass({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AppBar(
          backgroundColor: cs.surface.withOpacity(.50),
          elevation: 0,
          centerTitle: centerTitle,
          leading: leading,
          title: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w700),
            child: title,
          ),
          actions: actions,
        ),
      ),
    );
  }
}
