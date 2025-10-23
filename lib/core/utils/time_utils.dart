// lib/core/utils/time_utils.dart
import 'package:flutter/material.dart';

/// Convert "HH:MM" (24h) to minutes since midnight (0..1439).
/// Returns 480 (08:00) if parsing fails.
int hhmmToMin(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return 8 * 60; // fallback 08:00
  final h = int.tryParse(parts[0]) ?? 8;
  final m = int.tryParse(parts[1]) ?? 0;
  final total = h * 60 + m;
  // clamp to one day
  return total.clamp(0, 23 * 60 + 59);
}

/// Convert minutes since midnight (0..1439) to "HH:MM" (24h).
String minToHHMM(int minutes) {
  final t = minutes % (24 * 60);
  final h = t ~/ 60;
  final m = t % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// Add (or subtract) minutes to an "HH:MM" time, wraps within 24h.
String addMinutesHHMM(String hhmm, int delta) {
  final base = hhmmToMin(hhmm);
  final added = (base + delta) % (24 * 60);
  final normalized = added < 0 ? added + (24 * 60) : added;
  return minToHHMM(normalized);
}

/// Absolute difference between two "HH:MM" times in minutes (0..1439).
int diffMinutes(String a, String b) {
  final ma = hhmmToMin(a);
  final mb = hhmmToMin(b);
  return (ma - mb).abs();
}

/// Human-friendly duration formatting.
/// 0 -> "0 min", 45 -> "45 min", 60 -> "1h", 135 -> "2h 15m"
String formatDuration(int totalMin) {
  if (totalMin <= 0) return '0 min';
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  if (h == 0) return '${m} min';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

/// Simple time window within a single day, inclusive of start, exclusive of end.
class TimeRange {
  final int startMin; // minutes since midnight (0..1439)
  final int endMin; // minutes since midnight (0..1439)

  const TimeRange(this.startMin, this.endMin)
      : assert(startMin >= 0 && startMin <= 1439),
        assert(endMin >= 0 && endMin <= 1439);

  factory TimeRange.fromHHMM(String start, String end) =>
      TimeRange(hhmmToMin(start), hhmmToMin(end));

  /// e.g., "08:00–10:30"
  String get label => '${minToHHMM(startMin)}–${minToHHMM(endMin)}';

  /// True if ranges overlap at any minute.
  bool overlaps(TimeRange other) {
    // Treat as [start, end) intervals
    return startMin < other.endMin && other.startMin < endMin;
  }

  /// True if the given minute-of-day falls inside this range.
  bool containsMinute(int minuteOfDay) =>
      minuteOfDay >= startMin && minuteOfDay < endMin;

  /// Clamp a minute-of-day into this range (snap to nearest bound).
  int clampMinute(int minuteOfDay) {
    if (minuteOfDay < startMin) return startMin;
    if (minuteOfDay >= endMin) return endMin - 1;
    return minuteOfDay;
  }
}

/// Safe parse of "HH:MM" to TimeOfDay. Returns null if invalid.
TimeOfDay? toTimeOfDay(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return TimeOfDay(hour: h, minute: m);
}

/// Convert a TimeOfDay to "HH:MM" 24h string (e.g., 8:5 -> "08:05").
String fromTimeOfDay(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Extensions that help with arithmetic on TimeOfDay without dates.
extension TimeOfDayX on TimeOfDay {
  /// Minutes since midnight (0..1439)
  int get inMinutes => hour * 60 + minute;

  /// Returns a new TimeOfDay offset by [delta] minutes (wraps within 24h).
  TimeOfDay addMinutes(int delta) {
    final total = (inMinutes + delta) % (24 * 60);
    final norm = total < 0 ? total + 24 * 60 : total;
    return TimeOfDay(hour: norm ~/ 60, minute: norm % 60);
  }

  /// Difference in minutes to [other], absolute value (0..1439).
  int differenceAbs(TimeOfDay other) => (inMinutes - other.inMinutes).abs();

  /// Formats as "HH:MM".
  String get hhmm => fromTimeOfDay(this);
}
