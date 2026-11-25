import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../theme/subject_colors.dart';

class ClassDetailsSheet extends StatelessWidget {
  final ClassSession session;

  const ClassDetailsSheet({super.key, required this.session});

  static void show(BuildContext context, ClassSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppPalette.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ClassDetailsSheet(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        currentMinutes < session.endTotalMinutes;
    final isDone = isToday && currentMinutes >= session.endTotalMinutes;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppPalette.cardDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppPalette.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: subjectTheme.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          session.courseCode,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: subjectTheme.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isOngoing
                              ? AppPalette.flameOrange
                              : isDone
                                  ? AppPalette.emeraldGreen
                                      .withValues(alpha: 0.18)
                                  : AppPalette.electricBlue
                                      .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOngoing
                              ? 'ONGOING'
                              : isDone
                                  ? 'DONE'
                                  : isToday
                                      ? 'TODAY'
                                      : session.dayOfWeek.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isOngoing
                                ? Colors.white
                                : isDone
                                    ? AppPalette.emeraldGreen
                                    : AppPalette.electricBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.courseTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.inkWhite,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailTile(
              icon: Icons.calendar_today_rounded,
              label: 'Day & Time',
              value: '${session.dayOfWeek} · ${session.formattedTime}',
            ),
            const SizedBox(height: 10),
            _DetailTile(
              icon: Icons.location_on_outlined,
              label: 'Room',
              value: session.room,
            ),
            const SizedBox(height: 10),
            _DetailTile(
              icon: Icons.person_outline_rounded,
              label: 'Instructor',
              value: session.instructor,
            ),
            const SizedBox(height: 10),
            const _DetailTile(
              icon: Icons.notifications_active_outlined,
              label: 'Automated Reminder',
              value: '10 minutes before class starts',
            ),
            if (session.statusNote != null &&
                session.statusNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _DetailTile(
                icon: Icons.campaign_outlined,
                label: 'Note',
                value: session.statusNote!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppPalette.electricBlue.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppPalette.electricBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.inkMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.inkWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
