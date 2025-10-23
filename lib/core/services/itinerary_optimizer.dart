import '../models/location.dart';

/// Service to optimize itinerary based on preferred times and travel duration
class ItineraryOptimizer {
  static final ItineraryOptimizer _instance = ItineraryOptimizer._internal();
  factory ItineraryOptimizer() => _instance;
  ItineraryOptimizer._internal();

  /// Optimize itinerary by ordering locations based on preferred times
  static List<LocationItem> optimizeItinerary(List<LocationItem> locations) {
    if (locations.isEmpty) return locations;

    // Sort locations by preferred start time
    final sortedLocations = List<LocationItem>.from(locations);
    sortedLocations.sort((a, b) {
      final aStart = _parseTime(a.prefStart);
      final bStart = _parseTime(b.prefStart);
      return aStart.compareTo(bStart);
    });

    return sortedLocations;
  }

  /// Parse time string (HH:MM) to minutes since midnight
  static int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  /// Create optimized schedule for a day
  static List<ScheduleItem> createDailySchedule({
    required List<LocationItem> locations,
    required String startTime,
    required int bufferMinutes,
  }) {
    if (locations.isEmpty) return [];

    final optimizedLocations = optimizeItinerary(locations);
    final schedule = <ScheduleItem>[];
    var currentTime = _parseTime(startTime);

    for (int i = 0; i < optimizedLocations.length; i++) {
      final location = optimizedLocations[i];

      // Calculate arrival time
      final arrivalTime = _formatTime(currentTime);

      // Use predicted duration or default
      final visitDuration = location.suggestedDurationMin;

      // Calculate departure time
      final departureTime = currentTime + visitDuration;

      // Add to schedule
      schedule.add(ScheduleItem(
        location: location,
        arrivalTime: arrivalTime,
        departureTime: _formatTime(departureTime),
        visitDuration: visitDuration,
        order: i + 1,
      ));

      // Add travel time to next location (if not last)
      if (i < optimizedLocations.length - 1) {
        final nextLocation = optimizedLocations[i + 1];
        final travelTime = _estimateTravelTime(location, nextLocation);
        currentTime = departureTime + travelTime + bufferMinutes;
      }
    }

    return schedule;
  }

  /// Estimate travel time between locations
  static int _estimateTravelTime(LocationItem from, LocationItem to) {
    // This would integrate with TravelDurationService in production
    // For now, return a simulated value
    return 15 + (from.name.hashCode % 30); // 15-45 minutes
  }

  /// Format minutes since midnight to HH:MM
  static String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  /// Check if schedule is feasible within preferred time windows
  static bool isScheduleFeasible(List<ScheduleItem> schedule) {
    for (final item in schedule) {
      final arrivalTime = _parseTime(item.arrivalTime);
      final preferredStart = _parseTime(item.location.prefStart);
      final preferredEnd = _parseTime(item.location.prefEnd);

      // Check if arrival time is within preferred window
      if (arrivalTime < preferredStart || arrivalTime > preferredEnd) {
        return false;
      }
    }
    return true;
  }

  /// Get schedule optimization suggestions
  static List<String> getOptimizationSuggestions(List<ScheduleItem> schedule) {
    final suggestions = <String>[];

    for (final item in schedule) {
      final arrivalTime = _parseTime(item.arrivalTime);
      final preferredStart = _parseTime(item.location.prefStart);
      final preferredEnd = _parseTime(item.location.prefEnd);

      if (arrivalTime < preferredStart) {
        suggestions.add(
            '${item.location.name}: Consider starting later to match preferred time');
      } else if (arrivalTime > preferredEnd) {
        suggestions.add(
            '${item.location.name}: Consider starting earlier to match preferred time');
      }
    }

    return suggestions;
  }

  /// Calculate total schedule duration
  static int calculateTotalDuration(List<ScheduleItem> schedule) {
    if (schedule.isEmpty) return 0;

    final firstArrival = _parseTime(schedule.first.arrivalTime);
    final lastDeparture = _parseTime(schedule.last.departureTime);

    return lastDeparture - firstArrival;
  }
}

/// Represents a scheduled item in the itinerary
class ScheduleItem {
  final LocationItem location;
  final String arrivalTime;
  final String departureTime;
  final int visitDuration;
  final int order;

  ScheduleItem({
    required this.location,
    required this.arrivalTime,
    required this.departureTime,
    required this.visitDuration,
    required this.order,
  });

  @override
  String toString() {
    return 'ScheduleItem(${location.name}: $arrivalTime - $departureTime)';
  }
}
