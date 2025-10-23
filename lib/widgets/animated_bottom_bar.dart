import 'package:flutter/material.dart';

/// Bouncy, glowing bottom navigation bar.
/// Provide current [index] and [onChanged].
class AnimatedBottomBar extends StatelessWidget {
  const AnimatedBottomBar({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.explore_rounded, 'Explore'),
      (Icons.schedule_rounded, 'Ongoing'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.60),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == index;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    active ? cs.primary.withOpacity(.16) : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Icon(items[i].$1,
                      color: active ? cs.primary : Colors.white70),
                  if (active) ...[
                    const SizedBox(width: 8),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
