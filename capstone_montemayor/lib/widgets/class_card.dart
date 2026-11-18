import 'package:flutter/material.dart';
import '../models/class_session.dart';
import '../theme/subject_colors.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subjectTheme = SubjectColors.getTheme(
      session.courseCode,
      isOverload: session.isOverload,
    );

    final durationMin = session.endTotalMinutes - session.startTotalMinutes;
    final durationHours = durationMin ~/ 60;
    final durationRemMin = durationMin % 60;
    final durationStr = durationHours > 0
        ? (durationRemMin > 0 ? '${durationHours}h ${durationRemMin}m' : '${durationHours}h')
        : '${durationRemMin}m';

    final cardBgColor = isDark
        ? (isOngoing
            ? subjectTheme.primary.withValues(alpha: 0.18)
            : theme.colorScheme.surfaceContainerLow)
        : (isOngoing
            ? subjectTheme.background
            : Colors.white);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOngoing
              ? subjectTheme.primary
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          width: isOngoing ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black26
                : (isOngoing
                    ? subjectTheme.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04)),
            blurRadius: isOngoing ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ClassDetailsSheet.show(context, session),
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subject color accent bar on left
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: subjectTheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top badges row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? subjectTheme.primary.withValues(alpha: 0.3)
                                    : subjectTheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: subjectTheme.primary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                session.courseCode,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : subjectTheme.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (session.isOverload)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Added',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            if (isOngoing)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle, size: 8, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ongoing',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (isDone)
                              const Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              Text(
                                durationStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Course title
                        Text(
                          session.courseTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                        ),
                        const SizedBox(height: 10),

                        // Time & Venue Row
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 15,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session.formattedTime,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                session.room,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Instructor line
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                session.instructor,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
