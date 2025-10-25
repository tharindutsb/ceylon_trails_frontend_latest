import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../state/trip_provider.dart';
import '../../core/services/weather_service.dart';
import '../../widgets/animated_gradient_scaffold.dart';
import '../../core/models/trip.dart';

class ScheduleViewerPage extends StatefulWidget {
  const ScheduleViewerPage({super.key});

  @override
  State<ScheduleViewerPage> createState() => _ScheduleViewerPageState();
}

class _ScheduleViewerPageState extends State<ScheduleViewerPage> {
  Timer? _timer;
  int _currentStopIndex = 0;
  bool _isTripActive = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          // Update current time and check if we should move to next stop
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripProvider>();
    final currentTrip = trips.currentTrip;
    final cs = Theme.of(context).colorScheme;

    if (currentTrip == null) {
      return _buildNoTripState(context, cs);
    }

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Schedule Viewer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isTripActive ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isTripActive = !_isTripActive;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(_isTripActive ? 'Trip started!' : 'Trip paused'),
                  backgroundColor: _isTripActive ? Colors.green : Colors.orange,
                ),
              );
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
            // Trip Status Header
            _buildTripStatusHeader(context, cs, currentTrip),
            const SizedBox(height: 20),

            // Weather Alert (if applicable)
            _buildWeatherAlert(context, cs),
            const SizedBox(height: 20),

            // Current Location (if trip is active)
            if (_isTripActive &&
                _currentStopIndex < currentTrip.stops.length) ...[
              _buildCurrentLocationCard(context, cs, currentTrip),
              const SizedBox(height: 20),
            ],

            // Full Itinerary
            _buildItineraryList(context, cs, currentTrip),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(context, cs, currentTrip),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTripState(BuildContext context, ColorScheme cs) {
    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Schedule Viewer'),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Active Trip',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create a schedule first to view your itinerary',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        cs.primary,
                        cs.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.build),
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text('Create Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripStatusHeader(
      BuildContext context, ColorScheme cs, Trip trip) {
    final progress = _currentStopIndex / trip.stops.length;
    final completedStops = _currentStopIndex;
    final totalStops = trip.stops.length;

    return Container(
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
                _isTripActive ? Icons.play_circle_fill : Icons.schedule_rounded,
                color: _isTripActive ? Colors.green : cs.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _isTripActive ? 'Trip in Progress' : 'Ready to Start',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isTripActive
                      ? Colors.green.withOpacity(0.2)
                      : cs.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isTripActive ? 'LIVE' : 'READY',
                  style: TextStyle(
                    color: _isTripActive ? Colors.green : cs.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedStops of $totalStops stops completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isTripActive ? Colors.green : cs.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _isTripActive ? Colors.green : cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAlert(BuildContext context, ColorScheme cs) {
    final weather = WeatherService.getCurrentWeather();
    final alerts = WeatherService.getWeatherAlerts();

    if (alerts.isEmpty && weather.isGoodForTravel) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alerts.isNotEmpty
            ? Colors.orange.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alerts.isNotEmpty
              ? Colors.orange.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            alerts.isNotEmpty ? Icons.warning : Icons.info,
            color: alerts.isNotEmpty ? Colors.orange : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alerts.isNotEmpty
                  ? alerts.first.message
                  : 'Weather conditions are good for travel',
              style: TextStyle(
                color: alerts.isNotEmpty ? Colors.orange : Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationCard(
      BuildContext context, ColorScheme cs, Trip trip) {
    if (_currentStopIndex >= trip.stops.length) return const SizedBox.shrink();

    final currentStop = trip.stops[_currentStopIndex];
    final timeRemaining = _calculateTimeRemaining(currentStop);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
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
              Icon(Icons.location_on, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Location',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentStop.location.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule,
                  color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 8),
              Text(
                'Arrived at ${currentStop.etaHHMM}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (timeRemaining > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: timeRemaining <= 10
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: timeRemaining <= 10
                      ? Colors.orange.withOpacity(0.5)
                      : Colors.green.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: timeRemaining <= 10 ? Colors.orange : Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeRemaining <= 10
                        ? 'Only $timeRemaining minutes left!'
                        : '$timeRemaining minutes remaining',
                    style: TextStyle(
                      color: timeRemaining <= 10 ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItineraryList(BuildContext context, ColorScheme cs, Trip trip) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.route, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Full Itinerary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(trip.stops.length, (index) {
            final stop = trip.stops[index];
            final isCurrent = _isTripActive && index == _currentStopIndex;
            final isCompleted = _isTripActive && index < _currentStopIndex;
            final isUpcoming = !_isTripActive || index > _currentStopIndex;

            return _buildItineraryItem(
              context,
              cs,
              stop,
              index,
              trip.stops.length,
              isCurrent: isCurrent,
              isCompleted: isCompleted,
              isUpcoming: isUpcoming,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItineraryItem(
    BuildContext context,
    ColorScheme cs,
    TripStop stop,
    int index,
    int totalStops, {
    required bool isCurrent,
    required bool isCompleted,
    required bool isUpcoming,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isCurrent) {
      statusColor = Colors.green;
      statusIcon = Icons.location_on;
      statusText = 'Current';
    } else if (isCompleted) {
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle;
      statusText = 'Completed';
    } else {
      statusColor = Colors.white.withOpacity(0.6);
      statusIcon = Icons.schedule;
      statusText = 'Upcoming';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.green.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? Colors.green.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Center(
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          // Location info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.location.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ETA: ${stop.etaHHMM} • Duration: ${stop.plannedDurationMin} min',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Travel time to next (if not last)
          if (index < totalStops - 1) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '15 min', // This would be calculated from actual travel time
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme cs, Trip trip) {
    return Row(
      children: [
        if (_isTripActive) ...[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.green.withOpacity(0.8),
                  ],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_currentStopIndex < trip.stops.length - 1) {
                    setState(() {
                      _currentStopIndex++;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Moving to next location'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Complete the trip - fill progress to 100%
                    setState(() {
                      _currentStopIndex = trip.stops.length;
                    });

                    // Move trip to past trips
                    final trips = context.read<TripProvider>();
                    trips.completeCurrentTrip();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trip completed! Moved to past trips.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(_currentStopIndex < trip.stops.length - 1
                    ? 'Next Stop'
                    : 'Complete Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    cs.primary,
                    cs.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isTripActive = true;
                    _currentStopIndex = 0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trip started!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Trip'),
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
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.overview),
              icon: const Icon(Icons.timeline),
              label: const Text('Overview'),
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
        ),
      ],
    );
  }

  int _calculateTimeRemaining(TripStop stop) {
    // This would calculate actual time remaining based on current time
    // For demo purposes, return a simulated value
    return stop.plannedDurationMin - 15; // Assume 15 minutes have passed
  }
}
