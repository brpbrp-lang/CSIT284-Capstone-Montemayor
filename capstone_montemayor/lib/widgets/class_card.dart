import 'package:flutter/material.dart';
import '../models/class_session.dart';
import 'class_details_sheet.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final bool isOngoing;
  final bool isDone;

  const ClassCard({
    super.key,
    required this.session,
    this.isOngoing = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isOngoing ? 2 : 0,
      color: isOngoing
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => ClassDetailsSheet.show(context, session),
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Badge(
              label: Text(session.courseCode),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            if (isOngoing)
              const Chip(
                label: Text('Ongoing'),
                visualDensity: VisualDensity.compact,
              )
            else if (isDone)
              const Text(
                'Done',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              session.courseTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(session.formattedTime),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.room_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${session.room} • ${session.instructor}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}