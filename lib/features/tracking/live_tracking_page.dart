import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/live_tracking_service.dart';
import '../../core/services/weather_service.dart';
import '../../state/trip_provider.dart';
import '../../widgets/animated_gradient_scaffold.dart';
import '../../core/models/trip.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final LiveTrackingService _trackingService = LiveTrackingService();
  StreamSubscription<TrackingUpdate>? _trackingSubscription;
  TrackingUpdate? _currentUpdate;
  WeatherData? _currentWeather;

  @override
  void initState() {
    super.initState();
    _startTracking();
    _currentWeather = WeatherService.getCurrentWeather();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    _trackingService.stopTracking();
    super.dispose();
  }

  void _startTracking() {
    final trips = context.read<TripProvider>();
    if (trips.currentTrip != null) {
      _trackingService.startTracking(trips.currentTrip!);
      _trackingSubscription = _trackingService.trackingUpdates.listen((update) {
        setState(() {
          _currentUpdate = update;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentWeather = WeatherService.getCurrentWeather();
              });
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
            // Current Status Card
            _buildCurrentStatusCard(context, cs),
            const SizedBox(height: 20),

            // Weather Information
            if (_currentWeather != null) ...[
              _buildWeatherCard(context, cs),
              const SizedBox(height: 20),
            ],

            // Next Destination
            if (_currentUpdate?.nextStop != null) ...[
              _buildNextDestinationCard(context, cs),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            _buildActionButtons(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(BuildContext context, ColorScheme cs) {
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
              Icon(Icons.location_on, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Current Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_currentUpdate?.currentStop != null) ...[
            _buildLocationInfo(_currentUpdate!.currentStop!, cs),
            const SizedBox(height: 16),
            if (_currentUpdate!.timeRemaining > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _currentUpdate!.timeRemaining <= 10
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _currentUpdate!.timeRemaining <= 10
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.green.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: _currentUpdate!.timeRemaining <= 10
                          ? Colors.orange
                          : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentUpdate!.timeRemaining <= 10
                            ? 'Only ${_currentUpdate!.timeRemaining} minutes left!'
                            : '${_currentUpdate!.timeRemaining} minutes remaining',
                        style: TextStyle(
                          color: _currentUpdate!.timeRemaining <= 10
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'No active trip',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo(TripStop stop, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stop.location.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arrival: ${stop.etaHHMM}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${stop.plannedDurationMin} minutes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Weather Conditions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _currentWeather!.condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${_currentWeather!.temperature}°C',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentWeather!.recommendation,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDestinationCard(BuildContext context, ColorScheme cs) {
    final nextStop = _currentUpdate!.nextStop!;
    final travelTime = _trackingService.getTravelTimeToNext();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.navigation, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Next Destination',
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
            nextStop.location.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
                'Travel time: $travelTime minutes',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
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
                _trackingService.confirmArrival();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Arrival confirmed!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirm Arrival'),
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
        const SizedBox(width: 16),
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
                _trackingService.moveToNextStop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Moving to next location'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Stop'),
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
}
