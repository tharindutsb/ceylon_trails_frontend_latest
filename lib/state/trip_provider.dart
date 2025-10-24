// lib/state/trip_provider.dart
import 'package:flutter/foundation.dart';

import '../core/models/group.dart';
import '../core/models/location.dart';
import '../core/models/trip.dart';
import '../core/services/travel_duration_service.dart';
import '../core/services/itinerary_optimizer.dart';

/// Holds the "working schedule" the user is building,
/// and the last saved Trip (overview/ongoing).
class TripProvider extends ChangeNotifier {
  // ------- Working plan (editable) -------
  String _startHHMM = '08:00';
  int _bufferMin = 15; // travel/transition buffer between stops
  final List<TripStop> _stops = [];

  // ------- Multi-day trip support -------
  DateTime? _tripStartDate;
  int _totalDays = 1;
  final Map<int, List<TripStop>> _dailyStops = {}; // day -> stops
  final Map<int, String> _dailyStartTimes = {}; // day -> start time
  final Map<int, String> _dailyEndTimes = {}; // day -> end time

  // ------- Saved trip (read-only snapshot) -------
  Trip? _currentTrip;

  // Getters
  String get startHHMM => _startHHMM;
  int get bufferMin => _bufferMin;
  List<TripStop> get stops => List.unmodifiable(_stops);
  Trip? get currentTrip => _currentTrip;

  // Multi-day getters
  DateTime? get tripStartDate => _tripStartDate;
  int get totalDays => _totalDays;
  int get tripDurationDays => _totalDays;
  int get currentDayIndex => 0; // For now, always show day 1
  String get endHHMM => _dailyEndTimes[1] ?? '18:00';
  Map<int, List<TripStop>> get dailyStops => Map.unmodifiable(_dailyStops);
  Map<int, String> get dailyStartTimes => Map.unmodifiable(_dailyStartTimes);
  Map<int, String> get dailyEndTimes => Map.unmodifiable(_dailyEndTimes);

  // Meal time settings
  bool _includeBreakfast = true;
  bool _includeLunch = true;
  bool _includeDinner = true;

  bool get includeBreakfast => _includeBreakfast;
  bool get includeLunch => _includeLunch;
  bool get includeDinner => _includeDinner;

  // ---------- Mutations on working plan ----------

  /// Pick a new start time (HH:MM)
  void pickStart(String hhmm) {
    _startHHMM = hhmm;
    _recomputeEtas();
    notifyListeners();
  }

  /// Increase/decrease the travel buffer between stops (in minutes).
  void changeBuffer(int delta) {
    _bufferMin = (_bufferMin + delta).clamp(0, 120);
    _recomputeEtas();
    notifyListeners();
  }

  /// Add a stop from a [LocationItem].
  /// If [plannedDurationMin] is not given, use the location's suggested duration.
  void addStopFromLocation(LocationItem loc, {int? plannedDurationMin}) {
    final dur = plannedDurationMin ?? loc.suggestedDurationMin;
    _stops.add(
      TripStop(
        location: loc,
        plannedDurationMin: dur,
        etaHHMM: _startHHMM, // placeholder; will be recomputed below
      ),
    );
    _recomputeEtas();
    notifyListeners();
  }

  /// Remove stop at [index].
  void removeStopAt(int index) {
    if (index < 0 || index >= _stops.length) return;
    _stops.removeAt(index);
    _recomputeEtas();
    notifyListeners();
  }

  /// Change the planned duration of a given [stop] by [deltaMin] minutes.
  void changeDuration(TripStop stop, int deltaMin) {
    final i = _stops.indexOf(stop);
    if (i == -1) return;
    final newDur = (_stops[i].plannedDurationMin + deltaMin).clamp(10, 360);
    _stops[i] = _stops[i].copyWith(plannedDurationMin: newDur);
    _recomputeEtas();
    notifyListeners();
  }

  /// Move stop up by one (swap with previous).
  void moveStopUp(int index) {
    if (index <= 0 || index >= _stops.length) return;
    final tmp = _stops[index - 1];
    _stops[index - 1] = _stops[index];
    _stops[index] = tmp;
    _recomputeEtas();
    notifyListeners();
  }

