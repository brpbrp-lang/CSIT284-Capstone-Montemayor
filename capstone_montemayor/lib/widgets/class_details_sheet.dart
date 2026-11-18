import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../providers/schedule_provider.dart';
import '../theme/subject_colors.dart';
import 'add_edit_class_sheet.dart';

class ClassDetailsSheet extends StatelessWidget {
  final ClassSession session;

  const ClassDetailsSheet({super.key, required this.session});

  static void show(BuildContext context, ClassSession session) {
    final scheduleProvider = ScheduleScope.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ScheduleScope(
        notifier: scheduleProvider,
        child: ClassDetailsSheet(session: session),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Subject?'),
        content: Text(
          'Are you sure you want to drop "${session.courseCode} - ${session.courseTitle}" from your schedule?',
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
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
              ScheduleScope.of(context).deleteClass(session.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subject removed.'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectTheme = SubjectColors.getTheme(
      session.courseCode,
      isOverload: session.isOverload,
    );

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
      statusColor = subjectTheme.primary;
      statusIcon = Icons.schedule;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 4,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Subject Signature Gradient
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subjectTheme.primary,
                  subjectTheme.primary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        session.courseCode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (session.isOverload)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Added Subject',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'BSIT 3-A Block',
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  session.courseTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Live Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  durationText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Detail Tiles with aesthetic soft circles
          _DetailRow(
            icon: Icons.access_time_rounded,
            title: 'Schedule & Timing',
            subtitle: '${session.dayOfWeek} • ${session.formattedTime}',
            accentColor: subjectTheme.primary,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.location_on_outlined,
            title: 'Classroom / Lab',
            subtitle: session.room,
            accentColor: subjectTheme.primary,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.person_outline_rounded,
            title: 'Professor / Instructor',
            subtitle: session.instructor,
            accentColor: subjectTheme.primary,
          ),
          const SizedBox(height: 22),

          // Action buttons: If overload unit -> allow edit/drop. If official -> lock notice.
          if (session.isOverload) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      AddEditClassSheet.show(context, session: session);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Subject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Drop Subject'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Official BSIT 3-A Curriculum Subject',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
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
  final Color accentColor;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: accentColor.withValues(alpha: 0.12),
          child: Icon(icon, size: 20, color: accentColor),
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
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
