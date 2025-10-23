import 'dart:math';
import '../models/location.dart';

/// Service to simulate travel duration calculations between locations
/// In production, this would call a real API like Google Maps or similar
class TravelDurationService {
  static final TravelDurationService _instance =
      TravelDurationService._internal();
  factory TravelDurationService() => _instance;
  TravelDurationService._internal();

  /// Calculate travel duration between two locations
  /// Returns duration in minutes
  static int calculateTravelDuration(LocationItem from, LocationItem to) {
    // Simulate API call delay
    // In production, this would be an actual API call

    // Base travel time calculation based on distance and traffic
    final baseTime = _calculateBaseTravelTime(from, to);
    final trafficMultiplier = _getTrafficMultiplier();
    final weatherFactor = _getWeatherFactor();

    return (baseTime * trafficMultiplier * weatherFactor).round();
  }

  /// Calculate base travel time based on distance
  static int _calculateBaseTravelTime(LocationItem from, LocationItem to) {
    // Simulate distance calculation
    final distance = _calculateDistance(from, to);

    // Average speed in km/h (considering city traffic)
    const averageSpeed = 25.0;

    // Convert to minutes
    return ((distance / averageSpeed) * 60).round();
  }

  /// Simulate distance calculation between locations
  static double _calculateDistance(LocationItem from, LocationItem to) {
    // In production, this would use real coordinates
    // For now, simulate based on location names and types

    final distance = Random().nextDouble() * 20 + 5; // 5-25 km
    return distance;
  }

  /// Get traffic multiplier based on time of day
  static double _getTrafficMultiplier() {
    final hour = DateTime.now().hour;

    // Peak hours have higher traffic
    if (hour >= 7 && hour <= 9) return 1.5; // Morning rush
    if (hour >= 17 && hour <= 19) return 1.4; // Evening rush
    if (hour >= 12 && hour <= 14) return 1.2; // Lunch time
    return 1.0; // Normal traffic
  }

  /// Get weather factor (rain, etc.)
  static double _getWeatherFactor() {
    // Simulate weather conditions
    final weather = Random().nextInt(4);
    switch (weather) {
      case 0:
        return 1.3; // Heavy rain
      case 1:
        return 1.1; // Light rain
      case 2:
        return 1.0; // Clear weather
      case 3:
        return 0.9; // Perfect weather
      default:
        return 1.0;
    }
  }

  /// Get optimal travel time between locations based on traffic patterns
  static String getOptimalTravelTime(LocationItem from, LocationItem to) {
    final hour = DateTime.now().hour;

    // Suggest optimal times based on traffic patterns
    if (hour < 7 || hour > 19) {
      return 'Early morning or evening (less traffic)';
    } else if (hour >= 10 && hour <= 11) {
      return 'Mid-morning (good traffic)';
    } else if (hour >= 14 && hour <= 16) {
      return 'Afternoon (moderate traffic)';
    } else {
      return 'Peak hours (expect delays)';
    }
  }

  /// Calculate total travel time for a route with multiple stops
  static int calculateRouteTravelTime(List<LocationItem> locations) {
    if (locations.length < 2) return 0;

    int totalTime = 0;
    for (int i = 0; i < locations.length - 1; i++) {
      totalTime += calculateTravelDuration(locations[i], locations[i + 1]);
    }

    return totalTime;
  }

  /// Get travel mode recommendations
  static String getRecommendedTravelMode(LocationItem from, LocationItem to) {
    final distance = _calculateDistance(from, to);

    if (distance < 2) {
      return 'Walking (${(distance * 12).round()} min)';
    } else if (distance < 5) {
      return 'Tuk-tuk or Taxi';
    } else {
      return 'Car or Bus';
    }
  }
}
