import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/class_details_sheet.dart';

class WeeklyScreen extends StatelessWidget {
  final List<ClassSession>? allClasses;

  const WeeklyScreen({super.key, this.allClasses});

  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final isTeacher = auth.isTeacher;
    final teacherName = auth.currentUser?.name ?? '';

    final todayName = DateFormat('EEEE').format(DateTime.now());
    final initialIndex = _days.indexOf(todayName);

    final sourceClasses =
        allClasses ?? ScheduleScope.of(context).classes;

    return DefaultTabController(
      length: _days.length,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _days.map((d) => Tab(text: d.substring(0, 3))).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: _days.map((day) {
                final dayClasses = sourceClasses
                    .where((c) => c.dayOfWeek.toLowerCase() == day.toLowerCase())
                    .toList()
                  ..sort((a, b) =>
                      a.startTotalMinutes.compareTo(b.startTotalMinutes));

                if (dayClasses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 40,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No classes on $day',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayClasses.length,
                  itemBuilder: (context, index) {
                    final item = dayClasses[index];
                    final avatarCode = item.courseCode.length >= 2
                        ? item.courseCode.substring(0, 2)
                        : item.courseCode;
                    final isMyClass = isTeacher &&
                        item.instructor.toLowerCase().contains(teacherName.toLowerCase());

                    return Card.outlined(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        onTap: () => ClassDetailsSheet.show(context, item),
                        leading: CircleAvatar(
                          backgroundColor: item.isOverload
                              ? Colors.amber.shade200
                              : (isMyClass
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : null),
                          child: Text(avatarCode),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.courseCode} - ${item.courseTitle}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (item.isOverload)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Overload',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${item.formattedTime}\n${item.room} • ${item.instructor}',
                            ),
                            if (item.statusNote != null && item.statusNote!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '📢 ${item.statusNote}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
