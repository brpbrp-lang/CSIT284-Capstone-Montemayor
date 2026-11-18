import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../providers/schedule_provider.dart';
import '../widgets/class_card.dart';

class WeeklyScreen extends StatefulWidget {
  final List<ClassSession>? allClasses;

  const WeeklyScreen({super.key, this.allClasses});

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showWeekends = true;

  static const List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<String> get _activeDays => _showWeekends ? _allDays : _allDays.take(5).toList();

  @override
  void initState() {
    super.initState();
    final todayName = DateFormat('EEEE').format(DateTime.now());
    final initialIndex = _allDays.indexOf(todayName);
    _tabController = TabController(
      length: _activeDays.length,
      vsync: this,
      initialIndex: initialIndex >= 0 && initialIndex < _activeDays.length ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleWeekends() {
    setState(() {
      _showWeekends = !_showWeekends;
      final currentIdx = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: _activeDays.length,
        vsync: this,
        initialIndex: currentIdx < _activeDays.length ? currentIdx : 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceClasses = widget.allClasses ?? ScheduleScope.of(context).classes;

    return Column(
      children: [
        // Top Toolbar: 5-Day / 7-Day filter button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
              ),
              InkWell(
                onTap: _toggleWeekends,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showWeekends ? Icons.view_week_rounded : Icons.calendar_view_day_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showWeekends ? '7-Day View' : '5-Day View',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // iOS-style Horizontal Day Capsule Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: 48,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: _activeDays.map((day) {
              final count = sourceClasses
                  .where((c) => c.dayOfWeek.toLowerCase() == day.toLowerCase())
                  .length;
              return Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(day.substring(0, 3)),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Tab Views with Subject Cards
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _activeDays.map((day) {
              final dayClasses = sourceClasses
                  .where((c) => c.dayOfWeek.toLowerCase() == day.toLowerCase())
                  .toList()
                ..sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));

              if (dayClasses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wb_sunny_outlined,
                          size: 38,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No classes on $day',
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Free day! Use this time to study or rest.',
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: dayClasses.length,
                itemBuilder: (context, index) {
                  final item = dayClasses[index];
                  return ClassCard(session: item);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
