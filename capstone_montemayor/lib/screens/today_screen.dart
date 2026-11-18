import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../providers/schedule_provider.dart';
import '../theme/subject_colors.dart';
import '../widgets/class_card.dart';
import '../widgets/class_details_sheet.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    // Find currently active class or the immediate next class
    ClassSession? ongoingSession;
    ClassSession? upNextSession;

    for (final s in todaysClasses) {
      if (currentMinutes >= s.startTotalMinutes && currentMinutes <= s.endTotalMinutes) {
        ongoingSession = s;
        break;
      } else if (currentMinutes < s.startTotalMinutes) {
        upNextSession ??= s;
      }
    }

    final heroSession = ongoingSession ?? upNextSession;
    final isHeroOngoing = ongoingSession != null;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header Date Row
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
                      style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF272733) : const Color(0xFFEFF2FE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : const Color(0xFFDBE4FE),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      timeFormatted,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // "Up Next" / "Happening Now" Hero Banner (Timetable App signature feature)
          if (heroSession != null) ...[
            _HeroScheduleCard(
              session: heroSession,
              isOngoing: isHeroOngoing,
              currentMinutes: currentMinutes,
            ),
            const SizedBox(height: 20),
          ],

          // Section Title & Class Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Schedule Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${todaysClasses.length} ${todaysClasses.length == 1 ? "Class" : "Classes"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (todaysClasses.isEmpty)
            Card.filled(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No classes scheduled today!',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enjoy your break, or check the Weekly tab for your upcoming schedule.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    ),
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

class _HeroScheduleCard extends StatelessWidget {
  final ClassSession session;
  final bool isOngoing;
  final int currentMinutes;

  const _HeroScheduleCard({
    required this.session,
    required this.isOngoing,
    required this.currentMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final subjectTheme = SubjectColors.getTheme(
      session.courseCode,
      isOverload: session.isOverload,
    );

    String countdownText;
    if (isOngoing) {
      final rem = session.endTotalMinutes - currentMinutes;
      countdownText = '$rem min remaining';
    } else {
      final diff = session.startTotalMinutes - currentMinutes;
      countdownText = diff > 60
          ? 'Starts in ${diff ~/ 60}h ${diff % 60}m'
          : 'Starts in $diff min';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            subjectTheme.primary,
            subjectTheme.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: subjectTheme.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ClassDetailsSheet.show(context, session),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOngoing ? Icons.play_arrow_rounded : Icons.next_plan_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOngoing ? 'NOW HAPPENING' : 'UP NEXT',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        countdownText,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Course Code & Title
                Text(
                  session.courseCode,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session.courseTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Location & Time pills
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            session.formattedTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                session.room,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
