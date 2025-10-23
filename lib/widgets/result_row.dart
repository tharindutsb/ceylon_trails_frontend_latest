import 'package:flutter/material.dart';

/// Small label–value line used in Review/Predict panels.
class ResultRow extends StatelessWidget {
  const ResultRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: text.bodyMedium)),
        Text(value,
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
