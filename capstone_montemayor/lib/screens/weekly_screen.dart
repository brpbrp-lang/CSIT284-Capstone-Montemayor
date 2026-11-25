import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/dummy_data.dart';
import '../models/class_session.dart';
import '../theme/subject_colors.dart';
import '../widgets/class_card.dart';

class WeeklyScreen extends StatefulWidget {
  final List<ClassSession> allClasses;
  final DateTime Function()? nowProvider;

  const WeeklyScreen({
    super.key,
    required this.allClasses,
    this.nowProvider,
  });

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen>
    with WidgetsBindingObserver {
  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  late int _selectedDayIndex;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final todayName = DateFormat('EEEE').format((widget.nowProvider ?? DateTime.now)());
    final foundIndex = _days.indexOf(todayName);
    _selectedDayIndex = foundIndex >= 0 ? foundIndex : 0;
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _formatStartHour(ClassSession session) {
    final period = session.startHour >= 12 ? 'PM' : 'AM';
    final h12 = session.startHour % 12 == 0 ? 12 : session.startHour % 12;
    final min = session.startMinute.toString().padLeft(2, '0');
    return '$h12:$min\n$period';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = _days[_selectedDayIndex];
    final now = (widget.nowProvider ?? DateTime.now)();
    final todayName = DateFormat('EEEE').format(now);
    final todayIndex = _days.indexOf(todayName);
    final isSelectedToday = selectedDay.toLowerCase() == todayName.toLowerCase();
    final currentMinutes = now.hour * 60 + now.minute;

    final dayClasses = widget.allClasses
        .where((c) => c.dayOfWeek.trim().toLowerCase() == selectedDay.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));

    final totalMinutes = dayClasses.fold<int>(
      0,
      (sum, c) => sum + (c.endTotalMinutes - c.startTotalMinutes).clamp(0, 600),
    );
    final hoursLabel =
        '${totalMinutes ~/ 60}h ${(totalMinutes % 60).toString().padLeft(2, '0')}m';

    return Container(
      color: AppPalette.bgDark,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Schedule',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.inkWhite,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppPalette.borderSubtle),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: AppPalette.electricBlue,
                      ),
                      SizedBox(width: 6),
                      Text(
                        kSectionName,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.inkWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // "Daily Goal" Style Horizontal Weekly Selector Bento Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.cardDark,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppPalette.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 20,
                        color: AppPalette.electricBlue,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Weekly Overview',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.inkWhite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppPalette.inkMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hoursLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(_days.length, (index) {
                      final day = _days[index];
                      final isSelected = index == _selectedDayIndex;
                      final isDayToday = index == todayIndex;
                      final isPastDay =
                          todayIndex != -1 && index < todayIndex;
                      final count = widget.allClasses
                          .where(
                            (c) =>
                                c.dayOfWeek.trim().toLowerCase() ==
                                day.toLowerCase(),
                          )
                          .length;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                setState(() => _selectedDayIndex = index),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppPalette.cardElevated
                                        : AppPalette.bgDark,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppPalette.electricBlue
                                          : AppPalette.borderSubtle,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      _DayStatusIcon(
                                        count: count,
                                        isPast: isPastDay,
                                        isToday: isDayToday,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        day.substring(0, 3),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppPalette.electricBlue
                                              : AppPalette.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  height: 3,
                                  width: isSelected ? 22 : 0,
                                  decoration: BoxDecoration(
                                    color: AppPalette.electricBlue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Day Timeline Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$selectedDay\'s Classes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.inkWhite,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (dayClasses.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppPalette.cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppPalette.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.bedtime_rounded,
                      size: 40,
                      color: AppPalette.inkMuted,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No classes on $selectedDay',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.inkWhite,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...dayClasses.map((session) {
                final isOngoing = isSelectedToday &&
                    currentMinutes >= session.startTotalMinutes &&
                    currentMinutes < session.endTotalMinutes;
                final isDone = isSelectedToday &&
                    currentMinutes >= session.endTotalMinutes;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          _formatStartHour(session),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.inkMuted,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClassCard(
                          session: session,
                          isOngoing: isOngoing,
                          isDone: isDone,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DayStatusIcon extends StatelessWidget {
  final int count;
  final bool isPast;
  final bool isToday;

  const _DayStatusIcon({
    required this.count,
    required this.isPast,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppPalette.cardElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'zZ',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppPalette.inkMuted,
            ),
          ),
        ),
      );
    }

    if (isPast) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppPalette.emeraldGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: AppPalette.inkDark,
        ),
      );
    }

    if (isToday) {
      return SizedBox(
        width: 26,
        height: 26,
        child: CustomPaint(
          painter: _MiniRingPainter(active: true),
        ),
      );
    }

    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(
        painter: _MiniRingPainter(active: false),
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final bool active;

  const _MiniRingPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 2;
    final innerR = outerR - 5;

    final track = Paint()
      ..color = AppPalette.borderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, outerR, track);
    canvas.drawCircle(center, innerR, track);

    if (active) {
      final blue = Paint()
        ..color = AppPalette.electricBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final white = Paint()
        ..color = AppPalette.inkWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerR),
        -math.pi / 2,
        math.pi * 1.4,
        false,
        blue,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerR),
        -math.pi / 2,
        math.pi * 1.7,
        false,
        white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) =>
      oldDelegate.active != active;
}
