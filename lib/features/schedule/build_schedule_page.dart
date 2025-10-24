import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../state/plan_provider.dart';
import '../../state/trip_provider.dart';
import '../../core/models/trip.dart';
import '../../core/models/location.dart';
import '../../widgets/animated_gradient_scaffold.dart';

class BuildSchedulePage extends StatelessWidget {
  const BuildSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripProvider>();
    final plan = context.watch<PlanProvider>();
    final cs = Theme.of(context).colorScheme;

    final stops = trips.stops;
    final start = trips.startHHMM;
    final buffer = trips.bufferMin;

    final totalMinutes = _computeTotalMinutes(
      startHHMM: start,
      bufferMin: buffer,
      stops: stops,
    );

    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Build Schedule'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1D29),
              const Color(0xFF2D1B69),
              const Color(0xFF11998E),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              20, 10, 20, MediaQuery.of(context).padding.bottom + 120),
          children: [
            // Day Selection Header
            _buildDayHeader(context),
            const SizedBox(height: 20),

            // Enhanced Start Time & Buffer Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: cs.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Schedule Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeSelector(
                          context,
                          'Start Time',
                          start,
                          Icons.access_time,
                          () async {
                            final now = TimeOfDay.now();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _toTimeOfDay(start) ?? now,
                            );
                            if (picked != null && context.mounted) {
                              final hh = picked.hour.toString().padLeft(2, '0');
                              final mm =
                                  picked.minute.toString().padLeft(2, '0');
                              context.read<TripProvider>().pickStart('$hh:$mm');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeSelector(
                          context,
                          'End Time',
                          trips.endHHMM,
                          Icons.schedule,
                          () async {
                            final now = TimeOfDay.now();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _toTimeOfDay(trips.endHHMM) ?? now,
                            );
                            if (picked != null && context.mounted) {
                              final hh = picked.hour.toString().padLeft(2, '0');
                              final mm =
                                  picked.minute.toString().padLeft(2, '0');
                              context.read<TripProvider>().pickEnd('$hh:$mm');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBufferSelector(context, buffer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMealTimeSelector(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Enhanced Stops List
            if (stops.isEmpty)
              _buildEmptySchedule(context)
            else
              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.route, color: cs.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Your Itinerary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stops.length} stops',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Auto-optimize button
                  if (stops.length > 1)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _autoOptimizeItinerary(context),
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: const Text('Auto-optimize order'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                      color: Colors.white.withOpacity(0.3)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  cs.primary,
                                  cs.primary.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _showOptimizationInfo(context),
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Info'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ...List.generate(stops.length, (i) {
                    final s = stops[i];
                    return _buildStopCard(context, s, i, stops.length);
                  }),
                ],
              ),

            const SizedBox(height: 24),

            // Enhanced Summary Card
            _buildSummaryCard(context, totalMinutes, plan),
          ],
        ),
      ),

      // Enhanced FAB
      fab: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              cs.primary,
              cs.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_location_alt_rounded),
          label: const Text('Add locations'),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.choose);
          },
        ),
      ),
    );
  }

  static TimeOfDay? _toTimeOfDay(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static int _computeTotalMinutes({
    required String startHHMM,
    required int bufferMin,
    required List<TripStop> stops,
  }) {
    if (stops.isEmpty) return 0;
    // Sum durations + buffers between them
    final dur = stops.fold<int>(0, (acc, s) => acc + s.plannedDurationMin);
    final buffers = bufferMin * (stops.length - 1);
    return dur + (buffers < 0 ? 0 : buffers);
  }

  static String _minutesToHrs(int total) {
    final h = total ~/ 60;
    final m = total % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  Widget _buildDayHeader(BuildContext context) {
    final trips = context.watch<TripProvider>();
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: cs.primary, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Duration',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${trips.tripDurationDays} day${trips.tripDurationDays > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showTripDurationDialog(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day Selector
          if (trips.tripDurationDays > 1) ...[
            Row(
              children: [
                Text(
                  'Current Day:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(trips.tripDurationDays, (index) {
                        final isSelected = trips.currentDayIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => trips.setCurrentDay(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primary.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? cs.primary
                                      : Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Day ${index + 1}',
                                style: TextStyle(
                                  color: isSelected ? cs.primary : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, String title, String time,
      IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBufferSelector(BuildContext context, int buffer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Buffer',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBufferButton(context, Icons.remove,
                  () => context.read<TripProvider>().changeBuffer(-5)),
              const SizedBox(width: 12),
              Text(
                '$buffer min',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              _buildBufferButton(context, Icons.add,
                  () => context.read<TripProvider>().changeBuffer(5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBufferButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
      ),
    );
  }

  Widget _buildStopCard(
      BuildContext context, TripStop stop, int index, int totalStops) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showStopDetails(context, stop, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Stop Number and Time
                    SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stop.etaHHMM,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'ETA',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Location Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.location.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pref ${stop.location.prefStart}–${stop.location.prefEnd} • ${stop.location.city ?? ''}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Duration Controls
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Duration: ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              _buildDurationButton(
                                  context,
                                  Icons.remove,
                                  () => context
                                      .read<TripProvider>()
                                      .changeDuration(stop, -5)),
                              Text(
                                '${stop.plannedDurationMin} min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              _buildDurationButton(
                                  context,
                                  Icons.add,
                                  () => context
                                      .read<TripProvider>()
                                      .changeDuration(stop, 5)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons
                    Column(
                      children: [
                        if (index > 0)
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up),
                            onPressed: () =>
                                context.read<TripProvider>().moveStopUp(index),
                            color: Colors.white70,
                          ),
                        if (index < totalStops - 1)
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: () => context
                                .read<TripProvider>()
                                .moveStopDown(index),
                            color: Colors.white70,
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              context.read<TripProvider>().removeStopAt(index),
                          color: Colors.red.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child:
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 14),
      ),
    );
  }

  Widget _buildEmptySchedule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.route_rounded,
              size: 64, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No stops yet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add locations to start building your perfect day',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.choose),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Add locations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, int totalMinutes, PlanProvider plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total time',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _minutesToHrs(totalMinutes),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                final trip = context.read<TripProvider>().createTrip(
                      group: plan.group,
                      date: DateTime.now(),
                    );
                if (trip == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add at least one location first.'),
                    ),
                  );
                  return;
                }
                Navigator.pushNamed(context, AppRoutes.overview);
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save schedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  void _showStopDetails(BuildContext context, TripStop stop, int index) {
    // Show detailed information about the stop
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stop.location.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ETA: ${stop.etaHHMM}'),
            Text('Duration: ${stop.plannedDurationMin} min'),
            Text(
                'Preferred time: ${stop.location.prefStart}–${stop.location.prefEnd}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _autoOptimizeItinerary(BuildContext context) {
    final tripProvider = context.read<TripProvider>();
    final stops = tripProvider.stops;

    if (stops.length < 2) return;

    // Extract locations from stops
    final locations = stops.map((s) => s.location).toList();

    // Optimize based on distance and preferred time
    final optimizedLocations = _optimizeByDistanceAndTime(locations);

    // Create new optimized stops
    final optimizedStops = <TripStop>[];
    for (int i = 0; i < optimizedLocations.length; i++) {
      final location = optimizedLocations[i];
      final originalStop =
          stops.firstWhere((s) => s.location.id == location.id);
      optimizedStops.add(originalStop);
    }

    // Clear current stops and add optimized ones
    tripProvider.clearWorkingPlan();
    for (final stop in optimizedStops) {
      tripProvider.addStopFromLocation(
        stop.location,
        plannedDurationMin: stop.plannedDurationMin,
      );
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Itinerary optimized! Locations reordered for better efficiency.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<LocationItem> _optimizeByDistanceAndTime(List<LocationItem> locations) {
    if (locations.length < 2) return locations;

    final optimized = <LocationItem>[];
    final remaining = List<LocationItem>.from(locations);

    // Start with the first location
    LocationItem? current = remaining.removeAt(0);
    optimized.add(current);

    while (remaining.isNotEmpty) {
      LocationItem? next;
      double bestScore = double.infinity;

      for (final candidate in remaining) {
        final distance = _calculateDistance(current!, candidate);
        final timeScore = _calculateTimeScore(current, candidate);

        // Priority: if distance > 400m, prioritize distance; otherwise prioritize time
        final score = distance > 400
            ? distance * 0.7 + timeScore * 0.3
            : timeScore * 0.7 + distance * 0.3;

        if (score < bestScore) {
          bestScore = score;
          next = candidate;
        }
      }

      if (next != null) {
        optimized.add(next);
        remaining.remove(next);
        current = next;
      }
    }

    return optimized;
  }

  double _calculateDistance(LocationItem from, LocationItem to) {
    // Simulate distance calculation (in production, use real coordinates)
    // For now, use a hash-based approximation
    final hash1 = from.name.hashCode.abs();
    final hash2 = to.name.hashCode.abs();
    return ((hash1 - hash2).abs() % 1000).toDouble(); // 0-1000m range
  }

  double _calculateTimeScore(LocationItem from, LocationItem to) {
    // Calculate time-based score based on preferred times
    final fromPrefStart = _parseTime(from.prefStart);
    final toPrefStart = _parseTime(to.prefStart);

    // Score based on how well the preferred times align
    final timeDiff = (toPrefStart - fromPrefStart).abs();
    return timeDiff.toDouble();
  }

  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  void _showOptimizationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Optimization Info'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How auto-optimization works:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
                '• If distance between locations > 400m: Prioritizes shorter distances'),
            SizedBox(height: 4),
            Text('• If distance ≤ 400m: Prioritizes preferred visit times'),
            SizedBox(height: 8),
            Text(
              'This helps minimize travel time while respecting when places are best visited.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimeSelector(BuildContext context) {
    final trips = context.watch<TripProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Meal Times',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMealToggle(context, 'Breakfast', trips.includeBreakfast,
                  (value) => trips.setIncludeBreakfast(value)),
              const SizedBox(width: 8),
              _buildMealToggle(context, 'Lunch', trips.includeLunch,
                  (value) => trips.setIncludeLunch(value)),
              const SizedBox(width: 8),
              _buildMealToggle(context, 'Dinner', trips.includeDinner,
                  (value) => trips.setIncludeDinner(value)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealToggle(BuildContext context, String meal, bool isEnabled,
      Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isEnabled
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          meal,
          style: TextStyle(
            color: isEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showTripDurationDialog(BuildContext context) {
    final trips = context.read<TripProvider>();
    int selectedDays = trips.tripDurationDays;
    DateTime selectedDate = trips.tripStartDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1D29),
          title: const Text(
            'Trip Duration',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Picker
              ListTile(
                leading:
                    const Icon(Icons.calendar_today, color: Colors.white70),
                title: const Text(
                  'Start Date',
                  style: TextStyle(color: Colors.white70),
                ),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Days Selector
              Row(
                children: [
                  const Text(
                    'Duration:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: selectedDays > 1
                              ? () => setState(() => selectedDays--)
                              : null,
                          icon: const Icon(Icons.remove, color: Colors.white70),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$selectedDays day${selectedDays > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: selectedDays < 14
                              ? () => setState(() => selectedDays++)
                              : null,
                          icon: const Icon(Icons.add, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                trips.setTripDuration(selectedDays);
                trips.setTripStartDate(selectedDate);
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
