import 'package:flutter/material.dart';
import '../../core/models/location.dart';
import '../../widgets/animated_gradient_scaffold.dart';
import '../../widgets/glass_card.dart';

class LocationDetailsPage extends StatelessWidget {
  const LocationDetailsPage({super.key, required this.location});
  final LocationItem location;

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientScaffold(
      appBar: AppBar(title: const Text('Location details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        children: [
          if (location.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(location.imageUrl!, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 12),
          Text(location.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tag(ctx: context, t: locTypeLabel(location.type)),
              _tag(
                  ctx: context,
                  t: 'terrain: ${terrainLabel(location.terrain)}'),
              _tag(ctx: context, t: 'access: ${accessLabel(location.access)}'),
              _tag(ctx: context, t: 'heat: ${heatLabel(location.heat)}'),
              _tag(
                  ctx: context,
                  t: 'pref: ${location.prefStart}–${location.prefEnd}'),
            ],
          ),
          const SizedBox(height: 14),
          if ((location.desc ?? '').isNotEmpty) Text(location.desc!),
          const SizedBox(height: 20),
          GlassCard(
            child: ListTile(
              title: const Text('Rating'),
              subtitle:
                  Text('${location.rating?.toStringAsFixed(1) ?? '4.5'} / 5'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag({required BuildContext ctx, required String t}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.04),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Text(t, style: Theme.of(ctx).textTheme.labelMedium),
      );
}
