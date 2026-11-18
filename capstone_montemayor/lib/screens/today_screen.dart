import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../providers/schedule_provider.dart';
import '../widgets/class_card.dart';

class TodayScreen extends StatefulWidget {
  final List<ClassSession>? allClasses;

  const TodayScreen({super.key, this.allClasses});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh every 30 seconds to update Upcoming / Ongoing / Done statuses
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayName = DateFormat('EEEE').format(now);
    final dateSubtitle = DateFormat('MMMM d, y').format(now);
    final timeFormatted = DateFormat('h:mm a').format(now);
    final currentMinutes = now.hour * 60 + now.minute;

    final sourceClasses =
        widget.allClasses ?? ScheduleScope.of(context).classes;

    final todaysClasses = sourceClasses
        .where((c) => c.dayOfWeek.toLowerCase() == todayName.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todayName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      dateSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todaysClasses.isEmpty)
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.weekend_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No classes scheduled today!',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text('Switch to the Weekly tab or tap "+" to add a class.'),
                  ],
                ),
              ),
            )
          else
            ...todaysClasses.map((session) {
              final isOngoing = currentMinutes >= session.startTotalMinutes &&
                  currentMinutes <= session.endTotalMinutes;
              final isDone = currentMinutes > session.endTotalMinutes;

              return ClassCard(
                session: session,
                isOngoing: isOngoing,
                isDone: isDone,
              );
            }),
        ],
      ),
    );
  }
}
