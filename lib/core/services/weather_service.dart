import 'dart:math';

/// Service to simulate weather data and notifications
/// In production, this would call a real weather API
class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  /// Get current weather conditions
  static WeatherData getCurrentWeather() {
    // Simulate weather data
    final conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy', 'Stormy'];
    final condition = conditions[Random().nextInt(conditions.length)];

    final temperature = 20 + Random().nextInt(20); // 20-40°C
    final humidity = 40 + Random().nextInt(40); // 40-80%
    final windSpeed = Random().nextInt(20); // 0-20 km/h

    return WeatherData(
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      isGoodForTravel: _isGoodForTravel(condition, temperature),
      recommendation: _getWeatherRecommendation(condition, temperature),
    );
  }

  /// Get weather forecast for the next few days
  static List<WeatherData> getWeatherForecast(int days) {
    final forecast = <WeatherData>[];
    for (int i = 0; i < days; i++) {
      forecast.add(getCurrentWeather());
    }
    return forecast;
  }

  /// Check if weather is good for travel
  static bool _isGoodForTravel(String condition, int temperature) {
    if (condition == 'Stormy') return false;
    if (condition == 'Rainy' && temperature < 25) return false;
    if (temperature > 35) return false;
    return true;
  }

  /// Get weather-based recommendations
  static String _getWeatherRecommendation(String condition, int temperature) {
    if (condition == 'Stormy') {
      return 'Avoid outdoor activities. Consider indoor attractions.';
    } else if (condition == 'Rainy') {
      return 'Bring umbrella and rain gear. Indoor activities recommended.';
    } else if (temperature > 35) {
      return 'Very hot! Stay hydrated, wear light clothes, and avoid midday sun.';
    } else if (temperature < 20) {
      return 'Cool weather. Dress warmly and enjoy comfortable sightseeing.';
    } else {
      return 'Perfect weather for outdoor activities!';
    }
  }

  /// Get weather alerts for travel
  static List<WeatherAlert> getWeatherAlerts() {
    final alerts = <WeatherAlert>[];

    // Simulate potential alerts
    if (Random().nextBool()) {
      alerts.add(WeatherAlert(
        type: 'Heat Warning',
        message:
            'High temperatures expected. Stay hydrated and avoid prolonged sun exposure.',
        severity: 'Medium',
        icon: '🌡️',
      ));
    }

    if (Random().nextBool()) {
      alerts.add(WeatherAlert(
        type: 'Rain Alert',
        message:
            'Light rain expected in the afternoon. Consider indoor alternatives.',
        severity: 'Low',
        icon: '🌧️',
      ));
    }

    return alerts;
  }

  /// Get optimal travel times based on weather
  static List<String> getOptimalTravelTimes() {
    return [
      'Early morning (6-8 AM): Cool and comfortable',
      'Late afternoon (4-6 PM): Pleasant temperature',
      'Avoid midday (12-2 PM): Peak heat hours',
    ];
  }
}

/// Weather data model
class WeatherData {
  final String condition;
  final int temperature;
  final int humidity;
  final int windSpeed;
  final bool isGoodForTravel;
  final String recommendation;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.isGoodForTravel,
    required this.recommendation,
  });

  @override
  String toString() {
    return 'WeatherData($condition, ${temperature}°C, $humidity% humidity)';
  }
}

/// Weather alert model
class WeatherAlert {
  final String type;
  final String message;
  final String severity;
  final String icon;

  WeatherAlert({
    required this.type,
    required this.message,
    required this.severity,
    required this.icon,
  });
}
