import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/plan_provider.dart';
import '../../state/trip_provider.dart';
import '../../core/models/location.dart';
import '../../core/seed/locations_seed.dart';
import '../../core/router/app_router.dart';
import '../../widgets/animated_gradient_scaffold.dart';

class ReviewPredictPage extends StatelessWidget {
  const ReviewPredictPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();
    // prefer route arg, else provider.selected, else seed[0]
    final arg = ModalRoute.of(context)?.settings.arguments;
    final loc =
        (arg is LocationItem) ? arg : (plan.selected ?? kSeedLocations.first);

    final group = plan.group;

    // --- Demo “prediction” rules (fast & explainable) ---
    final analysis = _predict(groupSize: group.people.length, loc: loc);

    // cache for use in schedule (optional)
    plan.setPrediction(
      suitable: analysis.suitable,
      probability: analysis.p,
      window: analysis.window,
      recDurationMin: analysis.duration.toDouble(),
    );

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Review & Predict'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1D29),
              const Color(0xFF2D1B69),
              const Color(0xFF11998E),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            // Enhanced Hero Image
            if (loc.imageUrl != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Image.network(loc.imageUrl!, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Location Name with better contrast
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _enhancedTag(
                          locTypeLabel(loc.type), const Color(0xFF4CAF50)),
                      _enhancedTag('terrain: ${terrainLabel(loc.terrain)}',
                          const Color(0xFFFF9800)),
                      _enhancedTag('access: ${accessLabel(loc.access)}',
                          const Color(0xFF2196F3)),
                      _enhancedTag('heat: ${heatLabel(loc.heat)}',
                          const Color(0xFFFF5722)),
                      _enhancedTag('pref: ${loc.prefStart}–${loc.prefEnd}',
                          const Color(0xFF6EE7F2)),
                    ],
                  ),
                  if ((loc.desc ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      loc.desc!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Enhanced Prediction Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Predictions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPredictionRow(
                    analysis.suitable
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    'Suitability (group)',
                    '${(analysis.p * 100).toStringAsFixed(0)}% ${analysis.suitable ? 'OK' : 'Not ideal'}',
                    analysis.suitable
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5722),
                  ),
                  const SizedBox(height: 16),
                  _buildPredictionRow(
                    Icons.timelapse_outlined,
                    'Recommended duration',
                    '${analysis.duration} min',
                    const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 16),
                  _buildPredictionRow(
                    Icons.wb_sunny_outlined,
                    'Best window',
                    analysis.window,
                    const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Enhanced Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.choose),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Choose another'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: () {
                        // Add to TripProvider working list
                        final trips = context.read<TripProvider>();
                        try {
                          trips.addStopFromLocation(
                            loc,
                            plannedDurationMin: analysis.duration,
                          );
                        } catch (_) {
                          // If your TripProvider doesn't expose addStopFromLocation,
                          // you can ignore this and let the Schedule page handle adding.
                        }
                        Navigator.pushNamed(context, AppRoutes.build);
                      },
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Add to schedule'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _enhancedTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPredictionRow(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny, explainable heuristic for demo predictions.
/// In production you’ll call your ML API instead.
class _Prediction {
  final bool suitable;
  final double p;
  final int duration;
  final String window;
  const _Prediction(this.suitable, this.p, this.duration, this.window);
}

_Prediction _predict({
  required int groupSize,
  required LocationItem loc,
}) {
  // base probability by access/terrain/heat
  double p = 0.85;
  if (loc.access == Access.limited) p -= .25;
  if (loc.terrain == Terrain.hilly) p -= .08;
  if (loc.heat == Heat.high) p -= .07;

  // mild penalty for large groups
  if (groupSize >= 5) p -= .05;
  if (groupSize >= 8) p -= .05;

  p = p.clamp(0.1, 0.97);
  final suitable = p >= 0.5;

  // duration: start from suggested, adjust by terrain & access
  int dur = loc.suggestedDurationMin;
  if (loc.terrain == Terrain.hilly) dur += 15;
  if (loc.access == Access.limited) dur += 10;
  if (!suitable) dur = (dur * .85).round();

  // best window (simple by heat)
  final window = switch (loc.heat) {
    Heat.high => 'Morning / Late afternoon',
    Heat.medium => 'Morning',
    Heat.low => 'Anytime',
  };

  return _Prediction(suitable, p, dur, window);
}
