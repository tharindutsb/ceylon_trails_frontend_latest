import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/trip.dart';

/// Service for live tracking of itinerary execution with GPS
class LiveTrackingService {
  static final LiveTrackingService _instance = LiveTrackingService._internal();
  factory LiveTrackingService() => _instance;
  LiveTrackingService._internal();

  Timer? _trackingTimer;
  StreamSubscription<Position>? _positionSubscription;
  int _currentStopIndex = 0;
  Trip? _currentTrip;
  Position? _currentPosition;
  final StreamController<TrackingUpdate> _trackingController =
      StreamController.broadcast();

  /// Start tracking a trip with GPS
  Future<void> startTracking(Trip trip) async {
    _currentTrip = trip;
    _currentStopIndex = 0;

    // Request location permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _trackingController.add(TrackingUpdate(
        type: TrackingType.error,
        message: 'Location services are disabled',
        currentStop: null,
        nextStop: null,
        timeRemaining: 0,
      ));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _trackingController.add(TrackingUpdate(
          type: TrackingType.error,
          message: 'Location permissions are denied',
          currentStop: null,
          nextStop: null,
          timeRemaining: 0,
        ));
        return;
      }
    }

    // Start GPS tracking
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10 meters
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _updateTrackingWithGPS();
    });

    // Start periodic tracking updates
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateTracking();
    });

    // Get initial position
    _currentPosition = await Geolocator.getCurrentPosition();

    _trackingController.add(TrackingUpdate(
      type: TrackingType.tripStarted,
      message: 'Trip tracking started',
      currentStop: _getCurrentStop(),
      nextStop: _getNextStop(),
      timeRemaining: _getTimeRemaining(),
    ));
  }

  /// Update tracking with GPS data
  void _updateTrackingWithGPS() {
    if (_currentPosition != null && _currentTrip != null) {
      final currentStop = _getCurrentStop();
      if (currentStop != null) {
        // Calculate distance to current destination
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          currentStop.location.lat,
          currentStop.location.lon,
        );

        // Estimate time to destination based on distance
        // This could be used for future ETA predictions

        _trackingController.add(TrackingUpdate(
          type: TrackingType.locationUpdate,
          message:
              'GPS updated - ${(distance / 1000).toStringAsFixed(1)} km to destination',
          currentStop: currentStop,
          nextStop: _getNextStop(),
          timeRemaining: _getTimeRemaining(),
          distanceToNext: distance,
        ));
      }
    }
  }

  /// Stop tracking
  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _currentTrip = null;
    _currentStopIndex = 0;
    _currentPosition = null;
  }

  /// Confirm arrival at current location
  void confirmArrival() {
    if (_currentTrip == null) return;

    _trackingController.add(TrackingUpdate(
      type: TrackingType.arrivalConfirmed,
      message: 'Arrived at ${_getCurrentStop()?.location.name}',
      currentStop: _getCurrentStop(),
      nextStop: _getNextStop(),
      timeRemaining: _getTimeRemaining(),
    ));
  }

  /// Move to next stop
  void moveToNextStop() {
    if (_currentTrip == null) return;

    _currentStopIndex++;
    if (_currentStopIndex >= _currentTrip!.stops.length) {
      // Trip completed
      _trackingController.add(TrackingUpdate(
        type: TrackingType.tripCompleted,
        message: 'Trip completed successfully!',
        currentStop: null,
        nextStop: null,
        timeRemaining: 0,
      ));
      stopTracking();
      return;
    }

    _trackingController.add(TrackingUpdate(
      type: TrackingType.movedToNext,
      message: 'Moving to next location',
      currentStop: _getCurrentStop(),
      nextStop: _getNextStop(),
      timeRemaining: _getTimeRemaining(),
    ));
  }

  /// Get tracking updates stream
  Stream<TrackingUpdate> get trackingUpdates => _trackingController.stream;

  /// Get current stop
  TripStop? _getCurrentStop() {
    if (_currentTrip == null ||
        _currentStopIndex >= _currentTrip!.stops.length) {
      return null;
    }
    return _currentTrip!.stops[_currentStopIndex];
  }

  /// Get next stop
  TripStop? _getNextStop() {
    if (_currentTrip == null ||
        _currentStopIndex + 1 >= _currentTrip!.stops.length) {
      return null;
    }
    return _currentTrip!.stops[_currentStopIndex + 1];
  }

  /// Get time remaining at current location
  int _getTimeRemaining() {
    final currentStop = _getCurrentStop();
    if (currentStop == null) return 0;

    // Simulate time remaining (in production, this would be calculated based on actual time)
    return currentStop.plannedDurationMin -
        (Random().nextInt(30)); // Random remaining time
  }

  /// Update tracking status
  void _updateTracking() {
    if (_currentTrip == null) return;

    final currentStop = _getCurrentStop();
    if (currentStop == null) return;

    final timeRemaining = _getTimeRemaining();
    final nextStop = _getNextStop();

    // Check if it's time to move to next location
    if (timeRemaining <= 0 && nextStop != null) {
      _trackingController.add(TrackingUpdate(
        type: TrackingType.timeToMove,
        message: 'Time to move to next location: ${nextStop.location.name}',
        currentStop: currentStop,
        nextStop: nextStop,
        timeRemaining: 0,
      ));
    } else if (timeRemaining <= 10 && timeRemaining > 0) {
      _trackingController.add(TrackingUpdate(
        type: TrackingType.warning,
        message: 'Only $timeRemaining minutes left at current location',
        currentStop: currentStop,
        nextStop: nextStop,
        timeRemaining: timeRemaining,
      ));
    }
  }

  /// Get travel time to next destination
  int getTravelTimeToNext() {
    final currentStop = _getCurrentStop();
    final nextStop = _getNextStop();

    if (currentStop == null || nextStop == null) return 0;

    // Simulate travel time calculation
    return 15 + Random().nextInt(30); // 15-45 minutes
  }

  /// Get weather conditions for current location
  String getCurrentWeatherCondition() {
    final conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy'];
    return conditions[Random().nextInt(conditions.length)];
  }

  /// Get weather recommendation for current location
  String getWeatherRecommendation() {
    final condition = getCurrentWeatherCondition();
    switch (condition) {
      case 'Rainy':
        return 'Bring umbrella and rain gear';
      case 'Sunny':
        return 'Wear sunscreen and stay hydrated';
      case 'Cloudy':
        return 'Perfect weather for sightseeing';
      default:
        return 'Enjoy your visit';
    }
  }

  /// Dispose resources
  void dispose() {
    _trackingTimer?.cancel();
    _trackingController.close();
  }
}

/// Tracking update model
class TrackingUpdate {
  final TrackingType type;
  final String message;
  final TripStop? currentStop;
  final TripStop? nextStop;
  final int timeRemaining;
  final double? distanceToNext; // in meters

  TrackingUpdate({
    required this.type,
    required this.message,
    required this.currentStop,
    required this.nextStop,
    required this.timeRemaining,
    this.distanceToNext,
  });
}

/// Tracking update types
enum TrackingType {
  tripStarted,
  arrivalConfirmed,
  movedToNext,
  timeToMove,
  warning,
  tripCompleted,
  locationUpdate,
  error,
}
