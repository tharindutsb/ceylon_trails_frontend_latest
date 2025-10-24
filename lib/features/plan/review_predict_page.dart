import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/plan_provider.dart';
import '../../state/trip_provider.dart';
import '../../core/models/location.dart';
import '../../core/seed/locations_seed.dart';
import '../../core/router/app_router.dart';
import '../../widgets/animated_gradient_scaffold.dart';

class ReviewPredictPage extends StatefulWidget {
  const ReviewPredictPage({super.key});

  @override
  State<ReviewPredictPage> createState() => _ReviewPredictPageState();
}

class _ReviewPredictPageState extends State<ReviewPredictPage> {
  String _selectedProvince = 'All';
  final List<String> _provinces = [
    'All',
    'Western',
    'Central',
    'Southern',
    'Northern',
    'Eastern',
    'North Western',
    'North Central',
    'Uva',
    'Sabaragamuwa'
  ];

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();
    final group = plan.group;

    // Filter locations by selected province
    final filteredLocations = _selectedProvince == 'All'
        ? kSeedLocations
        : kSeedLocations.where((loc) => loc.city == _selectedProvince).toList();

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
        child: Column(
          children: [
            // Province Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Filter by Province',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _provinces.map((province) {
                        final isSelected = _selectedProvince == province;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedProvince = province),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                province,
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Locations List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final loc = filteredLocations[index];
                  final analysis =
                      _predict(groupSize: group.people.length, loc: loc);

                  return _buildLocationCard(context, loc, analysis, group);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, LocationItem loc,
      _Prediction analysis, dynamic group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLocationDetails(context, loc, analysis),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Location Image
                    if (loc.imageUrl != null)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(loc.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    const SizedBox(width: 12),

                    // Location Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${loc.city ?? 'Unknown'} • ${locTypeLabel(loc.type)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _buildSmallTag('${loc.prefStart}–${loc.prefEnd}',
                                  const Color(0xFF6EE7F2)),
                              _buildSmallTag(terrainLabel(loc.terrain),
                                  const Color(0xFFFF9800)),
                              _buildSmallTag(accessLabel(loc.access),
                                  const Color(0xFF2196F3)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Suitability Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: analysis.suitable
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(analysis.p * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: analysis.suitable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Prediction Summary
                Row(
                  children: [
                    Icon(Icons.timelapse, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${analysis.duration} min',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.wb_sunny, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        analysis.window,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final trips = context.read<TripProvider>();
                          try {
                            trips.addStopFromLocation(
                              loc,
                              plannedDurationMin: analysis.duration,
                            );
                          } catch (_) {
                            // Handle error silently
                          }
                          Navigator.pushNamed(context, AppRoutes.build);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            const Text('Add', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showLocationDetails(
      BuildContext context, LocationItem loc, _Prediction analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: Text(
          loc.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loc.desc != null) ...[
              Text(
                loc.desc!,
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
            ],
            _buildDetailRow(
                'Suitability',
                '${(analysis.p * 100).toStringAsFixed(0)}% ${analysis.suitable ? 'OK' : 'Not ideal'}',
                analysis.suitable ? Colors.green : Colors.red),
            _buildDetailRow(
                'Duration', '${analysis.duration} min', Colors.blue),
            _buildDetailRow('Best Time', analysis.window, Colors.orange),
            _buildDetailRow(
                'Type', locTypeLabel(loc.type), const Color(0xFF4CAF50)),
            _buildDetailRow(
                'Terrain', terrainLabel(loc.terrain), const Color(0xFFFF9800)),
            _buildDetailRow(
                'Access', accessLabel(loc.access), const Color(0xFF2196F3)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final trips = context.read<TripProvider>();
              try {
                trips.addStopFromLocation(
                  loc,
                  plannedDurationMin: analysis.duration,
                );
              } catch (_) {
                // Handle error silently
              }
              Navigator.pushNamed(context, AppRoutes.build);
            },
            child: const Text('Add to Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
