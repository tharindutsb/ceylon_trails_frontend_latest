import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/location.dart';
import '../core/services/location_prediction_service.dart';
import '../state/plan_provider.dart';
import '../state/trip_provider.dart';
import '../core/router/app_router.dart';

class LocationDetailsPopup extends StatelessWidget {
  final LocationItem location;

  const LocationDetailsPopup({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D29),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      location.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    if (location.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            location.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Rating and votes
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${location.rating?.toStringAsFixed(1) ?? '4.5'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${location.voteCount ?? 0} votes)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    if (location.desc != null) ...[
                      Text(
                        'Overview',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        location.desc!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Location details
                    _buildDetailsSection(context, cs),
                    const SizedBox(height: 20),

                    // Predicted details
                    _buildPredictedDetails(context, cs),
                    const SizedBox(height: 20),

                    // Action buttons
                    _buildActionButtons(context, cs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details',
          style: TextStyle(
            color: cs.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                  'Type', locTypeLabel(location.type), const Color(0xFF4CAF50)),
              _buildDetailRow('Terrain', terrainLabel(location.terrain),
                  const Color(0xFFFF9800)),
              _buildDetailRow('Access', accessLabel(location.access),
                  const Color(0xFF2196F3)),
              _buildDetailRow('Heat Level', heatLabel(location.heat),
                  const Color(0xFFFF5722)),
              _buildDetailRow(
                  'Best Time',
                  '${location.prefStart}–${location.prefEnd}',
                  const Color(0xFF6EE7F2)),
              if (location.city != null)
                _buildDetailRow(
                    'City', location.city!, const Color(0xFF9C27B0)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPredictedDetails(BuildContext context, ColorScheme cs) {
    final plan = context.watch<PlanProvider>();
    final group = plan.group;

    // Check if group and mobility status are available
    if (group.people.isEmpty) {
      return _buildMissingGroupWarning(context, cs);
    }

    // For now, use a default mobility status if not available
    // In a real app, this would come from user profile or settings
    const mobilityStatus = 'fit'; // Default to fit

    try {
      final prediction = LocationPredictionService.predictLocation(
        location: location,
        group: group,
        mobilityStatus: mobilityStatus,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predicted Details',
            style: TextStyle(
              color: cs.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: prediction.isSuitable
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: prediction.isSuitable
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                _buildPredictionRow(
                  Icons.timelapse,
                  'Duration',
                  '${prediction.duration} minutes',
                  prediction.isSuitable ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildPredictionRow(
                  Icons.wb_sunny,
                  'Best Time Window',
                  prediction.timeWindow,
                  prediction.isSuitable ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildPredictionRow(
                  Icons.analytics,
                  'Suitability',
                  '${(prediction.suitability * 100).toStringAsFixed(0)}% ${prediction.isSuitable ? 'Recommended' : 'Not Ideal'}',
                  prediction.isSuitable ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildPredictionRow(
                  Icons.trending_up,
                  'Difficulty',
                  prediction.difficulty,
                  prediction.isSuitable ? Colors.green : Colors.orange,
                ),
                if (prediction.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildRecommendationsSection(prediction.recommendations),
                ],
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      return _buildPredictionError(context, cs, e.toString());
    }
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(0.8)],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                final trips = context.read<TripProvider>();
                final plan = context.read<PlanProvider>();
                final group = plan.group;

                if (group.people.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please add group members before adding locations'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  const mobilityStatus = 'fit'; // Default mobility status
                  final prediction = LocationPredictionService.predictLocation(
                    location: location,
                    group: group,
                    mobilityStatus: mobilityStatus,
                  );

                  trips.addStopFromLocation(
                    location,
                    plannedDurationMin: prediction.duration,
                  );
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.build);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding location: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add to Schedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingGroupWarning(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 32),
          const SizedBox(height: 8),
          Text(
            'Group Information Required',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please add group members and mobility status to get personalized predictions for this location.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionError(
      BuildContext context, ColorScheme cs, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Prediction Error',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations:',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
