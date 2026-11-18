import 'package:flutter/material.dart';
import '../models/class_session.dart';
import 'class_details_sheet.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final bool isOngoing;
  final bool isDone;
  final bool isMyClass; // For teachers to see their assigned class

  const ClassCard({
    super.key,
    required this.session,
    this.isOngoing = false,
    this.isDone = false,
    this.isMyClass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isOngoing ? 2 : 0,
      color: isOngoing
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => ClassDetailsSheet.show(context, session),
        contentPadding: const EdgeInsets.all(16),
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Badge(
              label: Text(session.courseCode),
              backgroundColor: theme.colorScheme.primary,
            ),
            if (session.isOverload)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 12, color: Colors.amber.shade900),
                    const SizedBox(width: 4),
                    Text(
                      'Overload Unit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            if (isMyClass)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'My Handled Class',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
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
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              session.courseTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(session.formattedTime)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.room_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${session.room} • ${session.instructor}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (session.statusNote != null && session.statusNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign_outlined, size: 16, color: Colors.orange.shade900),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        session.statusNote!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
