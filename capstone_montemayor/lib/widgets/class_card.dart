import 'package:flutter/material.dart';
import '../models/class_session.dart';
import '../theme/subject_colors.dart';
import 'class_details_sheet.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final bool isOngoing;
  final bool isDone;
  final bool compact;

  const ClassCard({
    super.key,
    required this.session,
    this.isOngoing = false,
    this.isDone = false,
    this.compact = false,
  });

  int get _durationMinutes =>
      (session.endTotalMinutes - session.startTotalMinutes).clamp(0, 600);

  String get _durationLabel {
    final mins = _durationMinutes;
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m == 0 ? '${h}h' : '${h}h ${m}m';
    }
    return '$mins min';
  }

  @override
  Widget build(BuildContext context) {
    final subjectTheme = SubjectColors.getTheme(
      session.courseCode,
      isOverload: session.isOverload,
    );

    final accentColor = isDone ? AppPalette.inkMuted : subjectTheme.primary;
    final titleColor =
        isDone ? AppPalette.inkMuted : AppPalette.inkWhite;

    if (compact) {
      return _buildCompactCard(context, subjectTheme, accentColor, titleColor);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => ClassDetailsSheet.show(context, session),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.cardDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOngoing
                  ? AppPalette.electricBlue
                  : AppPalette.borderSubtle,
              width: isOngoing ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon badge + Course code pill + Status badge
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      subjectTheme.icon,
                      size: 20,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppPalette.cardElevated,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          session.courseCode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(isOngoing: isOngoing, isDone: isDone),
                ],
              ),
              const SizedBox(height: 14),

              // Course Title
              Text(
                session.courseTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Time & Room row + Circular arrow button
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppPalette.inkMuted,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '${session.formattedTime} · $_durationLabel',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppPalette.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppPalette.inkMuted,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '${session.room} · ${session.instructor}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppPalette.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppPalette.cardElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.north_east_rounded,
                      size: 17,
                      color: AppPalette.inkWhite,
                    ),
                  ),
                ],
              ),
              if (session.statusNote != null &&
                  session.statusNote!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.cardElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: accentColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          session.statusNote!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.inkWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    SubjectTheme subjectTheme,
    Color accentColor,
    Color titleColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ClassDetailsSheet.show(context, session),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: AppPalette.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOngoing
                  ? AppPalette.electricBlue
                  : AppPalette.borderSubtle,
              width: isOngoing ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  subjectTheme.icon,
                  size: 18,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.courseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${session.formattedTime} · ${session.room}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isDone)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppPalette.emeraldGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppPalette.inkDark,
                  ),
                )
              else if (isOngoing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.flameOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.north_east_rounded,
                  size: 16,
                  color: AppPalette.inkMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOngoing;
  final bool isDone;

  const _StatusBadge({required this.isOngoing, required this.isDone});

  @override
  Widget build(BuildContext context) {
    if (isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppPalette.flameOrange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded,
                size: 13, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'ONGOING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    if (isDone) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppPalette.emeraldGreen.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 13, color: AppPalette.emeraldGreen),
            SizedBox(width: 4),
            Text(
              'DONE',
              style: TextStyle(
                color: AppPalette.emeraldGreen,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppPalette.electricBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'UPCOMING',
        style: TextStyle(
          color: AppPalette.electricBlue,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
