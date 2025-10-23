import 'package:flutter/material.dart';
import '../core/models/location.dart';

/// Versatile card for a LocationItem, with thumbnail + meta + CTA.
class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.loc,
    this.onTap,
    this.onSelect,
  });

  final LocationItem loc;
  final VoidCallback? onTap;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Thumb(imageUrl: loc.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      '${locTypeLabel(loc.type)} • ${terrainLabel(loc.terrain)} • access: ${accessLabel(loc.access)} • heat: ${heatLabel(loc.heat)}',
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StarRow(rating: loc.rating ?? 4.5),
                        const SizedBox(width: 8),
                        Text('Pref ${loc.prefStart}–${loc.prefEnd}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (onSelect != null)
                FilledButton(
                  onPressed: onSelect,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Select'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: Colors.white10,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? const Icon(Icons.photo, color: Colors.white30)
            : Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor().clamp(0, 5);
    final half = (rating - full) >= 0.5;
    final empty = 5 - full - (half ? 1 : 0);

    List<Widget> stars = [];
    for (var i = 0; i < full; i++) {
      stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
    }
    if (half)
      stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
    for (var i = 0; i < empty; i++) {
      stars.add(const Icon(Icons.star_border, size: 16, color: Colors.amber));
    }

    return Row(children: [
      ...stars,
      const SizedBox(width: 4),
      Text(rating.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white70)),
    ]);
  }
}