  /// Move stop down by one (swap with next).
  void moveStopDown(int index) {
    if (index < 0 || index >= _stops.length - 1) return;
    final tmp = _stops[index + 1];
    _stops[index + 1] = _stops[index];
    _stops[index] = tmp;
    _recomputeEtas();
    notifyListeners();
  }

  /// Clear current working plan (optional helper).
  void clearWorkingPlan() {
    _stops.clear();
    _startHHMM = '08:00';
    _bufferMin = 15;
    notifyListeners();
  }

  // ---------- Multi-day trip methods ----------

  /// Initialize a multi-day trip
  void initializeMultiDayTrip({
    required DateTime startDate,
    required String startTime,
    required int totalDays,
  }) {
    _tripStartDate = startDate;
    _totalDays = totalDays;
    _startHHMM = startTime;

    // Initialize daily start and end times
    _dailyStartTimes.clear();
    _dailyEndTimes.clear();
    for (int day = 1; day <= totalDays; day++) {
      _dailyStartTimes[day] = startTime;
      _dailyEndTimes[day] = '18:00'; // Default end time
    }

    // Initialize daily stops
    _dailyStops.clear();
    for (int day = 1; day <= totalDays; day++) {
      _dailyStops[day] = [];
    }

    notifyListeners();
  }

  /// Add location to specific day
  void addLocationToDay(int day, LocationItem location,
      {int? plannedDurationMin}) {
    if (day < 1 || day > _totalDays) return;

    final duration = plannedDurationMin ?? location.suggestedDurationMin;
    final stops = _dailyStops[day] ?? [];

    stops.add(TripStop(
      location: location,
      plannedDurationMin: duration,
      etaHHMM: _dailyStartTimes[day] ?? '08:00',
    ));

    _dailyStops[day] = stops;
    _recomputeDailyEtas(day);
    notifyListeners();
  }

  /// Get stops for a specific day
  List<TripStop> getStopsForDay(int day) {
    return _dailyStops[day] ?? [];
  }

  /// Set start time for a specific day
  void setDayStartTime(int day, String startTime) {
    if (day < 1 || day > _totalDays) return;

    _dailyStartTimes[day] = startTime;
    _recomputeDailyEtas(day);
    notifyListeners();
  }

  /// Set end time for a specific day
  void setDayEndTime(int day, String endTime) {
    if (day < 1 || day > _totalDays) return;

    _dailyEndTimes[day] = endTime;
    notifyListeners();
  }

  /// Optimize itinerary for a specific day
  void optimizeDayItinerary(int day) {
    final stops = _dailyStops[day];
    if (stops == null || stops.isEmpty) return;

    // Extract locations and optimize
    final locations = stops.map((s) => s.location).toList();
    final optimizedLocations = ItineraryOptimizer.optimizeItinerary(locations);

    // Create new optimized schedule
    final startTime = _dailyStartTimes[day] ?? '08:00';
    final schedule = ItineraryOptimizer.createDailySchedule(
      locations: optimizedLocations,
      startTime: startTime,
      bufferMinutes: _bufferMin,
    );

    // Update stops with optimized times
    final newStops = <TripStop>[];
    for (int i = 0; i < schedule.length; i++) {
      final scheduleItem = schedule[i];
      final originalStop = stops.firstWhere(
        (s) => s.location.id == scheduleItem.location.id,
      );

      newStops.add(originalStop.copyWith(
        etaHHMM: scheduleItem.arrivalTime,
        plannedDurationMin: scheduleItem.visitDuration,
      ));
    }

    _dailyStops[day] = newStops;
    notifyListeners();
  }

  /// Get travel duration between two locations
  int getTravelDuration(LocationItem from, LocationItem to) {
    return TravelDurationService.calculateTravelDuration(from, to);
  }

