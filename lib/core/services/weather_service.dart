import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// Weather data model (unchanged)
class WeatherData {
  final String condition;
  final int temperature; // °C
  final int humidity; // %
  final int windSpeed; // km/h
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
  String toString() =>
      'WeatherData($condition, ${temperature}°C, $humidity% humidity, $windSpeed km/h)';
}

/// Weather alert model (unchanged)
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

/// Service: real API + safe fallbacks (your previous simulators)
class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  static const _openMeteo = 'https://api.open-meteo.com/v1/forecast';

  // --- simple cache to avoid frequent hits (15 min) ---
  static WeatherData? _cache;
  static DateTime? _cacheAt;
  static const _ttl = Duration(minutes: 15);

  /// Get current weather by coordinates (Open-Meteo, no key).
  static Future<WeatherData> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    if (_cache != null &&
        _cacheAt != null &&
        DateTime.now().difference(_cacheAt!) < _ttl) {
      return _cache!;
    }

    final uri = Uri.parse(_openMeteo).replace(queryParameters: {
      'latitude': '$lat',
      'longitude': '$lon',
      'current':
          'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'timezone': 'auto',
    });

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final cur = Map<String, dynamic>.from(data['current']);

      final temp = (cur['temperature_2m'] as num).toDouble();
      final hum = (cur['relative_humidity_2m'] as num?)?.toInt() ?? 60;
      final wind = (cur['wind_speed_10m'] as num?)?.toInt() ?? 0;
      final code = (cur['weather_code'] as num).toInt();
      final condition = _codeToSummary(code);
      final tInt = temp.round();

      _cache = WeatherData(
        condition: condition,
        temperature: tInt,
        humidity: hum,
        windSpeed: wind,
        isGoodForTravel: _isGoodForTravel(condition, tInt),
        recommendation: _getWeatherRecommendation(condition, tInt),
      );
      _cacheAt = DateTime.now();
      return _cache!;
    } catch (_) {
      return getCurrentWeather(); // fallback
    }
  }

  /// Helper: obtain device location then fetch current weather.
  static Future<WeatherData> fetchCurrentForDevice() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      // fallback if denied
      return getCurrentWeather();
    }
    final pos = await Geolocator.getCurrentPosition();
    return fetchCurrentWeather(lat: pos.latitude, lon: pos.longitude);
  }

  /// Forecast for N days (avg of min/max per day).
  static Future<List<WeatherData>> fetchWeatherForecast({
    required double lat,
    required double lon,
    int days = 5,
  }) async {
    final uri = Uri.parse(_openMeteo).replace(queryParameters: {
      'latitude': '$lat',
      'longitude': '$lon',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
    });

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final daily = Map<String, dynamic>.from(data['daily']);

      final codes = (daily['weather_code'] as List)
          .cast<num>()
          .map((e) => e.toInt())
          .toList();
      final tMax = (daily['temperature_2m_max'] as List)
          .cast<num>()
          .map((e) => e.toDouble())
          .toList();
      final tMin = (daily['temperature_2m_min'] as List)
          .cast<num>()
          .map((e) => e.toDouble())
          .toList();

      final out = <WeatherData>[];
      for (int i = 0; i < codes.length && out.length < days; i++) {
        final tAvg = ((tMax[i] + tMin[i]) / 2.0).round();
        final condition = _codeToSummary(codes[i]);
        out.add(WeatherData(
          condition: condition,
          temperature: tAvg,
          humidity: 60,
          windSpeed: 10,
          isGoodForTravel: _isGoodForTravel(condition, tAvg),
          recommendation: _getWeatherRecommendation(condition, tAvg),
        ));
      }
      return out;
    } catch (_) {
      return getWeatherForecast(days);
    }
  }

  // --------- your existing simulators (kept as fallback) ---------

  static WeatherData getCurrentWeather() {
    final conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy', 'Stormy'];
    final condition = conditions[Random().nextInt(conditions.length)];
    final temperature = 20 + Random().nextInt(20); // 20–40°C
    final humidity = 40 + Random().nextInt(40); // 40–80%
    final windSpeed = Random().nextInt(20); // 0–20 km/h
    return WeatherData(
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      isGoodForTravel: _isGoodForTravel(condition, temperature),
      recommendation: _getWeatherRecommendation(condition, temperature),
    );
  }

  static List<WeatherData> getWeatherForecast(int days) =>
      List.generate(days, (_) => getCurrentWeather());

  static List<WeatherAlert> getWeatherAlerts() {
    final alerts = <WeatherAlert>[];
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

  static List<String> getOptimalTravelTimes() => const [
        'Early morning (6–8 AM): Cool and comfortable',
        'Late afternoon (4–6 PM): Pleasant temperature',
        'Avoid midday (12–2 PM): Peak heat hours',
      ];

  // --------- helpers ---------

  static bool _isGoodForTravel(String condition, int temperature) {
    if (condition.contains('Storm')) return false;
    if (condition.contains('Rain') && temperature < 25) return false;
    if (temperature > 35) return false;
    return true;
  }

  static String _getWeatherRecommendation(String condition, int temperature) {
    if (condition.contains('Storm')) {
      return 'Avoid outdoor activities. Consider indoor attractions.';
    } else if (condition.contains('Rain')) {
      return 'Bring umbrella and rain gear. Indoor activities recommended.';
    } else if (temperature > 35) {
      return 'Very hot! Stay hydrated, wear light clothes, and avoid midday sun.';
    } else if (temperature < 20) {
      return 'Cool weather. Dress warmly and enjoy comfortable sightseeing.';
    } else {
      return 'Perfect weather for outdoor activities!';
    }
  }

  static String _codeToSummary(int code) {
    if (code == 0) return 'Sunny';
    if ({1, 2, 3}.contains(code)) return 'Partly Cloudy';
    if ({45, 48}.contains(code)) return 'Foggy';
    if ({51, 53, 55, 61, 63, 65}.contains(code)) return 'Rainy';
    if ({66, 67, 71, 73, 75, 77}.contains(code)) return 'Snow';
    if ({80, 81, 82}.contains(code)) return 'Showers';
    if ({95, 96, 99}.contains(code)) return 'Stormy';
    return 'Cloudy';
  }
}
