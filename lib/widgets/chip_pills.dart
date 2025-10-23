import 'package:flutter/material.dart';

/// Animated ChoiceChips row used for filters/categories.
class ChipPills extends StatelessWidget {
  const ChipPills({
    super.key,
    required this.labels,
    required this.current,
    required this.onSelect,
    this.icons,
    this.spacing = 8,
  });

  final List<String> labels;
  final int current;
  final ValueChanged<int> onSelect;
  final List<IconData>? icons;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: spacing,
      children: List.generate(labels.length, (i) {
        final selected = i == current;
        return ChoiceChip(
          avatar: icons == null
              ? null
              : Icon(
                  icons![i],
                  size: 16,
                  color: selected ? cs.primary : Colors.white70,
                ),
          showCheckmark: false,
          label: Text(labels[i]),
          selected: selected,
          onSelected: (_) => onSelect(i),
        );
      }),
    );
  }
}
