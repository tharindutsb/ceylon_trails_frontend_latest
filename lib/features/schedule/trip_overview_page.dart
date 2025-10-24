import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/trip_provider.dart';
import '../../widgets/animated_gradient_scaffold.dart';
import '../../core/models/trip.dart';

class TripOverviewPage extends StatelessWidget {
  const TripOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripProvider>();
    final cs = Theme.of(context).colorScheme;

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Trip Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create new trip
              Navigator.pushNamed(context, '/trip-duration');
            },
          ),
        ],
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
            // Header
            Row(
              children: [
                Icon(Icons.timeline, color: cs.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Trip Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current/Upcoming Trips Section
            _buildCurrentTripsSection(context, cs),
            const SizedBox(height: 20),

            // Past Trips Section
            _buildPastTripsSection(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTripsSection(BuildContext context, ColorScheme cs) {
    final trips = context.watch<TripProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_fill, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Current & Upcoming',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current Trip (if any)
        if (trips.currentTrip != null) ...[
          _buildCurrentTripCard(context, cs, trips.currentTrip!),
          const SizedBox(height: 16),
        ],

        // Upcoming Trips (simulated)
        ..._getUpcomingTrips().map((trip) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildUpcomingTripCard(context, cs, trip),
            )),

        // No current trips message
        if (trips.currentTrip == null && _getUpcomingTrips().isEmpty)
          _buildNoCurrentTripsCard(context),
      ],
    );
  }

  Widget _buildCurrentTripCard(
      BuildContext context, ColorScheme cs, Trip trip) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_circle_fill,
                    color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Current Trip',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Start: ${trip.startHHMM} • ${trip.stops.length} stops',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to live tracking
                    Navigator.pushNamed(context, '/live-tracking');
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Track Live'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View details
                    _showTripDetails(context, trip);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastTripsSection(BuildContext context, ColorScheme cs) {
    // Simulate past trips data
    final pastTrips = _getSimulatedPastTrips();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Past Trips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (pastTrips.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(Icons.history,
                    size: 64, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  'No past trips yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your completed trips will appear here',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: pastTrips
                .map((trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPastTripCard(context, cs, trip),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildPastTripCard(
      BuildContext context, ColorScheme cs, PastTrip trip) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip.status,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule,
                  color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 8),
              Text(
                '${trip.duration} • ${trip.stops} stops',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showTripDetails(context, trip);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _duplicateTrip(context, trip);
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Duplicate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTripDetails(BuildContext context, dynamic trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trip.title ?? 'Trip Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Date: ${trip.date ?? 'N/A'}'),
            Text('Duration: ${trip.duration ?? 'N/A'}'),
            Text('Stops: ${trip.stops ?? 'N/A'}'),
            if (trip.status != null) Text('Status: ${trip.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _duplicateTrip(BuildContext context, PastTrip trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicating ${trip.title}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildUpcomingTripCard(
      BuildContext context, ColorScheme cs, UpcomingTrip trip) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.schedule, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip.status,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule,
                  color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 8),
              Text(
                '${trip.duration} • ${trip.stops} stops',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _editUpcomingTrip(context, trip);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _startUpcomingTrip(context, trip);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoCurrentTripsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.add_location_alt,
              size: 64, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No current trips',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start planning your next adventure',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/group');
            },
            icon: const Icon(Icons.add),
            label: const Text('Plan New Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editUpcomingTrip(BuildContext context, UpcomingTrip trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${trip.title}...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _startUpcomingTrip(BuildContext context, UpcomingTrip trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${trip.title}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<UpcomingTrip> _getUpcomingTrips() {
    return [
      UpcomingTrip(
        title: 'Ella Scenic Journey',
        date: 'Tomorrow, Dec 20',
        duration: '7h 15m',
        stops: '6',
        status: 'Scheduled',
      ),
      UpcomingTrip(
        title: 'Galle Fort Walk',
        date: 'Dec 22, 2024',
        duration: '5h 30m',
        stops: '4',
        status: 'Scheduled',
      ),
    ];
  }

  List<PastTrip> _getSimulatedPastTrips() {
    return [
      PastTrip(
        title: 'Kandy Heritage Tour',
        date: 'Dec 15, 2024',
        duration: '6h 30m',
        stops: '4',
        status: 'Completed',
      ),
      PastTrip(
        title: 'Colombo City Walk',
        date: 'Dec 10, 2024',
        duration: '4h 15m',
        stops: '3',
        status: 'Completed',
      ),
      PastTrip(
        title: 'Sigiriya Adventure',
        date: 'Dec 5, 2024',
        duration: '8h 45m',
        stops: '5',
        status: 'Completed',
      ),
    ];
  }
}

class UpcomingTrip {
  final String title;
  final String date;
  final String duration;
  final String stops;
  final String status;

  UpcomingTrip({
    required this.title,
    required this.date,
    required this.duration,
    required this.stops,
    required this.status,
  });
}

class PastTrip {
  final String title;
  final String date;
  final String duration;
  final String stops;
  final String status;

  PastTrip({
    required this.title,
    required this.date,
    required this.duration,
    required this.stops,
    required this.status,
  });
}
