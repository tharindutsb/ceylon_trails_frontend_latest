// lib/state/plan_provider.dart
import 'package:flutter/foundation.dart';

import '../core/models/group.dart';
import '../core/models/person.dart';
import '../core/models/location.dart';

/// Holds “planning” context before a trip is finalized:
/// - the group (people + optional planned start)
/// - the currently selected location (from Choose → Review)
/// - light, demo-friendly “prediction” cache
class PlanProvider extends ChangeNotifier {
  PlanProvider();

  // The traveler group (people, optional planned start time).
  Group _group = Group();
  Group get group => _group;

  // Location currently selected on Choose/Review screens
  LocationItem? _selected;
  LocationItem? get selected => _selected;

  // --- Simple "prediction" cache used by Review screen (demo logic) ---
  bool? isSuitable;
  double? probaSuitable; // 0..1
  String? bestWindow; // e.g. Morning / Midday / Afternoon / Evening
  double? durationMin; // recommended duration in minutes

  // --- Group editing ---

  void addPerson(Person p) {
    _group.people.add(p);
    notifyListeners();
  }

  void updatePerson(Person p) {
    final i = _group.people.indexWhere((e) => e.id == p.id);
    if (i != -1) {
      _group.people[i] = p;
      notifyListeners();
    }
  }

  void removePerson(String id) {
    _group.people.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setPlannedStart(String? hhmm) {
    _group.plannedStartHHMM = hhmm;
    notifyListeners();
  }

  // --- Selection / review ---

  void setSelected(LocationItem? loc) {
    _selected = loc;
    notifyListeners();
  }

  void clearSelection() {
    _selected = null;
    notifyListeners();
  }

  /// Store (cache) the last prediction so Review → Build can display
  /// the same numbers without recomputing.
  void setPrediction({
    bool? suitable,
    double? probability,
    String? window,
    double? recDurationMin,
  }) {
    isSuitable = suitable;
    probaSuitable = probability;
    bestWindow = window;
    durationMin = recDurationMin;
    notifyListeners();
  }

  // Convenience: planned start (group) with a default for the UI
  String get plannedStartOrDefault => _group.plannedStartHHMM ?? '08:00';

  // Reset everything (useful for a fresh demo)
  void reset() {
    _group = Group();
    _selected = null;
    isSuitable = null;
    probaSuitable = null;
    bestWindow = null;
    durationMin = null;
    notifyListeners();
  }
}
