import '../models/location.dart';
import '../models/group.dart';

/// Service for predicting location suitability and travel details
class LocationPredictionService {
  /// Predict location details based on group and mobility status
  static LocationPrediction predictLocation({
    required LocationItem location,
    required Group group,
    String? mobilityStatus,
  }) {
    // Validate that group and mobility status are provided
    if (group.people.isEmpty) {
      throw ArgumentError('Group must have at least one person');
    }

    if (mobilityStatus == null || mobilityStatus.isEmpty) {
      throw ArgumentError('Mobility status must be provided for prediction');
    }

    // Base probability by access/terrain/heat
    double suitability = 0.85;

    // Adjust based on location characteristics
    if (location.access == Access.limited) suitability -= 0.25;
    if (location.terrain == Terrain.hilly) suitability -= 0.08;
    if (location.heat == Heat.high) suitability -= 0.07;

    // Adjust based on group size
    final groupSize = group.people.length;
    if (groupSize >= 5) suitability -= 0.05;
    if (groupSize >= 8) suitability -= 0.10;
    if (groupSize >= 12) suitability -= 0.15;

    // Adjust based on mobility status
    switch (mobilityStatus.toLowerCase()) {
      case 'wheelchair':
        if (location.access != Access.full) suitability -= 0.4;
        if (location.terrain == Terrain.hilly) suitability -= 0.3;
        break;
      case 'walking_aid':
        if (location.access == Access.limited) suitability -= 0.3;
        if (location.terrain == Terrain.hilly) suitability -= 0.2;
        break;
      case 'elderly':
        if (location.terrain == Terrain.hilly) suitability -= 0.15;
        if (location.heat == Heat.high) suitability -= 0.1;
        break;
      case 'pregnant':
        if (location.terrain == Terrain.hilly) suitability -= 0.2;
        if (location.heat == Heat.high) suitability -= 0.15;
        break;
      case 'children':
        if (location.access == Access.limited) suitability -= 0.2;
        if (location.heat == Heat.high) suitability -= 0.1;
        break;
      case 'fit':
        // No additional restrictions for fit individuals
        break;
      default:
        // Unknown mobility status - apply conservative adjustments
        suitability -= 0.1;
    }

    // Clamp suitability between 0.1 and 0.97
    suitability = suitability.clamp(0.1, 0.97);
    final isSuitable = suitability >= 0.5;

    // Calculate duration based on location and group factors
    int duration = location.suggestedDurationMin;

    // Adjust duration based on terrain
    if (location.terrain == Terrain.hilly) duration += 15;
    if (location.access == Access.limited) duration += 10;

    // Adjust duration based on group size
    if (groupSize >= 5) duration += 10;
    if (groupSize >= 8) duration += 15;

    // Adjust duration based on mobility status
    switch (mobilityStatus.toLowerCase()) {
      case 'wheelchair':
        duration = (duration * 1.3).round(); // 30% longer
        break;
      case 'walking_aid':
        duration = (duration * 1.2).round(); // 20% longer
        break;
      case 'elderly':
        duration = (duration * 1.15).round(); // 15% longer
        break;
      case 'pregnant':
        duration = (duration * 1.25).round(); // 25% longer
        break;
      case 'children':
        duration = (duration * 1.1).round(); // 10% longer
        break;
    }

    // If not suitable, reduce duration
    if (!isSuitable) duration = (duration * 0.85).round();

    // Determine best time window
    String timeWindow;
    if (location.heat == Heat.high) {
      timeWindow = 'Morning (6-10 AM) or Late Afternoon (4-6 PM)';
    } else if (location.heat == Heat.medium) {
      timeWindow = 'Morning (7-11 AM) or Evening (5-7 PM)';
    } else {
      timeWindow = 'Anytime (6 AM - 7 PM)';
    }

    // Adjust time window based on mobility status
    if (mobilityStatus.toLowerCase() == 'elderly' ||
        mobilityStatus.toLowerCase() == 'pregnant') {
      timeWindow = 'Morning (7-10 AM) - Cooler temperatures recommended';
    }

    // Calculate difficulty level
    String difficulty;
    if (location.terrain == Terrain.hilly &&
        location.access == Access.limited) {
      difficulty = 'Challenging';
    } else if (location.terrain == Terrain.hilly ||
        location.access == Access.limited) {
      difficulty = 'Moderate';
    } else {
      difficulty = 'Easy';
    }

    // Adjust difficulty based on mobility status
    if (mobilityStatus.toLowerCase() == 'wheelchair') {
      if (location.access != Access.full) difficulty = 'Not Recommended';
    } else if (mobilityStatus.toLowerCase() == 'walking_aid') {
      if (difficulty == 'Challenging')
        difficulty = 'Not Recommended';
      else if (difficulty == 'Moderate') difficulty = 'Challenging';
    }

    return LocationPrediction(
      suitability: suitability,
      isSuitable: isSuitable,
      duration: duration,
      timeWindow: timeWindow,
      difficulty: difficulty,
      recommendations:
          _generateRecommendations(location, group, mobilityStatus),
    );
  }

  /// Generate personalized recommendations
  static List<String> _generateRecommendations(
    LocationItem location,
    Group group,
    String mobilityStatus,
  ) {
    final recommendations = <String>[];

    // Group size recommendations
    if (group.people.length >= 8) {
      recommendations
          .add('Consider splitting into smaller groups for better experience');
    }

    // Mobility-specific recommendations
    switch (mobilityStatus.toLowerCase()) {
      case 'wheelchair':
        recommendations
            .add('Contact location in advance to confirm accessibility');
        recommendations.add('Bring a companion for assistance');
        break;
      case 'walking_aid':
        recommendations.add('Wear comfortable, non-slip shoes');
        recommendations.add('Take frequent breaks during the visit');
        break;
      case 'elderly':
        recommendations.add('Visit during cooler hours');
        recommendations.add('Bring water and take regular breaks');
        break;
      case 'pregnant':
        recommendations.add('Avoid strenuous activities');
        recommendations.add('Stay hydrated and take frequent breaks');
        break;
      case 'children':
        recommendations.add('Bring snacks and entertainment for children');
        recommendations.add('Plan for shorter visit duration');
        break;
    }

    // Location-specific recommendations
    if (location.heat == Heat.high) {
      recommendations.add('Bring sun protection and plenty of water');
    }
    if (location.terrain == Terrain.hilly) {
      recommendations.add('Wear appropriate footwear for hiking');
    }
    if (location.access == Access.limited) {
      recommendations.add('Check opening hours and availability in advance');
    }

    return recommendations;
  }
}

/// Data class for location predictions
class LocationPrediction {
  final double suitability; // 0.0 to 1.0
  final bool isSuitable;
  final int duration; // in minutes
  final String timeWindow;
  final String difficulty;
  final List<String> recommendations;

  const LocationPrediction({
    required this.suitability,
    required this.isSuitable,
    required this.duration,
    required this.timeWindow,
    required this.difficulty,
    required this.recommendations,
  });
}
