import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import 'add_edit_class_sheet.dart';

class ClassDetailsSheet extends StatelessWidget {
  final ClassSession session;

  const ClassDetailsSheet({super.key, required this.session});

  static void show(BuildContext context, ClassSession session) {
    final scheduleProvider = ScheduleScope.of(context);
    final authProvider = AuthScope.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AuthScope(
        notifier: authProvider,
        child: ScheduleScope(
          notifier: scheduleProvider,
          child: ClassDetailsSheet(session: session),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Drop Overload Subject?'),
        content: Text(
          'Are you sure you want to remove "${session.courseCode} - ${session.courseTitle}" from your schedule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx); // close dialog
              Navigator.pop(context); // close bottom sheet
              ScheduleScope.of(context).deleteClass(session.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Overload subject dropped.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Drop Subject'),
          ),
        ],
      ),
    );
  }

  void _showTeacherNoticeDialog(BuildContext context) {
    final roomCtrl = TextEditingController(text: session.room);
    final noteCtrl = TextEditingController(text: session.statusNote ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Update ${session.courseCode} for BSIT 3-A'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roomCtrl,
              decoration: const InputDecoration(
                labelText: 'Room / Venue',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Teacher Notice / Announcement',
                hintText: 'e.g. Moved to Lab 201 today. Bring laptops.',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updated = session.copyWith(
                room: roomCtrl.text.trim(),
                statusNote: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
              );
              ScheduleScope.of(context).updateClass(updated);
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Section schedule announcement updated!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save & Post Notice'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final isTeacher = auth.isTeacher;
    final isStudent = auth.isStudent;

    final now = DateTime.now();
    final todayName = DateFormat('EEEE').format(now);
    final isToday = session.dayOfWeek.toLowerCase() == todayName.toLowerCase();
    final currentMinutes = now.hour * 60 + now.minute;

    final isOngoing = isToday &&
        currentMinutes >= session.startTotalMinutes &&
        currentMinutes <= session.endTotalMinutes;
    final isDone = isToday && currentMinutes > session.endTotalMinutes;

    final durationMinutes = session.endTotalMinutes - session.startTotalMinutes;
    final durationHours = durationMinutes ~/ 60;
    final durationRemMinutes = durationMinutes % 60;
    final durationText = durationHours > 0
        ? (durationRemMinutes > 0
            ? '${durationHours}h ${durationRemMinutes}m'
            : '${durationHours}h')
        : '${durationRemMinutes}m';

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (!isToday) {
      statusText = 'Scheduled on ${session.dayOfWeek}';
      statusColor = Theme.of(context).colorScheme.outline;
      statusIcon = Icons.calendar_today_outlined;
    } else if (isOngoing) {
      final remaining = session.endTotalMinutes - currentMinutes;
      statusText = 'Ongoing ($remaining min left)';
      statusColor = Colors.green;
      statusIcon = Icons.timelapse;
    } else if (isDone) {
      statusText = 'Finished for today';
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle_outline;
    } else {
      final untilStart = session.startTotalMinutes - currentMinutes;
      statusText = untilStart > 60
          ? 'Starts in ${untilStart ~/ 60}h ${untilStart % 60}m'
          : 'Starts in $untilStart min';
      statusColor = Theme.of(context).colorScheme.primary;
      statusIcon = Icons.schedule;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course code and status chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.courseCode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (session.isOverload)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Text(
                    'Overload',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Official Block (BSIT 3-A)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Course title
          Text(
            session.courseTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Teacher announcement box if present
          if (session.statusNote != null && session.statusNote!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.campaign, color: Colors.orange.shade900, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notice from ${session.instructor}:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.statusNote!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Divider(),
          const SizedBox(height: 12),

          // Detail Tiles
          _DetailRow(
            icon: Icons.access_time_rounded,
            title: 'Schedule & Duration',
            subtitle: '${session.dayOfWeek} • ${session.formattedTime} ($durationText)',
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.room_outlined,
            title: 'Room / Venue',
            subtitle: session.room,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.person_outline_rounded,
            title: 'Instructor',
            subtitle: session.instructor,
          ),
          const SizedBox(height: 20),

          // Role-specific action buttons
          if (isTeacher) ...[
            // Teacher can post room changes or class notices
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showTeacherNoticeDialog(context),
                icon: const Icon(Icons.edit_note, size: 20),
                label: const Text('Update Room or Post Notice'),
              ),
            ),
          ] else if (isStudent && session.isOverload) ...[
            // Student can edit or drop ONLY their overload subjects
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      AddEditClassSheet.show(context, session: session);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Overload'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Drop Subject'),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Official Section Class: student sees protected status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                'Fixed Official Schedule for BSIT 3-A',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
