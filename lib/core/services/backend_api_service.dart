import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../models/group.dart';
import '../models/person.dart';

/// Service to communicate with the backend ML API
class BackendApiService {
  static const String baseUrl = 'http://localhost:5000';

  /// Predict location suitability for a group
  static Future<LocationSuitabilityPrediction> predictSuitability({
    required LocationItem location,
    required Group group,
  }) async {
    try {
      // Calculate group statistics
      final ages = group.people.map((p) => p.age).toList();
      final minAge = ages.isEmpty ? 30 : ages.reduce((a, b) => a < b ? a : b);
      final maxAge = ages.isEmpty ? 50 : ages.reduce((a, b) => a > b ? a : b);

      int nFullyMobile = 0;
      int nAssisted = 0;
      int nWheelchairUser = 0;
      int nLimitedEndurance = 0;
      int nChildCarried = 0;

      for (var person in group.people) {
        switch (person.mobility) {
          case Mobility.fullyMobile:
            nFullyMobile++;
            break;
          case Mobility.assisted:
            nAssisted++;
            break;
          case Mobility.wheelchair:
            nWheelchairUser++;
            break;
          case Mobility.limitedEndurance:
            nLimitedEndurance++;
            break;
          case Mobility.childCarried:
            nChildCarried++;
            break;
        }
      }

      final requestBody = {
        'group_size': group.people.length,
        'min_age': minAge,
        'max_age': maxAge,
        'n_fully_mobile': nFullyMobile,
        'n_assisted': nAssisted,
        'n_wheelchair_user': nWheelchairUser,
        'n_limited_endurance': nLimitedEndurance,
        'n_child_carried': nChildCarried,
        'location_name': location.name,
        'location_type': location.type.toString().split('.').last,
        'terrain_level': location.terrain.toString().split('.').last,
        'accessibility': location.access.toString().split('.').last,
        'heat_exposure_level': location.heat.toString().split('.').last,
        'preferred_visit_start': location.prefStart,
        'preferred_visit_end': location.prefEnd,
        'best_time_window': _getTimeWindowFromTime(location.prefStart),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/predict/suitability'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LocationSuitabilityPrediction(
          suitabilityScore: data['suitability_score'],
          isSuitable: data['is_suitable'],
          recommendedDurationMin: data['recommended_duration_min'],
          bestTimeWindow: data['best_time_window'],
          confidence: data['confidence'] ?? 0.7,
        );
      } else {
        // Fallback to local prediction
        return _fallbackPrediction(location, group);
      }
    } catch (e) {
      // Fallback to local prediction
      return _fallbackPrediction(location, group);
    }
  }

  /// Optimize itinerary with meal times
  static Future<ItineraryOptimizationResult> optimizeItinerary({
    required List<LocationItem> locations,
    required String startTime,
    required String endTime,
    bool includeBreakfast = true,
    bool includeLunch = true,
    bool includeDinner = true,
  }) async {
    try {
      final requestBody = {
        'locations': locations
            .map((loc) => {
                  'name': loc.name,
                  'duration_min': loc.suggestedDurationMin,
                })
            .toList(),
        'start_time': startTime,
        'end_time': endTime,
        'include_breakfast': includeBreakfast,
        'include_lunch': includeLunch,
        'include_dinner': includeDinner,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/optimize/itinerary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ItineraryOptimizationResult(
          schedule: List<Map<String, dynamic>>.from(data['optimized_schedule']),
          totalDurationMin: data['total_duration_min'],
        );
      }
    } catch (e) {
      print('Error calling optimization API: $e');
    }

    // Return empty result if API fails
    return ItineraryOptimizationResult(
      schedule: [],
      totalDurationMin: 0,
    );
  }

  /// Check backend health
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Fallback prediction when backend is unavailable
  static LocationSuitabilityPrediction _fallbackPrediction(
    LocationItem location,
    Group group,
  ) {
    // Simple heuristic-based prediction
    double suitability = 0.8;

    if (location.terrain.toString().contains('steep')) suitability -= 0.2;
    if (location.terrain.toString().contains('hilly')) suitability -= 0.15;
    if (location.access.toString().contains('limited')) suitability -= 0.25;
    if (location.heat.toString().contains('high')) suitability -= 0.1;

    return LocationSuitabilityPrediction(
      suitabilityScore: suitability.clamp(0.0, 1.0),
      isSuitable: suitability >= 0.5,
      recommendedDurationMin: location.suggestedDurationMin,
      bestTimeWindow: _getTimeWindowFromTime(location.prefStart),
      confidence: 0.6,
    );
  }

  static String _getTimeWindowFromTime(String time) {
    final hour = int.parse(time.split(':')[0]);
    if (hour < 10) return 'Morning';
    if (hour < 14) return 'Midday';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

/// Prediction result for location suitability
class LocationSuitabilityPrediction {
  final double suitabilityScore;
  final bool isSuitable;
  final int recommendedDurationMin;
  final String bestTimeWindow;
  final double confidence;

  LocationSuitabilityPrediction({
    required this.suitabilityScore,
    required this.isSuitable,
    required this.recommendedDurationMin,
    required this.bestTimeWindow,
    required this.confidence,
  });
}

/// Result from itinerary optimization
class ItineraryOptimizationResult {
  final List<Map<String, dynamic>> schedule;
  final int totalDurationMin;

  ItineraryOptimizationResult({
    required this.schedule,
    required this.totalDurationMin,
  });
}
