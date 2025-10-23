import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/trip_provider.dart';
import '../../core/router/app_router.dart';
import '../../widgets/animated_gradient_scaffold.dart';

class TripDurationPage extends StatefulWidget {
  const TripDurationPage({super.key});

  @override
  State<TripDurationPage> createState() => _TripDurationPageState();
}

class _TripDurationPageState extends State<TripDurationPage> {
  int selectedDays = 1;
  DateTime startDate = DateTime.now();
  String startTime = '08:00';

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientScaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            // Trip Duration Selection
            _buildTripDurationCard(),
            const SizedBox(height: 24),

            // Start Date Selection
            _buildStartDateCard(),
            const SizedBox(height: 24),

            // Start Time Selection
            _buildStartTimeCard(),
            const SizedBox(height: 32),

            // Continue Button
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDurationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Icon(Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Trip Duration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'How many days will you be traveling?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(7, (index) {
              final days = index + 1;
              final isSelected = selectedDays == days;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedDays = days),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$days',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days == 1 ? 'Day' : 'Days',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStartDateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Icon(Icons.event,
                  color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Start Date',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null && mounted) {
                setState(() => startDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month,
                      color: Colors.white.withOpacity(0.8)),
                  const SizedBox(width: 12),
                  Text(
                    '${_getMonthName(startDate.month)} ${startDate.day}, ${startDate.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down,
                      color: Colors.white.withOpacity(0.8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTimeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Icon(Icons.access_time,
                  color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Start Time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final currentTime = TimeOfDay(
                hour: int.parse(startTime.split(':')[0]),
                minute: int.parse(startTime.split(':')[1]),
              );
              final picked = await showTimePicker(
                context: context,
                initialTime: currentTime,
              );
              if (picked != null && mounted) {
                setState(() {
                  startTime =
                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white.withOpacity(0.8)),
                  const SizedBox(width: 12),
                  Text(
                    startTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down,
                      color: Colors.white.withOpacity(0.8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Initialize multi-day trip
          final tripProvider = context.read<TripProvider>();
          tripProvider.initializeMultiDayTrip(
            startDate: startDate,
            startTime: startTime,
            totalDays: selectedDays,
          );

          // Navigate to location selection
          Navigator.pushNamed(context, AppRoutes.choose);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Continue to Location Selection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