  /// Get total duration for a specific day
  int getDayTotalDuration(int day) {
    final stops = _dailyStops[day];
    if (stops == null || stops.isEmpty) return 0;

    final firstArrival = hhmmToMin(stops.first.etaHHMM);
    final lastDeparture =
        hhmmToMin(stops.last.etaHHMM) + stops.last.plannedDurationMin;

    return lastDeparture - firstArrival;
  }

  /// Get optimization suggestions for a day
  List<String> getDayOptimizationSuggestions(int day) {
    final stops = _dailyStops[day];
    if (stops == null || stops.isEmpty) return [];

    final locations = stops.map((s) => s.location).toList();
    final schedule = ItineraryOptimizer.createDailySchedule(
      locations: locations,
      startTime: _dailyStartTimes[day] ?? '08:00',
      bufferMinutes: _bufferMin,
    );

    return ItineraryOptimizer.getOptimizationSuggestions(schedule);
  }

  /// Recompute ETAs for a specific day
  void _recomputeDailyEtas(int day) {
    final stops = _dailyStops[day];
    if (stops == null || stops.isEmpty) return;

    final startTime = _dailyStartTimes[day] ?? '08:00';
    var cursor = hhmmToMin(startTime);

    for (int i = 0; i < stops.length; i++) {
      final eta = minToHHMM(cursor);
      stops[i] = stops[i].copyWith(etaHHMM: eta);

      cursor += stops[i].plannedDurationMin;
      if (i < stops.length - 1) {
        cursor += _bufferMin;
      }
    }
  }

  // ---------- Save as Trip (snapshot) ----------

  /// Finalize the current working plan to a saved [Trip].
  /// Returns null if there are no stops.
  Trip? createTrip({required Group group, required DateTime date}) {
    if (_stops.isEmpty) return null;

    // Build a new Trip snapshot
    final trip = Trip(
      startHHMM: _startHHMM,
      bufferMin: _bufferMin,
      stops: _stops
          .map(
            (s) => TripStop(
              location: s.location,
              plannedDurationMin: s.plannedDurationMin,
              etaHHMM: s.etaHHMM,
            ),
          )
          .toList(growable: false),
    );

    // Compute ETAs on the snapshot too (just in case)
    trip.recomputeEtas();

    _currentTrip = trip;
    notifyListeners();
    return _currentTrip;
  }

  // ---------- Internal ETA computation ----------

  void _recomputeEtas() {
    // Walk through stops: first ETA = start,
    // then each next = previous end + buffer
    var cursor = hhmmToMin(_startHHMM);
    for (var i = 0; i < _stops.length; i++) {
      // assign ETA for this stop
      final eta = minToHHMM(cursor);
      final s = _stops[i];
      _stops[i] = s.copyWith(etaHHMM: eta);
      // advance cursor = eta + duration + buffer
      cursor += s.plannedDurationMin;
      if (i < _stops.length - 1) {
        cursor += _bufferMin;
      }
    }
  }

  // ---------- Additional methods for build schedule page ----------

  /// Pick a new end time (HH:MM)
  void pickEnd(String hhmm) {
    _dailyEndTimes[1] = hhmm;
    notifyListeners();
  }

  /// Set trip duration in days
  void setTripDuration(int days) {
    _totalDays = days.clamp(1, 14);

    // Initialize daily times if not set
    for (int day = 1; day <= _totalDays; day++) {
      _dailyStartTimes[day] ??= '08:00';
      _dailyEndTimes[day] ??= '18:00';
      _dailyStops[day] ??= [];
    }

    notifyListeners();
  }

  /// Set trip start date
  void setTripStartDate(DateTime date) {
    _tripStartDate = date;
    notifyListeners();
  }

  /// Set current day index
  void setCurrentDay(int dayIndex) {
    // For now, this is a placeholder since we're showing day 1
    notifyListeners();
  }

  /// Set meal time preferences
  void setIncludeBreakfast(bool include) {
    _includeBreakfast = include;
    notifyListeners();
  }

  void setIncludeLunch(bool include) {
    _includeLunch = include;
    notifyListeners();
  }

  void setIncludeDinner(bool include) {
    _includeDinner = include;
    notifyListeners();
  }
}
