import 'package:flutter/material.dart';
import '../core/models/person.dart';

/// Mobility chips used in Add/Edit person bottom-sheet.
/// Usage:
/// MobilityPicker(value: mobility, onChanged: (m) => setState(() => mobility = m))
class MobilityPicker extends StatelessWidget {
  const MobilityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Mobility value;
  final ValueChanged<Mobility> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(Mobility m, String label, IconData icon) {
      final selected = value == m;
      return ChoiceChip(
        selected: selected,
        showCheckmark: false,
        avatar:
            Icon(icon, size: 16, color: selected ? cs.primary : Colors.white70),
        label: Text(label),
        onSelected: (_) => onChanged(m),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(Mobility.fullyMobile, 'Fully mobile',
            Icons.directions_walk_rounded),
        chip(Mobility.assisted, 'Assisted', Icons.accessibility_new_rounded),
        chip(
            Mobility.wheelchair, 'Wheelchair', Icons.wheelchair_pickup_rounded),
        chip(Mobility.limitedEndurance, 'Limited endurance',
            Icons.favorite_outline_rounded),
        chip(Mobility.childCarried, 'Child carried', Icons.child_care_rounded),
      ],
    );
  }
}
