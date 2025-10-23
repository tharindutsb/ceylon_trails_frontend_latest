/// Trip model used by Build Schedule and Trip Overview screens.

import 'location.dart';

/// Convert minutes since midnight to HH:MM (24h).
String minToHHMM(int minutes) {
  var m = minutes % (24 * 60);
  if (m < 0) m += 24 * 60;
  final h = m ~/ 60;
  final min = m % 60;
  return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
}

/// Parse HH:MM to minutes since midnight
int hhmmToMin(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return h * 60 + m;
}

class TripStop {
  final LocationItem location;
  int plannedDurationMin;
  String etaHHMM; // computed ETA (arrival time)

  TripStop({
    required this.location,
    required this.plannedDurationMin,
    this.etaHHMM = '00:00',
  });

  Map<String, dynamic> toMap() => {
        'location': location.toMap(),
        'plannedDurationMin': plannedDurationMin,
        'etaHHMM': etaHHMM,
      };

  factory TripStop.fromMap(Map<String, dynamic> m) => TripStop(
        location:
            LocationItem.fromMap(Map<String, dynamic>.from(m['location'])),
        plannedDurationMin: (m['plannedDurationMin'] as num).toInt(),
        etaHHMM: m['etaHHMM'] as String? ?? '00:00',
      );

  TripStop copyWith({
    LocationItem? location,
    int? plannedDurationMin,
    String? etaHHMM,
  }) {
    return TripStop(
      location: location ?? this.location,
      plannedDurationMin: plannedDurationMin ?? this.plannedDurationMin,
      etaHHMM: etaHHMM ?? this.etaHHMM,
    );
  }
}

class Trip {
  /// Starting time, HH:MM (24h)
  String startHHMM;

  /// Buffer between places (walking/transport, minutes)
  int bufferMin;

  final List<TripStop> _stops;

  Trip({
    this.startHHMM = '08:00',
    this.bufferMin = 15,
    List<TripStop>? stops,
  }) : _stops = List<TripStop>.from(stops ?? const []);

  List<TripStop> get stops => _stops;

  // Mutations used by UI/Provider

  void addStop(LocationItem loc, {int plannedDurationMin = 70}) {
    _stops.add(TripStop(
      location: loc,
      plannedDurationMin: plannedDurationMin,
    ));
    recomputeEtas();
  }

  void insertStop(int index, LocationItem loc, {int plannedDurationMin = 70}) {
    _stops.insert(
      index,
      TripStop(location: loc, plannedDurationMin: plannedDurationMin),
    );
    recomputeEtas();
  }

  void removeStopAt(int index) {
    if (index >= 0 && index < _stops.length) {
      _stops.removeAt(index);
      recomputeEtas();
    }
  }

  void changeDuration(TripStop s, int deltaMin) {
    s.plannedDurationMin = (s.plannedDurationMin + deltaMin).clamp(10, 360);
    recomputeEtas();
  }

  void changeBuffer(int deltaMin) {
    bufferMin = (bufferMin + deltaMin).clamp(0, 90);
    recomputeEtas();
  }

  void moveStop(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _stops.length) return;
    if (newIndex < 0 || newIndex >= _stops.length) return;
    final s = _stops.removeAt(oldIndex);
    _stops.insert(newIndex, s);
    recomputeEtas();
  }

  // ETA computation
  void recomputeEtas() {
    var t = hhmmToMin(startHHMM);
    for (final s in _stops) {
      s.etaHHMM = minToHHMM(t);
      t += s.plannedDurationMin + bufferMin;
    }
  }

  Map<String, dynamic> toMap() => {
        'startHHMM': startHHMM,
        'bufferMin': bufferMin,
        'stops': _stops.map((e) => e.toMap()).toList(),
      };

  factory Trip.fromMap(Map<String, dynamic> m) => Trip(
        startHHMM: m['startHHMM'] as String? ?? '08:00',
        bufferMin: (m['bufferMin'] as num?)?.toInt() ?? 15,
        stops: (m['stops'] as List<dynamic>? ?? const [])
            .map((e) => TripStop.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
